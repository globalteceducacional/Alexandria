import 'package:elearn/model/allcategory.dart';
import 'package:elearn/model/besthomebook.dart';
import 'package:elearn/screens/bottom_navigation.dart';
import 'package:elearn/screens/category.dart';
import 'package:elearn/screens/details_screen.dart';
import 'package:elearn/screens/explore.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:elearn/widgets/safe_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../consttants.dart';
import '../databasefavourite/db.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final RxList<Book> featuredBooks = <Book>[].obs;
  final RxList<Book> popularBooks = <Book>[].obs;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    try {
      final response =
          await http.get(Uri.parse('$apiLink/api.php?method_name=home'));
      if (response.statusCode == 200) {
        final data = bestHomeBookFromJson(response.body);
        featuredBooks.value = data.ebookApp.featuredBooks;
        popularBooks.value = data.ebookApp.popularBooks;
      }
    } catch (e) {
      debugPrint('Home load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: RefreshIndicator(
          color: kNavy,
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: _FeaturedBanner(books: featuredBooks),
              ),
              const SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Trilhas Literárias',
                  showArrow: true,
                ),
              ),
              const SliverToBoxAdapter(child: _CategoryRow()),
              const SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Continuar Lendo',
                  showArrow: false,
                ),
              ),
              const SliverToBoxAdapter(child: _ContinueReadingRow()),
              const SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Populares',
                  showArrow: true,
                ),
              ),
              SliverToBoxAdapter(
                child: _BookRow(books: popularBooks),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: kNavy,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'Destaque',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Gilroy-Bold',
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => Get.to(() => const Explore()),
        ),
      ],
    );
  }
}

// ─── Navigate to details helper ───────────────────────────────────────────────

void _goToDetails(Book b) {
  Get.to(() => DetailsScreen(
        id: int.tryParse(b.id) ?? 0,
        bookTitle: b.bookTitle,
        bookDescription: b.bookDescription,
        bookCoverImg: b.bookCoverImg,
        authorName: b.authorName,
        authorDescription: b.authorDescription,
        rating: b.rateAvg,
      ));
}

// ─── Featured Banner ─────────────────────────────────────────────────────────

class _FeaturedBanner extends StatefulWidget {
  final RxList<Book> books;
  const _FeaturedBanner({required this.books});

  @override
  State<_FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<_FeaturedBanner> {
  int _current = 0;
  late PageController _ctrl;

  @override
  void initState() {
    _ctrl = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.books.isEmpty) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFFE0D8CC),
          highlightColor: kCream,
          child: Container(
            height: 200.h,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
      return Column(
        children: [
          SizedBox(
            height: 200.h,
            child: PageView.builder(
              controller: _ctrl,
              itemCount: widget.books.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => _FeaturedCard(book: widget.books[i]),
            ),
          ),
          const SizedBox(height: 8),
          _DotsIndicator(count: widget.books.length, current: _current),
          const SizedBox(height: 4),
        ],
      );
    });
  }
}

class _FeaturedCard extends StatelessWidget {
  final Book book;
  const _FeaturedCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _goToDetails(book),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: kNavy,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: SafeBookCoverWidget(
                  imageUrl: book.bookBgImg?.toString() ?? book.bookCoverImg,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xDD1A2744),
                        Color(0x881A2744),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SafeBookCoverWidget(
                        imageUrl: book.bookCoverImg,
                        width: 80,
                        height: 110,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            book.authorName,
                            style: const TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 12,
                              fontFamily: 'Gilroy-SemiBold',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book.bookTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Gilroy-Bold',
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () => _goToDetails(book),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAmber,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0,
                            ),
                            child: const Text(
                              'Ler Agora',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Gilroy-SemiBold',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == current ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == current ? kNavy : const Color(0xFFCCCCCC),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showArrow;
  const _SectionHeader({required this.title, required this.showArrow});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontFamily: 'Gilroy-Bold',
              color: kNavy,
            ),
          ),
          if (showArrow)
            const Icon(Icons.chevron_right, color: kNavy, size: 22),
        ],
      ),
    );
  }
}

// ─── Category Row ─────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125.h,
      child: FutureBuilder<AllCategory?>(
        future: HttpService().getAllCategory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _shimmerRow();
          }
          final cats = snapshot.data!.ebookApp;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final cat = cats[i];
              return GestureDetector(
                onTap: () => Get.to(() => NewCategoryScreen(
                      catId: int.tryParse(cat.cid) ?? 0,
                      categoryName: cat.categoryName,
                    )),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 88.w,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            SafeCategoryImageWidget(
                              imageUrl: cat.categoryImage,
                              width: 88.w,
                              height: 88.w,
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0x881A2744),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        cat.categoryName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'Gilroy-SemiBold',
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _shimmerRow() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE0D8CC),
        highlightColor: kCream,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ─── Continue Reading Row ─────────────────────────────────────────────────────

class _ContinueReadingRow extends StatelessWidget {
  const _ContinueReadingRow();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.retrieveDownLoad(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.menu_book_outlined,
                      color: Color(0xFFCCCCCC), size: 32),
                  SizedBox(width: 14),
                  Text(
                    'Nenhum livro em andamento',
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontFamily: 'Gilroy-SemiBold',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 110.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: snapshot.data!.length,
            itemBuilder: (_, i) {
              final b = snapshot.data![i];
              return _ContinueReadingCard(
                title: b['title'] as String? ?? 'Livro',
                image: b['image'] as String? ?? '',
              );
            },
          ),
        );
      },
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final String title;
  final String image;
  const _ContinueReadingCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 290.w,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SafeBookCoverWidget(
              imageUrl: image,
              width: 58,
              height: 80,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    fontSize: 14,
                    color: kNavy,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.4,
                  backgroundColor: const Color(0xFFE8E8E8),
                  valueColor: const AlwaysStoppedAnimation<Color>(kAmber),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              elevation: 0,
            ),
            child: const Text(
              'Continuar',
              style: TextStyle(fontSize: 11, fontFamily: 'Gilroy-SemiBold'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Book Row (Populares) ─────────────────────────────────────────────────────

class _BookRow extends StatelessWidget {
  final RxList<Book> books;
  const _BookRow({required this.books});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (books.isEmpty) {
        return SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 5,
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: const Color(0xFFE0D8CC),
              highlightColor: kCream,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 110,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        );
      }
      return SizedBox(
        height: 175.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: books.length,
          itemBuilder: (_, i) {
            final b = books[i];
            return GestureDetector(
              onTap: () => _goToDetails(b),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 110.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SafeBookCoverWidget(
                        imageUrl: b.bookCoverImg,
                        width: 110.w,
                        height: 145.h,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      b.bookTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Gilroy-SemiBold',
                        color: kNavy,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
