import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Desktop (Windows/macOS/Linux): barra de rolagem visível na lista horizontal.
bool preferVisibleHorizontalScrollbar() {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

/// Espaço extra abaixo do conteúdo para a trilha do scrollbar no desktop.
const double _desktopScrollbarBottomGap = 14;

/// [ListView] horizontal com [Scrollbar] no desktop — mouse + indicação visual.
class HorizontalScrollbarList extends StatefulWidget {
  const HorizontalScrollbarList({
    super.key,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.physics,
  });

  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  State<HorizontalScrollbarList> createState() =>
      _HorizontalScrollbarListState();
}

class _HorizontalScrollbarListState extends State<HorizontalScrollbarList> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktopScrollbar = preferVisibleHorizontalScrollbar();
    final basePadding = widget.padding ?? EdgeInsets.zero;
    final resolvedPadding = basePadding.resolve(Directionality.of(context));
    final listPadding = desktopScrollbar
        ? resolvedPadding.copyWith(
            bottom: resolvedPadding.bottom + _desktopScrollbarBottomGap,
          )
        : basePadding;

    final list = ListView.builder(
      controller: _controller,
      primary: false,
      scrollDirection: Axis.horizontal,
      padding: listPadding,
      physics: widget.physics,
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
    );

    if (!desktopScrollbar) {
      return SizedBox(height: widget.height, child: list);
    }

    return SizedBox(
      height: widget.height + _desktopScrollbarBottomGap,
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        child: list,
      ),
    );
  }
}
