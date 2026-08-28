import 'dart:async';

import 'package:epub_view/epub_view.dart';
// ignore: implementation_imports — contagem de parágrafos alinhada ao EpubView interno
import 'package:epub_view/src/data/epub_parser.dart' as epub_parser;
// ignore: implementation_imports — tipo do callback não exportado pelo pacote
import 'package:epub_view/src/data/models/chapter_view_value.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';

import '../../core/models/book.dart';
import '../../core/services/reading_mode_service.dart';
import '../../core/services/reading_progress_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/horizontal_scrollbar_list.dart'
    show preferVisibleHorizontalScrollbar;
import '../auth/auth_view_model.dart';
import '../home/home_view_model.dart';
import '../wishlist/wishlist_view_model.dart';
import 'epub_paged_content.dart';
import 'epub_reader_content.dart';
import 'page_slider.dart';
import 'pdf_continuous_scroll_view.dart';

class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen({super.key, required this.book});

  final Book book;

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  PdfController? _pdfPageController;
  final GlobalKey<PdfContinuousScrollViewState> _pdfScrollKey = GlobalKey();
  final GlobalKey<EpubPagedContentState> _epubPagedKey = GlobalKey();
  EpubController? _epubScrollController;

  Uint8List? _fileBytes;
  _ReaderFormat? _format;

  bool _loading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;
  int _savedPage = 1;
  final List<_ReaderNote> _notes = [];
  final Set<int> _bookmarkedPages = {};

  ReadingMode _readingMode = ReadingModeService.defaultMode;

  /// EPUB: salva progresso no servidor com debounce durante a rolagem.
  Timer? _epubProgressDebounce;

  bool _wishlistRemovalTriggered = false;

  /// Espaço para a barra flutuante não cobrir o conteúdo.
  static const double _bottomToolbarGap = 88;

  bool get _isEpub => _format == _ReaderFormat.epub;
  bool get _isPdf => _format == _ReaderFormat.pdf;
  bool get _isPageMode => _readingMode == ReadingMode.page;
  bool get _isDesktop => preferVisibleHorizontalScrollbar();

  @override
  void initState() {
    super.initState();
    debugPrint('[Reader] initState bookId=${widget.book.id}');
    _bootstrap();
  }

  @override
  void dispose() {
    _epubProgressDebounce?.cancel();
    _saveProgress(syncServer: true);
    _disposeReaders();
    super.dispose();
  }

  void _disposeReaders() {
    _pdfPageController?.dispose();
    _pdfPageController = null;
    _epubScrollController?.dispose();
    _epubScrollController = null;
  }

  Future<void> _bootstrap() async {
    final mode = await ReadingModeService.get();
    if (mounted) {
      setState(() => _readingMode = mode);
    }
    await _loadSavedProgressThenDocument();
  }

  Future<void> _loadSavedProgressThenDocument() async {
    final progress = await ReadingProgressService.get(widget.book.id);
    debugPrint(
      '[Reader] _loadSavedProgressThenDocument bookId=${widget.book.id} '
      'progress=${progress?.currentPage}/${progress?.totalPages}',
    );
    if (progress != null && progress.currentPage > 1) {
      _savedPage = progress.currentPage;
    }
    await _loadRemotePageState();
    await _loadDocument();
  }

  Future<void> _loadRemotePageState() async {
    try {
      final auth = context.read<AuthViewModel>().user;
      if (auth == null) return;
      final api = context.read<HomeViewModel>().api;
      final list = await api.fetchBookPageState(
        auth.id.toString(),
        widget.book.id,
      );
      final notes = <_ReaderNote>[];
      final bookmarks = <int>{};
      for (final item in list) {
        final page = int.tryParse('${item['page'] ?? ''}') ?? 0;
        if (page <= 0) continue;
        final isBookmark = '${item['is_bookmark'] ?? '0'}' == '1';
        final noteText = (item['note'] ?? '').toString();
        if (isBookmark) {
          bookmarks.add(page);
        }
        if (noteText.isNotEmpty) {
          DateTime created;
          final rawDate = item['updated_at']?.toString();
          if (rawDate != null && rawDate.isNotEmpty) {
            created = DateTime.tryParse(rawDate) ?? DateTime.now();
          } else {
            created = DateTime.now();
          }
          notes.add(
            _ReaderNote(
              page: page,
              text: noteText,
              createdAt: created,
            ),
          );
        }
      }
      setState(() {
        _bookmarkedPages
          ..clear()
          ..addAll(bookmarks);
        _notes
          ..clear()
          ..addAll(notes);
      });
    } catch (e) {
      debugPrint('[Reader] _loadRemotePageState erro: $e');
    }
  }

  Future<void> _saveProgress({bool syncServer = false}) async {
    if (_totalPages <= 0) {
      debugPrint(
        '[Reader] _saveProgress ignorado: totalPages=$_totalPages '
        'para bookId=${widget.book.id}',
      );
      return;
    }
    debugPrint(
      '[Reader] _saveProgress bookId=${widget.book.id} '
      'page=$_currentPage/$_totalPages',
    );
    await ReadingProgressService.save(
      bookId: widget.book.id,
      currentPage: _currentPage,
      totalPages: _totalPages,
    );

    if (syncServer && mounted) {
      try {
        final auth = context.read<AuthViewModel>().user;
        if (auth != null) {
          final api = context.read<HomeViewModel>().api;
          await api.saveContinueReading(
            auth.id.toString(),
            widget.book.id,
            currentPage: _currentPage,
            totalPages: _totalPages,
          );
        }
      } catch (e) {
        debugPrint(
          '[Reader] erro ao sincronizar leitura contínua no servidor: $e',
        );
      }
    }

    await _maybeRemoveFromWishlistIfFinished();
  }

  Future<void> _maybeRemoveFromWishlistIfFinished() async {
    if (_wishlistRemovalTriggered) return;
    if (_totalPages <= 0 || _currentPage < _totalPages) return;
    if (!mounted) return;

    final auth = context.read<AuthViewModel>().user;
    if (auth == null) return;

    _wishlistRemovalTriggered = true;
    try {
      await context.read<WishlistViewModel>().removeIfPresent(
            auth.id.toString(),
            widget.book.id,
          );
    } catch (e) {
      debugPrint('[Reader] erro ao remover de Ler Depois: $e');
      _wishlistRemovalTriggered = false;
    }
  }

  Future<void> _loadDocument() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    _disposeReaders();
    _fileBytes = null;
    _format = null;
    _totalPages = 0;
    _currentPage = 1;

    try {
      final url = widget.book.resolvedFileUrl;
      if (url.isEmpty) {
        setState(() {
          _error = 'Este livro não possui arquivo para leitura.';
        });
        return;
      }

      final uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        setState(() {
          _error = 'Não foi possível carregar o arquivo de leitura.';
        });
        return;
      }
      final bytes = response.bodyBytes;
      final pathOnly = url.toLowerCase().split('?').first;
      if (pathOnly.endsWith('.pdf')) {
        _fileBytes = bytes;
        _format = _ReaderFormat.pdf;
        _initPdfReaders();
      } else if (pathOnly.endsWith('.epub')) {
        _fileBytes = bytes;
        _format = _ReaderFormat.epub;
        _initEpubReaders();
      } else {
        setState(() {
          _error = 'Formato não suportado. Use PDF ou EPUB.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao abrir o livro. Verifique sua conexão.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _initPdfReaders() {
    if (_fileBytes == null) return;
    _pdfPageController?.dispose();
    _pdfPageController = null;
    if (_isPageMode) {
      _pdfPageController = PdfController(
        document: PdfDocument.openData(_fileBytes!),
        initialPage: _savedPage,
      );
    }
  }

  void _initEpubReaders() {
    if (_fileBytes == null) return;
    _epubScrollController?.dispose();
    _epubScrollController = null;
    if (!_isPageMode) {
      _epubScrollController = EpubController(
        document: EpubDocument.openData(_fileBytes!),
      );
    }
  }

  Future<void> _toggleReadingMode() async {
    final next =
        _isPageMode ? ReadingMode.scroll : ReadingMode.page;
    // Preserva posição atual como ponto de partida no novo modo.
    _savedPage = _currentPage;
    await ReadingModeService.save(next);
    if (!mounted) return;
    setState(() {
      _readingMode = next;
      if (_isPdf) {
        _initPdfReaders();
      } else if (_isEpub) {
        _initEpubReaders();
      }
    });
  }

  void _onEpubDocumentLoaded(EpubBook book) {
    try {
      final chapters = epub_parser.parseChapters(book);
      final parsed = epub_parser.parseParagraphs(chapters, book.Content);
      final n = parsed.flatParagraphs.length;
      if (!mounted) return;
      setState(() {
        _totalPages = n > 0 ? n : 1;
        _currentPage = 1;
      });
      if (n <= 0) return;
      final target = _savedPage.clamp(1, n);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _epubScrollController == null) return;
        _epubScrollController!.jumpTo(index: target - 1);
        setState(() => _currentPage = target);
      });
    } catch (e) {
      debugPrint('[Reader] EPUB: erro ao preparar progresso ($e)');
    }
  }

  void _onEpubPagedLoaded(EpubBook book, int paragraphCount) {
    if (!mounted) return;
    setState(() {
      _totalPages = paragraphCount > 0 ? paragraphCount : 1;
      _currentPage = _savedPage.clamp(1, _totalPages);
    });
  }

  void _scheduleEpubProgressSync() {
    if (_totalPages <= 0) return;
    unawaited(
      ReadingProgressService.save(
        bookId: widget.book.id,
        currentPage: _currentPage,
        totalPages: _totalPages,
      ),
    );
    unawaited(_maybeRemoveFromWishlistIfFinished());
    _epubProgressDebounce?.cancel();
    _epubProgressDebounce = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      unawaited(_saveProgress(syncServer: true));
    });
  }

  void _onEpubChapterChanged(EpubChapterViewValue? value) {
    if (value == null) return;
    final idx = value.position.index + 1;
    setState(() {
      _currentPage = idx.clamp(1, _totalPages > 0 ? _totalPages : 1);
    });
    _scheduleEpubProgressSync();
  }

  void _onEpubParagraphChanged(int paragraph1Based) {
    setState(() {
      _currentPage =
          paragraph1Based.clamp(1, _totalPages > 0 ? _totalPages : 1);
    });
    _scheduleEpubProgressSync();
  }

  void _onPdfPageChanged(int page) {
    setState(() => _currentPage = page);
    _saveProgress(syncServer: true);
  }

  void _onPdfDocumentLoaded(int pagesCount) {
    setState(() {
      _totalPages = pagesCount;
      _currentPage = _savedPage.clamp(1, _totalPages);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.book.title;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final showPdfSlider = !_loading &&
        _error == null &&
        _isPdf &&
        _totalPages > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.primaryDark,
      ),
      body: Stack(
        children: [
          // Conteúdo respeita notch / home indicator (mobile).
          // top: false — AppBar já consome a status bar.
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.background,
              child: SafeArea(
                top: false,
                child: _buildBody(),
              ),
            ),
          ),
          if (showPdfSlider)
            Positioned(
              top: 80,
              right: 4,
              bottom: 80 + bottomInset,
              child: SafeArea(
                top: false,
                bottom: false,
                child: PageSlider(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onJumpToPage: _jumpToPage,
                  bookmarkedPages: _bookmarkedPages,
                  notedPages: _notes.map((n) => n.page).toSet(),
                ),
              ),
            ),
          if (!_loading && _error == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: _ReaderToolbar(
                    pageLabel: (_isPdf && _totalPages > 0)
                        ? 'Página $_currentPage de $_totalPages'
                        : '',
                    isBookmarked: _totalPages > 0 &&
                        _bookmarkedPages.contains(_currentPage),
                    isPageMode: _isPageMode,
                    onToggleReadingMode: _toggleReadingMode,
                    onToggleBookmark: _toggleBookmark,
                    onAddNote: _showAddNoteSheet,
                    onTapPageLabel: (_isPdf && _totalPages > 0)
                        ? _showJumpToPageDialog
                        : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: AppColors.textMedium,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMedium),
              ),
            ],
          ),
        ),
      );
    }

    // Espaço só para a toolbar; o inset do sistema vem do SafeArea pai.
    const bottomPad = _bottomToolbarGap;

    if (_isPdf && _fileBytes != null) {
      if (_isPageMode && _pdfPageController != null) {
        return Padding(
          padding: const EdgeInsets.only(bottom: bottomPad),
          child: _PdfPagedShell(
            controller: _pdfPageController!,
            onDocumentLoaded: (doc) => _onPdfDocumentLoaded(doc.pagesCount),
            onPageChanged: _onPdfPageChanged,
            isDesktop: _isDesktop,
          ),
        );
      }
      if (!_isPageMode) {
        return PdfContinuousScrollView(
          key: _pdfScrollKey,
          bytes: _fileBytes!,
          initialPage: _savedPage,
          bottomPadding: bottomPad,
          onDocumentLoaded: _onPdfDocumentLoaded,
          onPageChanged: _onPdfPageChanged,
        );
      }
    }

    if (_isEpub && _fileBytes != null) {
      if (_isPageMode) {
        return EpubPagedContent(
          key: _epubPagedKey,
          bytes: _fileBytes!,
          initialParagraph: _savedPage,
          bottomContentPadding: bottomPad,
          onDocumentLoaded: _onEpubPagedLoaded,
          onParagraphChanged: _onEpubParagraphChanged,
          onDocumentError: (err) {
            debugPrint('[Reader] EPUB page: $err');
            if (mounted) {
              setState(() {
                _error = 'Não foi possível abrir este EPUB.';
              });
            }
          },
        );
      }
      if (_epubScrollController != null) {
        return EpubReaderContent(
          controller: _epubScrollController!,
          bottomContentPadding: bottomPad,
          onDocumentLoaded: _onEpubDocumentLoaded,
          onChapterChanged: _onEpubChapterChanged,
          onDocumentError: (err) {
            debugPrint('[Reader] EPUB: $err');
            if (mounted) {
              setState(() {
                _error = 'Não foi possível abrir este EPUB.';
              });
            }
          },
        );
      }
    }

    return const Center(
      child: Text(
        'Formato de livro não suportado.',
        style: TextStyle(color: AppColors.textMedium),
      ),
    );
  }

  void _jumpToPage(int page) {
    if (_totalPages <= 0) return;
    final target = page.clamp(1, _totalPages);
    if (_isEpub) {
      if (_isPageMode) {
        _epubPagedKey.currentState?.jumpToParagraph(target);
      } else {
        _epubScrollController?.jumpTo(index: target - 1);
      }
      setState(() => _currentPage = target);
      return;
    }
    if (_isPdf) {
      if (_isPageMode) {
        _pdfPageController?.jumpToPage(target);
      } else {
        _pdfScrollKey.currentState?.jumpToPage(target);
      }
      setState(() => _currentPage = target);
    }
  }

  Future<void> _showJumpToPageDialog() async {
    if (_totalPages <= 0) return;
    final controller = TextEditingController(text: _currentPage.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ir para página'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '1 - $_totalPages',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final v = int.tryParse(controller.text.trim());
                if (v == null || v < 1 || v > _totalPages) {
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.of(context).pop(v);
              },
              child: const Text('Ir'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      _jumpToPage(result);
    }
  }

  void _toggleBookmark() {
    if (_totalPages <= 0) return;
    setState(() {
      if (_bookmarkedPages.contains(_currentPage)) {
        _bookmarkedPages.remove(_currentPage);
      } else {
        _bookmarkedPages.add(_currentPage);
      }
    });
    _syncCurrentPageStateWithServer();
  }

  Future<void> _showAddNoteSheet() async {
    if (_totalPages <= 0) return;
    final existingIndex = _notes.indexWhere((n) => n.page == _currentPage);
    final existingNote = existingIndex >= 0 ? _notes[existingIndex] : null;

    final controller = TextEditingController(
      text: existingNote?.text ?? '',
    );
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEpub
                    ? (existingNote == null
                        ? 'Nova anotação neste trecho'
                        : 'Editar anotação')
                    : (existingNote == null
                        ? 'Nova anotação (página $_currentPage)'
                        : 'Editar anotação (página $_currentPage)'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Escreva sua anotação...',
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(controller.text.trim()),
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result == null) return;

    setState(() {
      if (result.isEmpty) {
        _notes.removeWhere((n) => n.page == _currentPage);
      } else if (existingIndex >= 0) {
        _notes[existingIndex] = _ReaderNote(
          page: _currentPage,
          text: result,
          createdAt: DateTime.now(),
        );
      } else {
        _notes.add(
          _ReaderNote(
            page: _currentPage,
            text: result,
            createdAt: DateTime.now(),
          ),
        );
      }
    });
    _syncCurrentPageStateWithServer();
  }

  Future<void> _syncCurrentPageStateWithServer() async {
    try {
      final auth = context.read<AuthViewModel>().user;
      if (auth == null) return;
      final api = context.read<HomeViewModel>().api;
      final noteForPage = _notes.firstWhere(
        (n) => n.page == _currentPage,
        orElse: () => _ReaderNote(
          page: _currentPage,
          text: '',
          createdAt: DateTime.now(),
        ),
      );
      await api.saveBookPageState(
        userId: auth.id.toString(),
        bookId: widget.book.id,
        page: _currentPage,
        isBookmark: _bookmarkedPages.contains(_currentPage),
        note: noteForPage.text,
      );
    } catch (e) {
      debugPrint('[Reader] _syncCurrentPageStateWithServer erro: $e');
    }
  }
}

