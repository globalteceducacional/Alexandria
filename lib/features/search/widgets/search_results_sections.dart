import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/author.dart';
import '../../../core/models/book.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/html_decode.dart';
import '../../../routes/app_routes.dart';

class SearchResultsSections extends StatelessWidget {
  const SearchResultsSections({
    super.key,
    required this.query,
    required this.books,
    required this.authors,
    this.padding = const EdgeInsets.fromLTRB(0, 16, 0, 0),
  });

  final String query;
  final List<Book> books;
  final List<Author> authors;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final hasBooks = books.isNotEmpty;
    final hasAuthors = authors.isNotEmpty;
    if (!hasBooks && !hasAuthors) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Nenhum resultado para "$query".',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMedium,
            fontSize: 14,
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width >= 1100
              ? 4
              : width >= 800
                  ? 3
                  : 2;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasBooks) ...[
                const Text(
                  'Livros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    // Valor um pouco maior para deixar os
                    // cards menos altos em telas grandes.
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: books.length,
                  itemBuilder: (_, i) => _SearchBookCard(book: books[i]),
                ),
              ],
              if (hasAuthors) ...[
                SizedBox(height: hasBooks ? 18 : 0),
                const Text(
                  'Autores',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  itemCount: authors.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => _SearchAuthorTile(
                    author: authors[index],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SearchBookCard extends StatelessWidget {
  const _SearchBookCard({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.bookDetail,
        arguments: book,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: book.coverImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.primaryDark.withAlpha(20),
                    child: const Icon(
                      Icons.book_outlined,
                      size: 32,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            if (book.authorName.isNotEmpty)
              Text(
                book.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchAuthorTile extends StatelessWidget {
  const _SearchAuthorTile({required this.author});
  final Author author;

  @override
  Widget build(BuildContext context) {
    final description = cleanHtmlText(author.description);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.authorDetail,
        arguments: author,
      ),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 96),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryDark.withAlpha(20),
                backgroundImage: author.imageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(author.imageUrl)
                    : null,
                child: author.imageUrl.isEmpty
                    ? Text(
                        author.name.isNotEmpty ? author.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 3,
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
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textMedium),
            ],
          ),
        ),
      ),
    );
  }
}
