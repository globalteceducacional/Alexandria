import 'dart:async';
import 'dart:math' as math;

import 'package:epub_view/epub_view.dart' hide Image;
// ignore: implementation_imports — parser interno alinhado ao EpubView
import 'package:epub_view/src/data/epub_parser.dart' as epub_parser;
// ignore: implementation_imports — modelo de parágrafo não exportado pelo pacote
import 'package:epub_view/src/data/models/paragraph.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';

/// Leitura EPUB com passagem lateral de páginas (como um livro).
///
/// Cada “página” agrupa parágrafos suficientes para preencher a viewport.
/// O progresso externo continua em índice de parágrafo (1-based), compatível
/// com o modo rolagem e com bookmarks existentes.
class EpubPagedContent extends StatefulWidget {
  const EpubPagedContent({
    super.key,
    required this.bytes,
    this.initialParagraph = 1,
    this.bottomContentPadding = 0,
    this.onDocumentLoaded,
    this.onParagraphChanged,
    this.onDocumentError,
  });

  final Uint8List bytes;

  /// Parágrafo inicial (1-based), alinhado ao progresso salvo.
  final int initialParagraph;
  final double bottomContentPadding;
  final void Function(EpubBook book, int paragraphCount)? onDocumentLoaded;

  /// Parágrafo visível (1-based) — início da página atual.
  final ValueChanged<int>? onParagraphChanged;
  final void Function(Exception? error)? onDocumentError;

  @override
  State<EpubPagedContent> createState() => EpubPagedContentState();
}

class EpubPagedContentState extends State<EpubPagedContent> {
  static const _textStyle = TextStyle(
    fontSize: 17,
    height: 1.55,
    color: AppColors.textDark,
  );

