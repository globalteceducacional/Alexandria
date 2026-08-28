import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/layout/app_content_layout.dart';
import '../../core/models/book.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

class ProfileBooksListScreen extends StatelessWidget {
  const ProfileBooksListScreen({
    super.key,
    required this.title,
    required this.books,
  });

  final String title;
  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primaryDark,
      ),
      body: AppConstrainedContent(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemBuilder: (_, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.bookDetail,
              arguments: book,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 60,
                      height: 85,
                      child: CachedNetworkImage(
                        imageUrl: book.coverImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primaryDark.withAlpha(20),
                          child: const Icon(
                            Icons.book,
                            size: 24,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (book.authorName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            book.authorName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: books.length,
        ),
      ),
    );
  }
}