enum _ReaderFormat { pdf, epub }

/// PDF em modo livro: páginas horizontais + roda do mouse / setas no desktop.
class _PdfPagedShell extends StatefulWidget {
  const _PdfPagedShell({
    required this.controller,
    required this.onDocumentLoaded,
    required this.onPageChanged,
    required this.isDesktop,
  });

  final PdfController controller;
  final void Function(PdfDocument document) onDocumentLoaded;
  final ValueChanged<int> onPageChanged;
  final bool isDesktop;

  @override
  State<_PdfPagedShell> createState() => _PdfPagedShellState();
}

class _PdfPagedShellState extends State<_PdfPagedShell> {
  DateTime _lastWheelNav = DateTime.fromMillisecondsSinceEpoch(0);

  void _goRelative(int delta) {
    if (delta > 0) {
      widget.controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else if (delta < 0) {
      widget.controller.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onWheel(PointerScrollEvent signal) {
    final now = DateTime.now();
    if (now.difference(_lastWheelNav) < const Duration(milliseconds: 320)) {
      return;
    }
    if (signal.scrollDelta.dy > 8 || signal.scrollDelta.dx > 8) {
      _lastWheelNav = now;
      _goRelative(1);
    } else if (signal.scrollDelta.dy < -8 || signal.scrollDelta.dx < -8) {
      _lastWheelNav = now;
      _goRelative(-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = PdfView(
      controller: widget.controller,
      scrollDirection: Axis.horizontal,
      pageSnapping: true,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      onDocumentLoaded: widget.onDocumentLoaded,
      onPageChanged: widget.onPageChanged,
      backgroundDecoration: const BoxDecoration(color: AppColors.background),
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _goRelative(1),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _goRelative(-1),
        const SingleActivator(LogicalKeyboardKey.pageDown): () =>
            _goRelative(1),
        const SingleActivator(LogicalKeyboardKey.pageUp): () =>
            _goRelative(-1),
      },
      child: Focus(
        autofocus: true,
        child: Listener(
          onPointerSignal: (signal) {
            if (signal is PointerScrollEvent) _onWheel(signal);
          },
          child: Stack(
            children: [
              view,
              if (!widget.isDesktop)
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _goRelative(-1),
                        ),
                      ),
                      const Spacer(flex: 2),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _goRelative(1),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReaderToolbar extends StatelessWidget {
  const _ReaderToolbar({
    required this.pageLabel,
    required this.isBookmarked,
    required this.isPageMode,
    required this.onToggleReadingMode,
    required this.onToggleBookmark,
    required this.onAddNote,
    this.onTapPageLabel,
  });

  final String pageLabel;
  final bool isBookmarked;
  final bool isPageMode;
  final VoidCallback onToggleReadingMode;
  final VoidCallback onToggleBookmark;
  final VoidCallback onAddNote;
  final VoidCallback? onTapPageLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (pageLabel.isNotEmpty)
            InkWell(
              onTap: onTapPageLabel,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  pageLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            ),
          const Spacer(),
          IconButton(
            tooltip: isPageMode
                ? 'Alternar para rolagem'
                : 'Alternar para páginas (livro)',
            icon: Icon(
              isPageMode
                  ? Icons.swipe_rounded
                  : Icons.menu_book_rounded,
              color: AppColors.primaryDark,
            ),
            onPressed: onToggleReadingMode,
          ),
          IconButton(
            tooltip: isBookmarked ? 'Remover marcação' : 'Marcar página',
            icon: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border,
              color: isBookmarked ? AppColors.accent : AppColors.textMedium,
            ),
            onPressed: onToggleBookmark,
          ),
          IconButton(
            tooltip: 'Adicionar anotação',
            icon: const Icon(
              Icons.edit_note_rounded,
              color: AppColors.textMedium,
            ),
            onPressed: onAddNote,
          ),
        ],
      ),
    );
  }
}

class _ReaderNote {
  _ReaderNote({
    required this.page,
    required this.text,
    required this.createdAt,
  });

  final int page;
  final String text;
  final DateTime createdAt;
}
