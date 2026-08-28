import 'package:flutter/material.dart';

/// Limites de largura do conteúdo em telas grandes (barra superior em largura total).
class AppLayout {
  AppLayout._();

  static const double wideBreakpoint = 900;
  static const double contentMaxCap = 1200;

  static double contentMaxWidth(double screenWidth) {
    if (screenWidth <= wideBreakpoint) return screenWidth;
    return screenWidth < contentMaxCap ? screenWidth : contentMaxCap;
  }
}

/// Centraliza e limita a largura do corpo da tela, mantendo AppBars em largura total.
class AppConstrainedContent extends StatelessWidget {
  const AppConstrainedContent({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.maxWidth,
  });

  final Widget child;
  final Alignment alignment;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            maxWidth ?? AppLayout.contentMaxWidth(constraints.maxWidth);
        return Align(
          alignment: alignment,
          child: SizedBox(
            width: width,
            child: child,
          ),
        );
      },
    );
  }
}
