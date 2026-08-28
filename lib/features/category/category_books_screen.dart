import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/layout/app_content_layout.dart';
import '../../core/models/book.dart';
import '../../core/models/category.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/auth_view_model.dart';
import '../../features/home/home_view_model.dart';
import '../../routes/app_routes.dart';

class CategoryBooksScreen extends StatelessWidget {
  const CategoryBooksScreen({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthViewModel>().user;
    final api = context.read<HomeViewModel>().api;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: AppColors.primaryDark,
      ),
      body: FutureBuilder<List<Book>>(
        future: api.fetchBooksByCategory(
          category.id,
          acervoId: user?.acervoId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar livros da categoria.\nVerifique sua conexão.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMedium),
                ),
              ),
            );
          }
          final books = snapshot.data ?? <Book>[];
          if (books.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum livro encontrado para esta categoria.',
                style: TextStyle(color: AppColors.textMedium),
              ),
            );
          }

          return AppConstrainedContent(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final book = books[index];
                return _CategoryBookTile(book: book);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryBookTile extends StatelessWidget {
  const _CategoryBookTile({required this.book});
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book.views}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
