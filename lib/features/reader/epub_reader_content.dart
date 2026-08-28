import 'package:epub_view/epub_view.dart';
// ignore: implementation_imports — tipo do callback não exportado pelo pacote
import 'package:epub_view/src/data/models/chapter_view_value.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/horizontal_scrollbar_list.dart'
    show preferVisibleHorizontalScrollbar;
import 'reader_zoom.dart';

/// Leitura EPUB em rolagem vertical contínua, com zoom de texto.
class EpubReaderContent extends StatefulWidget {
  const EpubReaderContent({
    super.key,
    required this.controller,
    this.bottomContentPadding = 0,
    this.onChapterChanged,
    this.onDocumentLoaded,
    this.onDocumentError,
  });

  final EpubController controller;

  /// Evita que o último parágrafo fique atrás da barra de marca-página / anotações.
  final double bottomContentPadding;
  final void Function(EpubChapterViewValue? value)? onChapterChanged;
  final void Function(EpubBook document)? onDocumentLoaded;
  final void Function(Exception? error)? onDocumentError;

  @override
  State<EpubReaderContent> createState() => _EpubReaderContentState();
}

class _EpubReaderContentState extends State<EpubReaderContent>
    with ReaderZoomStateMixin {
  @override
  void initState() {
    super.initState();
    initZoomKeyboardListener();
  }

  @override
  void dispose() {
    disposeZoomKeyboardListener();
    super.dispose();
  }

  static Future<void> _openExternalLink(String href) async {
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
    final isDesktop = preferVisibleHorizontalScrollbar();
    final base = ScrollConfiguration.of(context);
    final basePhysics = isDesktop
        ? const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
        : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
    final physics = zoomAwarePhysics(basePhysics);

    final fontSize = 17 * zoom;

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
            ScrollConfiguration(
              behavior: base.copyWith(physics: physics, scrollbars: !isDesktop),
              child: Padding(
                padding: EdgeInsets.only(bottom: widget.bottomContentPadding),
                child: EpubView(
                  controller: widget.controller,
                  onChapterChanged: widget.onChapterChanged,
                  onDocumentLoaded: widget.onDocumentLoaded,
                  onDocumentError: widget.onDocumentError,
                  onExternalLinkPressed: _openExternalLink,
                  builders: EpubViewBuilders(
                    options: DefaultBuilderOptions(
                      textStyle: TextStyle(
                        fontSize: fontSize,
                        height: 1.55,
                        color: AppColors.textDark,
                      ),
                      paragraphPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            buildZoomButtons(
              bottom: widget.bottomContentPadding > 0
                  ? widget.bottomContentPadding + 8
                  : 96,
            ),
          ],
        ),
      ),
    );
  }
}
