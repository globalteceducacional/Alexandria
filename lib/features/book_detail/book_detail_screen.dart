import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/layout/app_content_layout.dart';
import '../../core/models/author.dart';
import '../../core/models/book.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/html_decode.dart';
import '../../core/widgets/horizontal_scrollbar_list.dart';
import '../../features/auth/auth_view_model.dart';
import '../../features/favorites/favorite_view_model.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/home_view_model.dart';
import '../../features/wishlist/wishlist_view_model.dart';
import '../../routes/app_routes.dart';
import 'book_detail_view_model.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.book});
  final Book book;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late final BookDetailViewModel _vm;
  late final String _userId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthViewModel>();
    final apiClient = context.read<HomeViewModel>().api;
    _userId = auth.user?.id.toString() ?? '';
    _vm = BookDetailViewModel(
      apiClient,
      userId: auth.user?.id.toString() ?? '',
    );
    _vm.load(widget.book.id);
    context.read<FavoriteViewModel>().ensureLoaded(_userId);
    context.read<WishlistViewModel>().ensureLoaded(_userId);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<BookDetailViewModel>(
        builder: (_, vm, __) {
          final book = vm.book ?? widget.book;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                _buildHeroBanner(context, book),
                SliverToBoxAdapter(
                  child: AppConstrainedContent(
                    child: _buildBody(context, book),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Banner no topo ─────────────────────────────────────────────────────────

  SliverAppBar _buildHeroBanner(BuildContext context, Book book) {
    // Tenta obter a imagem do autor a partir do HomeViewModel,
    // caindo para o authorImageUrl do próprio livro.
    String authorBg = book.authorImageUrl;
    try {
      final homeVm = context.read<HomeViewModel>();
      Author? author;
      if (book.authorId.isNotEmpty) {
        author = homeVm.authors
            .firstWhere((a) => a.id == book.authorId, orElse: () => author!);
      }
      author ??= homeVm.authors.firstWhere(
        (a) => a.name.toLowerCase() == book.authorName.toLowerCase(),
        orElse: () => author!,
      );
      if (author.imageUrl.isNotEmpty) {
        authorBg = author.imageUrl;
      }
    } catch (_) {
      // mantém fallback
    }

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Fundo escuro com gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary.withAlpha(220),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Imagem do autor ao fundo, semi-transparente
            if (authorBg.isNotEmpty)
              Positioned(
                right: -40,
                top: -20,
                bottom: -20,
                width: 260,
                child: Opacity(
                  opacity: 0.18,
                  child: CachedNetworkImage(
                    imageUrl: authorBg,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            // Conteúdo: capa + info
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Capa
                    Hero(
                      tag: 'book-cover-${book.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 110,
                          height: 160,
                          child: CachedNetworkImage(
                            imageUrl: book.coverImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.white.withAlpha(15),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.white.withAlpha(15),
                              child: const Icon(
                                Icons.book,
                                size: 48,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Título, autor e avaliação ao lado da capa
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (book.authorName.isNotEmpty)
                            Text(
                              'De ${book.authorName}',
                              style: TextStyle(
                                color: Colors.white.withAlpha(210),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            book.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Corpo ──────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, Book book) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ações (Ler, Ler mais tarde, Favoritar)
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Ler',
                  color: AppColors.accent,
                  onTap: () => _openBook(context, book),
                ),
              ),
              const SizedBox(width: 8),
              Consumer<WishlistViewModel>(
                builder: (_, wishVm, __) {
                  final inWishlist = wishVm.isInWishlist(_userId, book.id);
                  return Expanded(
                    child: _actionButton(
                      icon: inWishlist
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      label: inWishlist ? 'Na lista' : 'Ler Depois',
                      color: inWishlist ? AppColors.accent : AppColors.primaryDark,
                      onTap: () {
                        if (_userId.isEmpty) {
                          _showSnack(
                            context,
                            'Faça login para adicionar à lista Ler Depois.',
                          );
                          return;
                        }
                        wishVm.toggle(_userId, book.id);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Consumer<FavoriteViewModel>(
                builder: (_, favVm, __) {
                  final isFav = favVm.isFavorite(_userId, book.id);
                  return Expanded(
                    child: _actionButton(
                      icon: isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      label: isFav ? 'Favorito' : 'Favoritar',
                      color: isFav ? AppColors.accent : AppColors.primaryDark,
                      onTap: () {
                        if (_userId.isEmpty) {
                          _showSnack(
                            context,
                            'Faça login para favoritar livros.',
                          );
                          return;
                        }
                        favVm.toggleFavorite(_userId, book.id);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sinopse
          const Text(
            'Sinopse',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            book.description.isEmpty
                ? 'Sem descrição disponível.'
                : cleanHtmlText(book.description),
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 24),

          // Sobre o Autor (card clicável)
          if (book.authorName.isNotEmpty) ...[
            const Text(
              'Sobre o autor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            _AuthorInfoCard(
              book: book,
              onTap: () => _openAuthor(context, book),
            ),
            const SizedBox(height: 24),
          ],

          // Livros relacionados
          if (book.relatedBooks.isNotEmpty) ...[
            const Text(
              'Livros relacionados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            HorizontalScrollbarList(
              height: 230,
              padding: EdgeInsets.zero,
              itemCount: book.relatedBooks.length,
              itemBuilder: (_, i) => BookCard(book: book.relatedBooks[i]),
            ),
            const SizedBox(height: 24),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _openBook(BuildContext context, Book book) async {
    if (book.resolvedFileUrl.isEmpty) {
      _showSnack(context, 'Este livro ainda não possui arquivo.');
      return;
    }

    final user = context.read<AuthViewModel>().user;
    if (user != null) {
      await _vm.saveContinueReading(user.id.toString(), book.id);
    }

    await Navigator.pushNamed(
      // ignore: use_build_context_synchronously
      context,
      AppRoutes.bookReader,
      arguments: book,
    );
    if (context.mounted) {
      context.read<HomeViewModel>().refreshReadingProgress();
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Botão de ação principal com ícone + texto
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(120), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAuthor(BuildContext context, Book book) {
    if (book.authorId.isEmpty && book.authorName.isEmpty) return;

    // Tenta reaproveitar o autor carregado no HomeViewModel (vem da API author_list)
    Author? author;
    try {
      final homeVm = context.read<HomeViewModel>();
      author = homeVm.authors.firstWhere(
        (a) => a.id == book.authorId && a.id.isNotEmpty,
        orElse: () => homeVm.authors.firstWhere(
          (a) =>
              a.name.toLowerCase() == book.authorName.toLowerCase() &&
              a.name.isNotEmpty,
        ),
      );
    } catch (_) {
      author = null;
    }

    author ??= Author(
      id: book.authorId,
      name: book.authorName,
      image: book.authorImage,
      description: book.authorDescription,
    );

    Navigator.pushNamed(
      context,
      AppRoutes.authorDetail,
      arguments: author,
    );
  }
}

// ─── Card simples com resumo do autor ────────────────────────────────────────

class _AuthorInfoCard extends StatelessWidget {
  const _AuthorInfoCard({required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final description = cleanHtmlText(book.authorDescription);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.authorName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description.isEmpty
                        ? 'Sem biografia disponível.'
                        : description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMedium,
            ),
          ],
        ),
      ),
    );
  }
}
