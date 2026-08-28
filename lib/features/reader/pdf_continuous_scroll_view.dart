import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/horizontal_scrollbar_list.dart'
    show preferVisibleHorizontalScrollbar;
import 'reader_zoom.dart';

/// Rolagem vertical contínua de páginas PDF com zoom (pinça / Ctrl+scroll).
class PdfContinuousScrollView extends StatefulWidget {
  const PdfContinuousScrollView({
    super.key,
    required this.bytes,
    this.initialPage = 1,
    this.onDocumentLoaded,
    this.onPageChanged,
    this.bottomPadding = 0,
  });

  final Uint8List bytes;
  final int initialPage;
  final void Function(int pagesCount)? onDocumentLoaded;
  final ValueChanged<int>? onPageChanged;
  final double bottomPadding;

  @override
  State<PdfContinuousScrollView> createState() =>
      PdfContinuousScrollViewState();
}

class PdfContinuousScrollViewState extends State<PdfContinuousScrollView>
    with ReaderZoomStateMixin {
  final Map<int, Uint8List> _pageImages = {};
  final Set<int> _loadingPages = {};
  final Map<int, double> _pageHeights = {};

  /// Serializa renderizações (Android não permite páginas PDF em paralelo).
  Future<void> _renderQueue = Future.value();

  ScrollController? _vScrollController;
  ScrollController? _hScrollController;
  PdfDocument? _document;
  int _pagesCount = 0;
  int _currentPage = 1;
  String? _error;
  bool _opening = true;
  bool _didInitialJump = false;

  /// Faixa de qualidade de render (evita re-render a cada 1% de zoom).
  int _renderQualityBucket = 1;

  static const double _fallbackPageExtent = 720;

  bool get _isDesktop => preferVisibleHorizontalScrollbar();

  @override
  void initState() {
    super.initState();
    initZoomKeyboardListener();
    _openDocument();
  }

  @override
  void dispose() {
    disposeZoomKeyboardListener();
    _vScrollController?.removeListener(_onScroll);
    _vScrollController?.dispose();
    _hScrollController?.dispose();
    unawaited(_document?.close());
    super.dispose();
  }

  Future<void> _openDocument() async {
    try {
      final doc = await PdfDocument.openData(widget.bytes);
      if (!mounted) {
        await doc.close();
        return;
      }
      _document = doc;
      _pagesCount = doc.pagesCount;
      _currentPage = widget.initialPage.clamp(1, _pagesCount);
      _vScrollController = ScrollController();
      _hScrollController = ScrollController();
      _vScrollController!.addListener(_onScroll);

      setState(() => _opening = false);
      widget.onDocumentLoaded?.call(_pagesCount);

      unawaited(_ensurePageRendered(_currentPage));
      unawaited(_ensurePageRendered(_currentPage + 1));
      unawaited(_ensurePageRendered(_currentPage - 1));
    } catch (e) {
      debugPrint('[Reader] PDF scroll: falha ao abrir ($e)');
      if (mounted) {
        setState(() {
          _opening = false;
          _error = 'Não foi possível abrir o PDF.';
        });
      }
    }
  }

  @override
  void onZoomChanged(double previous, double next) {
    // Mantém a página aproximada na mesma posição vertical.
    final factor = next / previous;
    for (final key in _pageHeights.keys.toList()) {
      _pageHeights[key] = _pageHeights[key]! * factor;
    }

    final c = _vScrollController;
    if (c != null && c.hasClients) {
      final newOffset =
          (c.offset * factor).clamp(0.0, c.position.maxScrollExtent);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _vScrollController == null) return;
        final sc = _vScrollController!;
        if (sc.hasClients) {
          sc.jumpTo(newOffset.clamp(0.0, sc.position.maxScrollExtent));
        }
      });
    }

    // Re-renderiza em maior resolução quando o zoom sobe de faixa.
    final bucket = next < 1.4
        ? 1
        : next < 2.2
            ? 2
            : next < 3.2
                ? 3
                : 4;
    if (bucket > _renderQualityBucket) {
      _renderQualityBucket = bucket;
      _pageImages.clear();
      unawaited(_ensurePageRendered(_currentPage));
      unawaited(_ensurePageRendered(_currentPage + 1));
      unawaited(_ensurePageRendered(_currentPage - 1));
    }
  }

  double _extentForPage(int pageNumber) =>
      _pageHeights[pageNumber] ?? (_fallbackPageExtent * zoom);

  double _offsetForPage(int pageNumber) {
    var offset = 0.0;
    for (var i = 1; i < pageNumber; i++) {
      offset += _extentForPage(i);
    }
    return offset;
  }

  int _pageForOffset(double offset) {
    var remaining = offset;
    for (var i = 1; i <= _pagesCount; i++) {
      final h = _extentForPage(i);
      if (remaining < h * 0.55) return i;
      remaining -= h;
    }
    return _pagesCount;
  }

  void _onScroll() {
    final c = _vScrollController;
    if (c == null || !c.hasClients || _pagesCount <= 0) return;

    final page = _pageForOffset(c.offset).clamp(1, _pagesCount);
    if (page != _currentPage) {
      _currentPage = page;
      widget.onPageChanged?.call(_currentPage);
    }

    unawaited(_ensurePageRendered(page));
    unawaited(_ensurePageRendered(page + 1));
    unawaited(_ensurePageRendered(page + 2));
  }

  void _jumpToPage(int page) {
    final c = _vScrollController;
    if (c == null || !c.hasClients) return;
    final target = page.clamp(1, _pagesCount);
    final offset = _offsetForPage(target);
    c.jumpTo(offset.clamp(0.0, c.position.maxScrollExtent));
  }

  void jumpToPage(int page) {
    if (_pagesCount <= 0) return;
    final target = page.clamp(1, _pagesCount);
    setState(() => _currentPage = target);
    _jumpToPage(target);
    widget.onPageChanged?.call(target);
    unawaited(_ensurePageRendered(target));
  }

  double get _renderScale {
    final base = _isDesktop ? 1.6 : 1.4;
    return base * _renderQualityBucket;
  }

  Future<void> _ensurePageRendered(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > _pagesCount) return;
    if (_pageImages.containsKey(pageNumber) ||
        _loadingPages.contains(pageNumber)) {
      return;
    }
    final doc = _document;
    if (doc == null || doc.isClosed) return;

    _loadingPages.add(pageNumber);
    final completer = Completer<void>();
    final previous = _renderQueue;
    _renderQueue = completer.future;
    try {
      await previous;
      final page = await doc.getPage(pageNumber);
      Uint8List? bytes;
      try {
        final scale = _renderScale;
        final image = await page.render(
          width: page.width * scale,
          height: page.height * scale,
          format: PdfPageImageFormat.jpeg,
          backgroundColor: '#ffffff',
          quality: 85,
        );
        bytes = image?.bytes;
      } finally {
        await page.close();
      }

      if (!mounted || bytes == null) return;
      final rendered = bytes;
      setState(() => _pageImages[pageNumber] = rendered);

      if (!_didInitialJump && pageNumber == _currentPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _didInitialJump = true;
          _jumpToPage(_currentPage);
        });
      }
    } catch (e) {
      debugPrint('[Reader] PDF scroll: erro ao renderizar p.$pageNumber ($e)');
    } finally {
      _loadingPages.remove(pageNumber);
      if (!completer.isCompleted) completer.complete();
    }
  }

  void _onPageHeight(int pageNumber, double height) {
    if (height <= 0) return;
    final previous = _pageHeights[pageNumber];
    if (previous != null && (previous - height).abs() < 2) return;
    setState(() => _pageHeights[pageNumber] = height);
  }

  @override
  Widget build(BuildContext context) {
    if (_opening) {
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

    final basePhysics = _isDesktop
        ? const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
        : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
    final physics = zoomAwarePhysics(basePhysics);

    return ColoredBox(
      color: AppColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth * zoom;
          final zoomed = zoom > 1.05;

          final list = ListView.builder(
            controller: _vScrollController,
            physics: physics,
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: 8 + widget.bottomPadding,
            ),
            itemCount: _pagesCount,
            itemBuilder: (context, index) {
              final pageNumber = index + 1;
              if (!_pageImages.containsKey(pageNumber)) {
                unawaited(_ensurePageRendered(pageNumber));
              }
              return _PdfScrollPageTile(
                pageNumber: pageNumber,
                imageBytes: _pageImages[pageNumber],
                onMeasuredHeight: (h) => _onPageHeight(pageNumber, h),
              );
            },
          );

          Widget vertical = list;
          if (_isDesktop && _vScrollController != null) {
            vertical = Scrollbar(
              controller: _vScrollController,
              thumbVisibility: true,
              interactive: true,
              child: list,
            );
          }

          final body = SizedBox(
            width: contentWidth,
            height: constraints.maxHeight,
            child: vertical,
          );

          final scroller = zoomed
              ? SingleChildScrollView(
                  controller: _hScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: body,
                )
              : body;

          return Listener(
            onPointerSignal: (signal) {
              if (signal is PointerScrollEvent) {
                handleCtrlScrollZoom(signal);
              }
            },
            child: GestureDetector(
              onScaleStart: handlePinchStart,
              onScaleUpdate: handlePinchUpdate,
              child: Stack(
                children: [
                  scroller,
                  buildZoomButtons(
                    bottom: widget.bottomPadding > 0
                        ? widget.bottomPadding + 8
                        : 96,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PdfScrollPageTile extends StatelessWidget {
  const _PdfScrollPageTile({
    required this.pageNumber,
    required this.imageBytes,
    required this.onMeasuredHeight,
  });

  final int pageNumber;
  final Uint8List? imageBytes;
  final ValueChanged<double> onMeasuredHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: imageBytes == null
            ? const SizedBox(
                height: 480,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              )
            : _MeasuredImage(
                bytes: imageBytes!,
                onMeasuredHeight: onMeasuredHeight,
              ),
      ),
    );
  }
}

class _MeasuredImage extends StatefulWidget {
  const _MeasuredImage({
    required this.bytes,
    required this.onMeasuredHeight,
  });

  final Uint8List bytes;
  final ValueChanged<double> onMeasuredHeight;

  @override
  State<_MeasuredImage> createState() => _MeasuredImageState();
}

class _MeasuredImageState extends State<_MeasuredImage> {
  final _key = GlobalKey();

  void _report() {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      widget.onMeasuredHeight(box.size.height + 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      key: _key,
      widget.bytes,
      fit: BoxFit.fitWidth,
      width: double.infinity,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, sync) {
        if (frame != null || sync) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _report());
        }
        return child;
      },
      errorBuilder: (_, __, ___) => const SizedBox(
        height: 200,
        child: Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
  }
}
