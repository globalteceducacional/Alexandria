import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PageSlider extends StatelessWidget {
  const PageSlider({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onJumpToPage,
    required this.bookmarkedPages,
    required this.notedPages,
  });

  final int currentPage;
  final int totalPages;
  final void Function(int page) onJumpToPage;
  final Set<int> bookmarkedPages;
  final Set<int> notedPages;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackTop = 8.0;
          final trackBottom = constraints.maxHeight - 8.0;
          final trackHeight = (trackBottom - trackTop).clamp(1.0, double.infinity);

          final clampedPage = currentPage.clamp(1, totalPages);
          final t = totalPages > 1
              ? (clampedPage - 1) / (totalPages - 1)
              : 0.0;
          // Top = página 1, bottom = última página
          final thumbCenterY = trackTop + t * trackHeight;

          final bothPages = bookmarkedPages.intersection(notedPages);
          final noteOnlyPages = notedPages.difference(bothPages);
          final bookmarkOnlyPages = bookmarkedPages.difference(bothPages);

          int pageFromOffset(double dy) {
            final localDy = dy.clamp(trackTop, trackBottom);
            final frac = (localDy - trackTop) / trackHeight;
            final page =
                1 + frac * (totalPages > 1 ? (totalPages - 1) : 0);
            return page.round().clamp(1, totalPages);
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              onJumpToPage(pageFromOffset(details.localPosition.dy));
            },
            onVerticalDragUpdate: (details) {
              onJumpToPage(pageFromOffset(details.localPosition.dy));
            },
            child: Stack(
              children: [
                // Trilho principal
                Positioned(
                  left: (constraints.maxWidth - 4) / 2,
                  top: trackTop,
                  bottom: constraints.maxHeight - trackBottom,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Marcadores de páginas com notas (somente nota)
                ...noteOnlyPages.map((page) {
                  final p = page.clamp(1, totalPages);
                  final tt = totalPages > 1
                      ? (p - 1) / (totalPages - 1)
                      : 0.0;
                  final y = trackTop + tt * trackHeight;
                  return Positioned(
                    left: (constraints.maxWidth - 6) / 2,
                    top: y - 3,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }),

                // Marcadores de páginas marcadas (somente bookmark)
                ...bookmarkOnlyPages.map((page) {
                  final p = page.clamp(1, totalPages);
                  final tt = totalPages > 1
                      ? (p - 1) / (totalPages - 1)
                      : 0.0;
                  final y = trackTop + tt * trackHeight;
                  return Positioned(
                    left: (constraints.maxWidth - 8) / 2,
                    top: y - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                      ),
                    ),
                  );
                }),
                // Marcadores combinados (nota + bookmark na mesma página)
                ...bothPages.map((page) {
                  final p = page.clamp(1, totalPages);
                  final tt = totalPages > 1
                      ? (p - 1) / (totalPages - 1)
                      : 0.0;
                  final y = trackTop + tt * trackHeight;
                  return Positioned(
                    left: (constraints.maxWidth - 8) / 2,
                    top: y - 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 8,
                        height: 8,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(color: AppColors.accent),
                            ),
                            Expanded(
                              child: Container(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Thumb da página atual
                Positioned(
                  left: (constraints.maxWidth - 14) / 2,
                  top: thumbCenterY - 7,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                // Label com o número da página ao lado do thumb
                Positioned(
                  right: -40,
                  top: thumbCenterY - 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(160),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$clampedPage',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


