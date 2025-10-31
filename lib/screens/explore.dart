import 'package:elearn/generated/l10n.dart';
import 'package:elearn/model/exploreallbook.dart';
import 'package:elearn/model/exploreauthor.dart';
import 'package:elearn/model/explorelatest.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:elearn/widgets/beswtofday.dart';
import 'package:elearn/widgets/cat.dart' as catWidgets;
import 'package:elearn/widgets/richtxt.dart';
import 'package:elearn/widgets/title.dart';
import 'package:elearn/widgets/imageview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../consttants.dart';
import 'allauthor.dart';
import 'details_screen.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  ExploreLatestBook? latestBook;
  ExploreAuthor? bookAuthor;
  ExploreAllBook? allBooks;
  String? searchQuery;
  bool isLimitedList = true;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchData() async {
    allBooks = await HttpService().getExploreAllBooks();
    setState(() {});
  }

  Future<void> latest() async {
    latestBook = await HttpService().getExploreLatestBook();
    bookAuthor = await HttpService().getExploreAuthor();
    allBooks = await HttpService().getExploreAllBooks();
  }

  @override
  void initState() {
    latest().whenComplete(() {
      setState(() {});
    });
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            // Verifica a orientação do dispositivo
            if (orientation == Orientation.portrait) {
              // Configuração para orientação vertical
              return _portraitContent();
            } else {
              // Configuração para orientação horizontal
              return _landscapeContent();
            }
          },
        ),
      ),
    );
  }

  Widget _portraitContent() {
    // Conteúdo para orientação vertical
    return Container(
      color: comboBlackAndWhite(),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Barra de título
            TitleBar(
              image: 'assets/images/web-browser.svg',
              title: S.of(context).explore_EXPLORE,
            ),
            // Campo de pesquisa
            Padding(
              padding: EdgeInsets.all(15.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      isLimitedList = false;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: S.of(context).home_search_bar,
                    hintStyle: TextStyle(color: comboWhiteAndBlack()),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: comboLightGreyAndGrey(),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.search, color: comboWhiteAndBlack()),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ),
            // Lista de sites
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: allBooks != null
                  ? allBooks!.ebookApp
                      .where((book) {
                        return book.bookTitle
                            .toLowerCase()
                            .contains(searchQuery?.toLowerCase() ?? '');
                      })
                      .length
                      .clamp(0, 4)
                  : 0,
              itemBuilder: (context, index) {
                final book = allBooks!.ebookApp.where((book) {
                  return book.bookTitle
                      .toLowerCase()
                      .contains(searchQuery?.toLowerCase() ?? '');
                }).elementAt(index);
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 5.h),
                  child: BestOfTheDayVertical(
                    index: index,
                    image: book.bookCoverImg,
                    authorDescription: book.authorDescription,
                    bookTitle: book.bookTitle,
                    fileUrl: book.bookFileUrl,
                    bookDescription: book.bookDescription,
                    authorName: book.authorName,
                    rate: book.rateAvg,
                    catId: int.parse(book.id),
                  ),
                );
              },
            ),
            // Título "Últimos sites"
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 20.w),
              child: CustomRichText(
                context: context,
                txt1: "${S.of(context).explore_LATEST} ",
                txt2: S.of(context).explore_BOOKS,
                fontsize1: 26.sp,
                fontsize2: 26.sp,
              ),
            ),
            // Lista de últimos sites
            if (latestBook != null)
              Container(
                height: MediaQuery.of(context).size.height * 0.28,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: latestBook!.ebookApp.length,
                    itemBuilder: (context, index) {
                      return LatestBookViewVertical(
                        bookDescription:
                            latestBook!.ebookApp[index].bookDescription,
                        authorDescription:
                            latestBook!.ebookApp[index].authorDescription,
                        bookImage: latestBook!.ebookApp[index].bookCoverImg,
                        authorName: latestBook!.ebookApp[index].authorName,
                        bookTitle: latestBook!.ebookApp[index].bookTitle,
                        id: int.parse(latestBook!.ebookApp[index].id),
                        rating: latestBook!.ebookApp[index].rateAvg,
                      );
                    }),
              ),
            // Título "Desenvolvedores"
            Padding(
              padding: EdgeInsets.only(top: 10.h, left: 15.w, right: 15.w),
              child: Row(children: [
                CustomRichText(
                  context: context,
                  txt1: "",
                  txt2: S.of(context).explore_AUTHOR,
                  fontsize1: 26.sp,
                  fontsize2: 26.sp,
                ),
                Spacer(),
                if (bookAuthor != null)
                  GestureDetector(
                      onTap: () {
                        Get.to(() => AllAuthors(bookAuthor: bookAuthor));
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          S.of(context).home_SeeAll,
                          style: TextStyle(
                            fontFamily: "Gilroy-SemiBold",
                            color: comboWhiteAndBlack(),
                            fontSize: 30,
                          ),
                        ),
                      )),
              ]),
            ),
            // Lista de Desenvolvedores
            if (bookAuthor != null)
              Container(
                height: 280.h,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bookAuthor!.ebookApp.length,
                    itemBuilder: (context, index) {
                      return AuthorView(
                        authorName: bookAuthor!.ebookApp[index].authorName,
                        authorImage: bookAuthor!.ebookApp[index].authorImage,
                        authid: int.parse(bookAuthor!.ebookApp[index].authorId),
                        authorDescription:
                            bookAuthor!.ebookApp[index].authorDescription,
                      );
                    }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _landscapeContent() {
    // Conteúdo para orientação horizontal
    return Container(
        color: comboBlackAndWhite(),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
            child: Column(children: [
          // Barra de título
          TitleBar(
            image: 'assets/images/web-browser.svg',
            title: S.of(context).explore_EXPLORE,
          ),
          // Campo de pesquisa
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(1, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    isLimitedList = false;
                  });
                },
                decoration: InputDecoration(
                  hintText: S.of(context).home_search_bar,
                  hintStyle: TextStyle(color: comboWhiteAndBlack()),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: comboLightGreyAndGrey(),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search, color: comboWhiteAndBlack()),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 50.h),
                ),
              ),
            ),
          ),
          // Lista de sites
          Container(
            height: 300.h, // Reduced height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allBooks != null
                  ? allBooks!.ebookApp
                      .where((book) {
                        return book.bookTitle
                            .toLowerCase()
                            .contains(searchQuery?.toLowerCase() ?? '');
                      })
                      .length
                      .clamp(0, 4)
                  : 0,
              itemBuilder: (context, index) {
                final book = allBooks!.ebookApp.where((book) {
                  return book.bookTitle
                      .toLowerCase()
                      .contains(searchQuery?.toLowerCase() ?? '');
                }).elementAt(index);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0.w),
                  child: BestOfTheDayHorizontal(
                    index: index,
                    image: book.bookCoverImg,
                    authorDescription: book.authorDescription,
                    bookTitle: book.bookTitle,
                    fileUrl: book.bookFileUrl,
                    bookDescription: book.bookDescription,
                    authorName: book.authorName,
                    rate: book.rateAvg,
                    catId: int.parse(book.id),
                  ),
                );
              },
            ),
          ),
          // Título "Últimos sites"
          Padding(
            padding: EdgeInsets.symmetric(vertical: 18.0.h, horizontal: 10.w),
            child: CustomRichText(
              context: context,
              txt1: "${S.of(context).explore_LATEST} ",
              fontsize1: 15.sp,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 10.w),
            child: CustomRichText(
              context: context,
              txt2: S.of(context).explore_BOOKS,
              fontsize2: 15.sp,
            ),
          ),
          // Lista de últimos sites
          if (latestBook != null)
            Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: latestBook!.ebookApp.length,
                  itemBuilder: (context, index) {
                    return LatestBookViewhorizontal(
                      bookDescription:
                          latestBook!.ebookApp[index].bookDescription,
                      authorDescription:
                          latestBook!.ebookApp[index].authorDescription,
                      bookImage: latestBook!.ebookApp[index].bookCoverImg,
                      authorName: latestBook!.ebookApp[index].authorName,
                      bookTitle: latestBook!.ebookApp[index].bookTitle,
                      id: int.parse(latestBook!.ebookApp[index].id),
                      rating: latestBook!.ebookApp[index].rateAvg,
                    );
                  }),
            ),
          // Título "Autores"
          Padding(
            padding: EdgeInsets.only(top: 5.h, left: 15.w, right: 15.w),
            child: Row(children: [
              CustomRichText(
                context: context,
                txt1: "",
                txt2: S.of(context).explore_AUTHOR,
                fontsize1: 26.sp,
                fontsize2: 26.sp,
              ),
              Spacer(),
              if (bookAuthor != null)
                GestureDetector(
                    onTap: () {
                      Get.to(() => AllAuthors(bookAuthor: bookAuthor));
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        S.of(context).home_SeeAll,
                        style: TextStyle(
                          fontFamily: "Gilroy-SemiBold",
                          color: comboWhiteAndBlack(),
                          fontSize: 30,
                        ),
                      ),
                    )),
            ]),
          ),
          // Lista de Desenvolvedores
          if (bookAuthor != null)
            Container(
              height: 600.h,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bookAuthor!.ebookApp.length,
                  itemBuilder: (context, index) {
                    return AuthorView(
                      authorName: bookAuthor!.ebookApp[index].authorName,
                      authorImage: bookAuthor!.ebookApp[index].authorImage,
                      authid: int.parse(bookAuthor!.ebookApp[index].authorId),
                      authorDescription:
                          bookAuthor!.ebookApp[index].authorDescription,
                    );
                  }),
            ),
        ])));
  }
}

