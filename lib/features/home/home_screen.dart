import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/author.dart';
import '../../core/models/book.dart';
import '../../core/models/home_section.dart';
import '../../core/layout/app_content_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/html_decode.dart';
import '../../core/widgets/horizontal_scrollbar_list.dart';
import '../../features/auth/auth_view_model.dart';
import '../../features/search/widgets/search_results_sections.dart';
import '../../routes/app_routes.dart';
import 'home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      context.read<HomeViewModel>().loadHome(
            acervoId: user?.acervoId,
            userId: user?.id.toString(),
          );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final vm = context.read<HomeViewModel>();
    final user = context.read<AuthViewModel>().user;
    if (value.trim().isNotEmpty) {
      vm.search(value, acervoId: user?.acervoId);
      return;
    }
    if (value.isEmpty) {
      vm.clearSearch();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
    });
    if (!_isSearchOpen) {
      _searchCtrl.clear();
      context.read<HomeViewModel>().clearSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.homeData == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (vm.error != null && vm.homeData == null && vm.sections.isEmpty) {
            return _ErrorView(
              message: vm.error!,
              onRetry: () {
                final user = context.read<AuthViewModel>().user;
                vm.loadHome(
                  acervoId: user?.acervoId,
                  userId: user?.id.toString(),
                );
              },
            );
          }
          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () {
              final user = context.read<AuthViewModel>().user;
              return vm.loadHome(
                acervoId: user?.acervoId,
                userId: user?.id.toString(),
              );
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentMaxWidth =
                    AppLayout.contentMaxWidth(constraints.maxWidth);
                return CustomScrollView(
                  slivers: _buildSlivers(
                    context: context,
                    vm: vm,
                    contentMaxWidth: contentMaxWidth,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSlivers({
    required BuildContext context,
    required HomeViewModel vm,
    required double contentMaxWidth,
  }) {
    final hasActiveSearch = _isSearchOpen && _searchCtrl.text.isNotEmpty;
    return [
      _buildAppBar(context),
      if (hasActiveSearch)
        ..._buildSearchSlivers(vm, contentMaxWidth)
      else ...[
        if (vm.featuredRandomBooks.isNotEmpty)
          SliverToBoxAdapter(
            child: AppConstrainedContent(
              maxWidth: contentMaxWidth,
              child: _FeaturedCarousel(
                books: vm.featuredRandomBooks,
              ),
            ),
          ),
        if (vm.continueReadingBooks.isNotEmpty)
          SliverToBoxAdapter(
            child: AppConstrainedContent(
              maxWidth: contentMaxWidth,
              child: _ContinueReadingCard(
                books: vm.continueReadingBooks,
              ),
            ),
          ),
        for (final section in vm.sections)
          SliverToBoxAdapter(
            child: AppConstrainedContent(
              maxWidth: contentMaxWidth,
              child: _SectionBooks(section: section),
            ),
          ),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
    ];
  }

  List<Widget> _buildSearchSlivers(HomeViewModel vm, double contentMaxWidth) {
    if (vm.isSearching) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      ];
    }

    if (vm.searchResults.isEmpty && vm.searchAuthorResults.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Nenhum livro encontrado para "${_searchCtrl.text}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: AppConstrainedContent(
          maxWidth: contentMaxWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: SearchResultsSections(
              query: _searchCtrl.text,
              books: vm.searchResults,
              authors: vm.searchAuthorResults,
            ),
          ),
        ),
      ),
    ];
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      title: Text(
        _isSearchOpen ? 'Buscar livros' : 'Destaque',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      bottom: _isSearchOpen
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título, autor ou movimento',
                    hintStyle: TextStyle(color: Colors.white.withAlpha(140)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withAlpha(180),
                    ),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white.withAlpha(180),
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
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
}

// ─── Carrossel de destaque ────────────────────────────────────────────────────

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.books});
  final List<Book> books;

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.value = 1;
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.books.length <= 1) return;
    _autoPlayTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _goNext(),
    );
  }

  Future<void> _animateToIndex(int newIndex) async {
    if (!mounted || newIndex == _current) return;
    _autoPlayTimer?.cancel();
    try {
      await _fadeController.reverse();
      if (!mounted) return;
      setState(() {
        _current = newIndex;
      });
      await _fadeController.forward();
    } finally {
      if (mounted) {
        _startAutoPlay();
      }
    }
  }

  void _goPrev() {
    if (_current <= 0) return;
    _animateToIndex(_current - 1);
  }

  void _goNext() {
    if (widget.books.isEmpty) return;
    final isLast = _current >= widget.books.length - 1;
    final nextIndex = isLast ? 0 : _current + 1;
    _animateToIndex(nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              if (widget.books.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _FeaturedBannerCard(
                    book: widget.books[_current],
                  ),
                ),
              if (widget.books.length > 1)
                Positioned(
                  left: AppSpacing.screenHorizontal,
                  top: 0,
                  bottom: 0,
                  child: _CarouselArrow(
                    direction: AxisDirection.left,
                    enabled: _current > 0,
                    onTap: _current > 0 ? _goPrev : null,
                  ),
                ),
              if (widget.books.length > 1)
                Positioned(
                  right: AppSpacing.screenHorizontal,
                  top: 0,
                  bottom: 0,
                  child: _CarouselArrow(
                    direction: AxisDirection.right,
                    enabled: _current < widget.books.length - 1,
                    onTap: _current < widget.books.length - 1 ? _goNext : null,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.books.length, (i) {
            final selected = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: selected ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent
                    : AppColors.textLight.withAlpha(140),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FeaturedBannerCard extends StatelessWidget {
  const _FeaturedBannerCard({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    // Tenta usar a imagem do autor vinda do HomeViewModel (author_list)
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
      // Mantém fallback para book.authorImageUrl
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.bookDetail,
        arguments: book,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: 8,
        ),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.primaryDark,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Fundo com gradiente base
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary.withAlpha(200),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Imagem do autor ao fundo, semi-transparente
            if (authorBg.isNotEmpty)
              Positioned(
                right: -20,
                top: -10,
                bottom: -10,
                width: 200,
                child: Opacity(
                  opacity: 0.15,
                  child: CachedNetworkImage(
                    imageUrl: authorBg,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            Row(
              children: [
                // Capa do livro
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 100,
                      height: 148,
                      child: CachedNetworkImage(
                        imageUrl: book.coverImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: Colors.white.withAlpha(20),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.white.withAlpha(20),
                          child: const Icon(
                            Icons.book,
                            size: 40,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Informações
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (book.authorName.isNotEmpty)
                          Text(
                            book.authorName,
                            style: TextStyle(
                              color: Colors.white.withAlpha(180),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 6),
                        Text(
                          book.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        if (book.description.isNotEmpty)
                          Text(
                            cleanHtmlText(book.description),
                            style: TextStyle(
                              color: Colors.white.withAlpha(210),
                              fontSize: 12,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const Spacer(),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.bookDetail,
                              arguments: book,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Ler Agora',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Botão de seta do carrossel ───────────────────────────────────────────────

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({
    required this.direction,
    required this.enabled,
    required this.onTap,
  });

  final AxisDirection direction;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = direction == AxisDirection.left
        ? Icons.chevron_left
        : Icons.chevron_right;
    return Center(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(enabled ? 190 : 60),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.primaryDark : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}

// ─── Continuar Lendo ──────────────────────────────────────────────────────────

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.books});
  final List<Book> books;

  /// Largura ideal para exibir até 5 cartões; em telas estreitas mantém mínimo e rola.
  static const _gap = 12.0;
  static const _targetSlots = 5;
  static const _minCardWidth = 200.0;

  /// Altura fixa do cartão na faixa horizontal (capa + texto + progresso + botão).
  static const _stripHeight = 196.0;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        20,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Continuar Lendo'),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final slotFromFive =
                  (maxW - (_targetSlots - 1) * _gap) / _targetSlots;
              final cardWidth = math.max(_minCardWidth, slotFromFive);

              return HorizontalScrollbarList(
                height: _stripHeight,
                padding: const EdgeInsets.only(right: 4),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < books.length - 1 ? _gap : 0,
                    ),
                    child: SizedBox(
                      width: cardWidth,
                      child: _ContinueReadingTile(
                        book: books[index],
                        cardWidth: cardWidth,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContinueReadingTile extends StatelessWidget {
  const _ContinueReadingTile({
    required this.book,
    required this.cardWidth,
  });
  final Book book;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final titleSize = cardWidth >= 260 ? 14.0 : 13.0;
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 72,
                      child: CachedNetworkImage(
                        imageUrl: book.coverImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primaryDark.withAlpha(20),
                          child: const Icon(Icons.book, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (book.authorName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            book.authorName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMedium,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final progress =
                    context.read<HomeViewModel>().progressForBook(book.id);
                final fraction = progress?.fraction ?? 0;
                final percent = progress?.percent ?? 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        backgroundColor: AppColors.divider,
                        color: AppColors.accent,
                        minHeight: 4,
                      ),
                    ),
                    if (percent > 0) ...[
                      const SizedBox(height: 3),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.pushNamed(
                    context,
                    AppRoutes.bookReader,
                    arguments: book,
                  );
                  if (context.mounted) {
                    context.read<HomeViewModel>().refreshReadingProgress();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header de seção ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onTap});
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
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

// ─── Seções com livros ────────────────────────────────────────────────────────

class _SectionBooks extends StatelessWidget {
  const _SectionBooks({required this.section});
  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    if (section.books.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        20,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: section.title,
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.homeSectionBooks,
                arguments: section,
              );
            },
          ),
          const SizedBox(height: 12),
          HorizontalScrollbarList(
            height: 230,
            padding: const EdgeInsets.only(right: 4),
            itemCount: section.books.length,
            itemBuilder: (_, i) => BookCard(book: section.books[i]),
          ),
        ],
      ),
    );
  }
}

// ─── Card de livro reutilizável ───────────────────────────────────────────────

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book});
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
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 160,
                child: CachedNetworkImage(
                  imageUrl: book.coverImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(
                    color: AppColors.primaryDark.withAlpha(20),
                    child: const Icon(
                      Icons.book_outlined,
                      size: 36,
                      color: AppColors.textLight,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.primaryDark.withAlpha(20),
                    child: const Icon(
                      Icons.book_outlined,
                      size: 36,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  if (book.authorName.isNotEmpty)
                    Text(
                      book.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        color: AppColors.textMedium,
                      ),
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

// ─── Widget de erro ───────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMedium),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
