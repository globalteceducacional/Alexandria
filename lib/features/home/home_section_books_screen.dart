import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/layout/app_content_layout.dart';
import '../../core/models/book.dart';
import '../../core/models/home_section.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

class HomeSectionBooksScreen extends StatelessWidget {
  const HomeSectionBooksScreen({super.key, required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    final List<Book> books = section.books;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(section.title),
        backgroundColor: AppColors.primaryDark,
      ),
      body: books.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhum livro encontrado para esta sessão.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMedium),
                ),
              ),
            )
          : AppConstrainedContent(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: books.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final book = books[index];
                  return _SectionBookTile(book: book);
                },
              ),
            ),
    );
  }
}

class _SectionBookTile extends StatelessWidget {
  const _SectionBookTile({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.bookDetail,
          arguments: book,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 90,
                child: CachedNetworkImage(
                  imageUrl: book.coverImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.primaryDark.withAlpha(20),
                    child: const Icon(
                      Icons.book_outlined,
                      color: AppColors.textLight,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.primaryDark.withAlpha(20),
                    child: const Icon(
                      Icons.book_outlined,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (book.authorName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      book.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
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
  }
}