class LatestBookViewVertical extends StatelessWidget {
  LatestBookViewVertical(
      {required this.bookImage,
      required this.authorName,
      required this.bookTitle,
      required this.id,
      required this.rating,
      required this.bookDescription,
      required this.authorDescription});

  final String bookDescription;
  final String authorDescription;
  final String bookImage;
  final String bookTitle;
  final String authorName;
  final int id;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() {
          return DetailsScreen(
            authorName: authorName,
            authorDescription: authorDescription,
            bookCoverImg: bookImage,
            bookTitle: bookTitle,
            bookDescription: bookDescription,
            id: id,
            rating: rating,
          );
        });
      },
      child: Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: Column(
          children: [
            Container(
              child: Imageview(
                image: bookImage,
                width: 120.r, // Reduced width
                height: 180.r, // Reduced height

                radius: 10.r,
              ),
            ),
            Container(
              width: 100.r,
              margin: EdgeInsets.only(top: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$bookTitle",
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      decorationStyle: TextDecorationStyle.dotted,
                      fontSize: 10.sp, // Reduced font size
                      color: comboWhiteAndBlack(),
                      fontFamily: "Gilroy-Bold",
                    ),
                  ),
                  Text("$authorName",
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: comboWhiteAndBlack(),
                          fontSize: 7.sp, // Reduced font size
                          fontFamily: "Gilroy-Medium"))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LatestBookViewhorizontal extends StatelessWidget {
  LatestBookViewhorizontal(
      {required this.bookImage,
      required this.authorName,
      required this.bookTitle,
      required this.id,
      required this.rating,
      required this.bookDescription,
      required this.authorDescription});

  final String bookDescription;
  final String authorDescription;
  final String bookImage;
  final String bookTitle;
  final String authorName;
  final int id;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() {
          return DetailsScreen(
            authorName: authorName,
            authorDescription: authorDescription,
            bookCoverImg: bookImage,
            bookTitle: bookTitle,
            bookDescription: bookDescription,
            id: id,
            rating: rating,
          );
        });
      },
      child: Padding(
        padding: EdgeInsets.only(right: 4.w),
        child: Column(
          children: [
            Container(
              child: Imageview(
                image: bookImage,
                width: 400.r, // Reduced width
                height: 400.r, // Reduced height
                radius: 5.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthorView extends StatelessWidget {
  AuthorView(
      {required this.authorImage,
      required this.authorName,
      required this.authid,
      required this.authorDescription});

  final int authid;
  final String authorImage;
  final String authorName;
  final String authorDescription;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      height: 240.h,
      child: GestureDetector(
        onTap: () {
          Get.to(() {
            return catWidgets.SingleAuthorView(
              title: authorName,
              catId: authid,
              id: authid,
              name: authorName,
              image: authorImage,
              authorDescription: authorDescription,
            );
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 120.w,
              width: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: comboWhiteAndBlack().withAlpha(51),
                  width: 2.w,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60.w),
                child: Imageview(
                  image: authorImage,
                  height: 120.w,
                  width: 120.w,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Container(
                width: 120.w,
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Text(
                  "$authorName",
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: comboWhiteAndBlack(),
                    fontFamily: "Gilroy-Bold",
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
