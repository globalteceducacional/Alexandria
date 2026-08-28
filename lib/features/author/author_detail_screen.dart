import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/layout/app_content_layout.dart';
import '../../core/models/author.dart';
import '../../core/models/book.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/html_decode.dart';
import '../../features/auth/auth_view_model.dart';
import '../../features/favorites/favorite_view_model.dart';
import '../../features/home/home_view_model.dart';
import '../../routes/app_routes.dart';

class AuthorDetailScreen extends StatelessWidget {
  const AuthorDetailScreen({super.key, required this.author});

  final Author author;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthViewModel>().user;
    final api = context.read<HomeViewModel>().api;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(author.name),
        backgroundColor: AppColors.primaryDark,
      ),
      body: FutureBuilder<List<Book>>(
        future: api.fetchBooksByAuthor(
          author.id,
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
                  'Erro ao carregar dados do autor.\nVerifique sua conexão.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMedium),
                ),
              ),
            );
          }
          final books = snapshot.data ?? <Book>[];

          final description = cleanHtmlText(author.description);

          return AppConstrainedContent(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _AuthorHeader(author: author, totalBooks: books.length),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Sobre o autor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (books.isNotEmpty)
                  const Text(
                    'Livros do autor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                if (books.isNotEmpty) const SizedBox(height: 12),
                for (final book in books) _AuthorBookTile(book: book),
                if (books.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Text(
                        'Nenhum livro encontrado para este autor.',
                        style: TextStyle(color: AppColors.textMedium),
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

class _AuthorHeader extends StatelessWidget {
  const _AuthorHeader({required this.author, required this.totalBooks});

  final Author author;
  final int totalBooks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryDark.withAlpha(20),
            backgroundImage: author.imageUrl.isNotEmpty
                ? CachedNetworkImageProvider(author.imageUrl)
                : null,
            child: author.imageUrl.isEmpty
                ? Text(
                    author.name.isNotEmpty
                        ? author.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                if (totalBooks > 0)
                  Text(
                    '$totalBooks livro(s) neste acervo',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorBookTile extends StatefulWidget {
  const _AuthorBookTile({required this.book});

  final Book book;

  @override
  State<_AuthorBookTile> createState() => _AuthorBookTileState();
}

class _AuthorBookTileState extends State<_AuthorBookTile> {
  late final String _userId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthViewModel>();
    _userId = auth.user?.id.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.bookDetail,
        arguments: book,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
                  if (book.categoryName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      book.categoryName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    cleanHtmlText(book.description).isEmpty
                        ? 'Sem sinopse disponível.'
                        : cleanHtmlText(book.description),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Consumer<FavoriteViewModel>(
              builder: (_, favVm, __) {
                final isFav = favVm.isFavorite(_userId, book.id);
                return IconButton(
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? AppColors.accent : AppColors.textMedium,
                    size: 22,
                  ),
                  onPressed: () {
                    if (_userId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Faça login para favoritar livros.'),
                        ),
                      );
                      return;
                    }
                    favVm.toggleFavorite(_userId, book.id);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