  PageController? _pageController;
  EpubBook? _book;
  List<Paragraph> _paragraphs = const [];
  List<_EpubPageSlice> _pages = const [];
  int _currentPageIndex = 0;
  bool _loading = true;
  String? _error;
  Size? _lastViewport;
  DateTime _lastWheelNav = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final book = await EpubDocument.openData(widget.bytes);
      final chapters = epub_parser.parseChapters(book);
      final parsed = epub_parser.parseParagraphs(chapters, book.Content);
      if (!mounted) return;
      _book = book;
      _paragraphs = parsed.flatParagraphs;
      setState(() => _loading = false);
      widget.onDocumentLoaded?.call(
        book,
        _paragraphs.isEmpty ? 1 : _paragraphs.length,
      );
    } catch (e) {
      debugPrint('[Reader] EPUB page: falha ao abrir ($e)');
      widget.onDocumentError?.call(e is Exception ? e : Exception('$e'));
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Não foi possível abrir este EPUB.';
        });
      }
    }
  }

  void _rebuildPages(Size viewport) {
    if (_paragraphs.isEmpty) {
      _pages = const [_EpubPageSlice(0, 0)];
      return;
    }

    // Estimativa: quantos parágrafos cabem por tela.
    final usableHeight =
        (viewport.height - widget.bottomContentPadding - 32).clamp(120.0, 4000.0);
    final lineHeight = _textStyle.fontSize! * _textStyle.height!;
    final approxLines = (usableHeight / lineHeight).floor();
    // ~3–4 linhas por parágrafo em média; no mínimo 1 parágrafo por página.
    final perPage = math.max(1, (approxLines / 3.5).round());

    final slices = <_EpubPageSlice>[];
    for (var i = 0; i < _paragraphs.length; i += perPage) {
      final end = math.min(i + perPage, _paragraphs.length);
      slices.add(_EpubPageSlice(i, end));
    }
    _pages = slices;

    final targetParagraph =
        (widget.initialParagraph - 1).clamp(0, _paragraphs.length - 1);
    final pageIndex = _pages.indexWhere(
      (s) => targetParagraph >= s.start && targetParagraph < s.end,
    );
    _currentPageIndex = pageIndex >= 0 ? pageIndex : 0;

    _pageController?.dispose();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  /// Salto por índice de parágrafo (1-based), usado pelo progresso / bookmarks.
  void jumpToParagraph(int paragraph1Based) {
    if (_pages.isEmpty || _pageController == null) return;
    final idx = (paragraph1Based - 1).clamp(0, _paragraphs.length - 1);
    final pageIndex = _pages.indexWhere((s) => idx >= s.start && idx < s.end);
    if (pageIndex < 0) return;
    _pageController!.jumpToPage(pageIndex);
    setState(() => _currentPageIndex = pageIndex);
    widget.onParagraphChanged?.call(_pages[pageIndex].start + 1);
  }

  void _onPageChanged(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() => _currentPageIndex = index);
    widget.onParagraphChanged?.call(_pages[index].start + 1);
  }

  void _goRelative(int delta) {
    final c = _pageController;
    if (c == null || !c.hasClients) return;
    final next = (_currentPageIndex + delta).clamp(0, _pages.length - 1);
    if (next == _currentPageIndex) return;
    c.animateToPage(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openExternalLink(String? href) async {
    if (href == null || href.isEmpty) return;
    final uri = Uri.tryParse(href);
    if (uri == null) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[Reader] EPUB link externo falhou: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: AppColors.textMedium),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        if (_lastViewport != viewport || _pages.isEmpty) {
          _lastViewport = viewport;
          // Agenda rebuild fora do build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _rebuildPages(viewport));
            widget.onParagraphChanged
                ?.call(_pages[_currentPageIndex].start + 1);
          });
        }

        if (_pageController == null || _pages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

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
                if (signal is! PointerScrollEvent) return;
                final now = DateTime.now();
                if (now.difference(_lastWheelNav) <
                    const Duration(milliseconds: 320)) {
                  return;
                }
                if (signal.scrollDelta.dy > 8 || signal.scrollDelta.dx > 8) {
                  _lastWheelNav = now;
                  _goRelative(1);
                } else if (signal.scrollDelta.dy < -8 ||
                    signal.scrollDelta.dx < -8) {
                  _lastWheelNav = now;
                  _goRelative(-1);
                }
              },
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final slice = _pages[index];
                      return _EpubPageBody(
                        book: _book!,
                        paragraphs: _paragraphs.sublist(slice.start, slice.end),
                        bottomPadding: widget.bottomContentPadding,
                        textStyle: _textStyle,
                        onLinkTap: _openExternalLink,
                      );
                    },
                  ),
                  // Zonas de toque laterais (mobile / desktop).
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
      },
    );
  }
}

class _EpubPageSlice {
  const _EpubPageSlice(this.start, this.end);

  final int start;
  final int end;
}

class _EpubPageBody extends StatelessWidget {
  const _EpubPageBody({
    required this.book,
    required this.paragraphs,
    required this.bottomPadding,
    required this.textStyle,
    required this.onLinkTap,
  });

  final EpubBook book;
  final List<Paragraph> paragraphs;
  final double bottomPadding;
  final TextStyle textStyle;
  final void Function(String? href) onLinkTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paragraphs.length,
          itemBuilder: (context, index) {
            final p = paragraphs[index];
            return Html(
              data: p.element.outerHtml,
              onLinkTap: (href, _, __) => onLinkTap(href),
              style: {
                'html': Style.fromTextStyle(textStyle).copyWith(
                  padding: HtmlPaddings.symmetric(vertical: 6),
                ),
              },
              extensions: [
                TagExtension(
                  tagsToExtend: {'img'},
                  builder: (imageContext) {
                    final src = imageContext.attributes['src'];
                    if (src == null) return const SizedBox.shrink();
                    final url = src.replaceAll('../', '');
                    final bytes = book.Content?.Images?[url]?.Content;
                    if (bytes == null) return const SizedBox.shrink();
                    return Image(
                      image: MemoryImage(Uint8List.fromList(bytes)),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
