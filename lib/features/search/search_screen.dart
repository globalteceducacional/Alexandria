import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/layout/app_content_layout.dart';
import '../../core/models/author.dart';
import '../../core/models/category.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/horizontal_scrollbar_list.dart';
import '../../features/auth/auth_view_model.dart';
import '../../features/home/home_view_model.dart';
import '../../routes/app_routes.dart';
import 'widgets/search_results_sections.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  bool _isSearchOpen = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _search(String text) {
    final user = context.read<AuthViewModel>().user;
    context.read<HomeViewModel>().search(text, acervoId: user?.acervoId);
  }

  void _onSearchChanged(String value) {
    if (value.trim().isNotEmpty) {
      _search(value);
      return;
    }
    context.read<HomeViewModel>().clearSearch();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
    });
    if (!_isSearchOpen) {
      _ctrl.clear();
      context.read<HomeViewModel>().clearSearch();
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isSearchOpen ? 'Buscar livros' : 'Explorar',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      centerTitle: true,
      bottom: _isSearchOpen
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título, autor ou movimento',
                    hintStyle: TextStyle(color: Colors.white.withAlpha(140)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withAlpha(180),
                    ),
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white.withAlpha(180),
                            ),
                            onPressed: () {
                              _ctrl.clear();
                              setState(() {});
                              context.read<HomeViewModel>().clearSearch();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withAlpha(25),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.accent.withAlpha(120),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _onSearchChanged(value);
                  },
                ),
              ),
            )
          : null,
      actions: [
        IconButton(
          icon: Icon(_isSearchOpen ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveSearch = _isSearchOpen && _ctrl.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<HomeViewModel>(
        builder: (_, vm, __) {
          if (hasActiveSearch && vm.isSearching) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (!hasActiveSearch) {
            return _ExploreContent(categories: vm.categories, vm: vm);
          }

          if (vm.searchResults.isEmpty && vm.searchAuthorResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum livro encontrado para\n"${_ctrl.text}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMedium),
                  ),
                ],
              ),
            );
          }

          return AppConstrainedContent(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                24,
              ),
              children: [
                SearchResultsSections(
                  query: _ctrl.text,
                  books: vm.searchResults,
                  authors: vm.searchAuthorResults,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Conteúdo do Explorar (sem busca ativa) ───────────────────────────────────

class _ExploreContent extends StatelessWidget {
  const _ExploreContent({required this.categories, required this.vm});
  final List<Category> categories;
  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_outlined, size: 80, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'Explore livros e categorias',
              style: TextStyle(color: AppColors.textMedium, fontSize: 15),
            ),
          ],
        ),
      );
    }

    // Autores vindos da API dedicada
    final authors = vm.authors;

    return AppConstrainedContent(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          20,
          AppSpacing.screenHorizontal,
          32,
        ),
        children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Gêneros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        _GenresGrid(categories: categories),

        if (authors.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 24, bottom: 12),
            child: Text(
              'Autores',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          _AuthorsRow(authors: authors),
        ],
        ],
      ),
    );
  }
}

// ─── Gêneros: carrossel horizontal com cards ─────────────────────────────────

class _GenresGrid extends StatelessWidget {
  const _GenresGrid({required this.categories});
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    final orientation = MediaQuery.of(context).orientation;

    // Em retrato (celular em pé) usamos o layout
    // original: carrossel horizontal com páginas 2x2.
    if (orientation == Orientation.portrait) {
      final List<List<Category>> pages = <List<Category>>[];
      for (var i = 0; i < categories.length; i += 4) {
        final end = i + 4 > categories.length ? categories.length : i + 4;
        pages.add(categories.sublist(i, end));
      }

      const peekWidth = 40.0;

      return LayoutBuilder(
        builder: (context, constraints) {
          final pageWidth = constraints.maxWidth - peekWidth;

          return HorizontalScrollbarList(
            height: 340,
            padding: const EdgeInsets.only(right: 4),
            itemCount: pages.length,
            itemBuilder: (context, pageIndex) {
              final pageCategories = pages[pageIndex];
              return Padding(
                padding: EdgeInsets.only(
                  right: pageIndex == pages.length - 1 ? 0 : 16,
                ),
                child: SizedBox(
                  width: pageWidth,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: pageCategories.length,
                    itemBuilder: (context, index) {
                      final cat = pageCategories[index];
                      return _GenreCard(category: cat);
                    },
                  ),
                ),
              );
            },
          );
        },
      );
    }

    // Em paisagem/tablet usamos o grid responsivo atual.
    return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = width >= 1200
              ? 4
              : width >= 800
                  ? 3
                  : 2;
          final spacing = 12.0;
          final cardWidth =
              (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;
          final targetHeight = width >= 800 ? 170.0 : 160.0;
          final childAspectRatio = cardWidth / targetHeight;

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _GenreCard(category: cat);
            },
          );
        },
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.categoryBooks,
        arguments: category,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5EDE0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _categoryImage(category)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.white.withAlpha(180),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryImage(Category cat) {
    final url = cat.imageThumbUrl.isNotEmpty ? cat.imageThumbUrl : cat.imageUrl;
    if (url.isEmpty) {
      return Container(
        color: AppColors.primaryDark.withAlpha(12),
        alignment: Alignment.center,
        child: Icon(
          Icons.category_outlined,
          size: 48,
          color: AppColors.primaryDark.withAlpha(80),
        ),
      );
    }
    return SizedBox.expand(
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Container(
          color: AppColors.primaryDark.withAlpha(12),
          alignment: Alignment.center,
          child: Icon(
            Icons.category_outlined,
            size: 48,
            color: AppColors.primaryDark.withAlpha(80),
          ),
        ),
      ),
    );
  }
}

// ─── Autores (carrossel horizontal circular) ──────────────────────────────────

class _AuthorsRow extends StatelessWidget {
  const _AuthorsRow({required this.authors});
  final List<Author> authors;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 800;
    final avatarRadius = isWide ? 42.0 : 35.0;
    final containerHeight = isWide ? 130.0 : 110.0;
    final nameFontSize = isWide ? 12.0 : 11.0;

    return HorizontalScrollbarList(
      height: containerHeight,
      padding: const EdgeInsets.only(right: 4),
      itemCount: authors.length,
      itemBuilder: (_, i) {
        final author = authors[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.authorDetail,
              arguments: author,
            ),
            child: SizedBox(
              width: isWide ? 90 : 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: AppColors.primaryDark.withAlpha(25),
                    backgroundImage: author.imageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(author.imageUrl)
                        : null,
                    child: author.imageUrl.isEmpty
                        ? Text(
                            author.name.isNotEmpty
                                ? author.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: isWide ? 24 : 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    author.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
