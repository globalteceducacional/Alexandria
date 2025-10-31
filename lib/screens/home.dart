import 'package:elearn/generated/l10n.dart';
import 'package:elearn/model/Profile.dart';
import 'package:elearn/model/allcategory.dart';
import 'package:elearn/model/besthomebook.dart';
import 'package:elearn/model/homecategory.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:elearn/widgets/imageview.dart';
import 'package:elearn/widgets/richtxt.dart';
import 'package:elearn/widgets/safe_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Caso esteja usando flutter_screenutil
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../consttants.dart';
import '../model/categoryid.dart';
import '../widgets/title.dart';
import 'category.dart';
import 'details_screen.dart';
import 'griddview.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// Aqui criamos duas listas reativas (do GetX) para armazenar livros:
  RxList<Book> featuredBooks = <Book>[].obs;
  RxList<Book> latestBooks = <Book>[].obs;

  @override
  void initState() {
    /// Ao iniciar, chamamos a função que busca os livros da "home"
    getHomeBooks();
    super.initState();
  }

  /// Função que faz a requisição HTTP para buscar os livros
  Future<BestHomeBook?> getHomeBooks() async {
    try {
      var response =
          await http.get(Uri.parse('$apiLink/api.php?method_name=home'));
      if (response.statusCode == 200) {
        var data = bestHomeBookFromJson(response.body);

        /// Armazenamos os livros mais recentes e em destaque nas RxList
        latestBooks.value = data.ebookApp.latestBooks;
        featuredBooks.value = data.ebookApp.featuredBooks;
        return data;
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      print('Request failed with status:$e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------------------------
    // 1) Verificamos a orientação da tela
    // ------------------------------------------------------------------------------
    final orientation = MediaQuery.of(context).orientation;

    // ------------------------------------------------------------------------------
    // 2) Declaramos variáveis para tamanhos de fontes e dimensões
    //    Depois, ajustamos esses valores dependendo se a tela está
    //    em "portrait" (vertical) ou "landscape" (horizontal).
    // ------------------------------------------------------------------------------
    double greetingFontSize;
    double categoryFontSize;
    double categoryHeight;
    double categoryImageWidth;
    double categoryImageHeight;
    double categoryTitleFontSize;
    double bookContainerHeight;
    double bookContainerWidth;

    // ------------------------------------------------------------------------------
    // 3) Usamos um if/else para definir cada variável manualmente.
    //    Você pode ajustar esses valores à vontade, dependendo do design.
    // ------------------------------------------------------------------------------
    if (orientation == Orientation.portrait) {
      // --------------------------------------------------------------------
      // Caso a orientação seja VERTICAL (Portrait)
      // --------------------------------------------------------------------
      greetingFontSize = 26.sp; // Ex: Fonte do "Olá, convidado"
      categoryFontSize = 20.sp; // Ex: Fonte do "Categoria"
      categoryHeight = 250.h; // Ex: Altura do container de categorias
      categoryImageWidth = 350.w; // Ex: Largura da imagem de cada categoria
      categoryImageHeight = 300.w; // Ex: Altura da imagem de cada categoria
      categoryTitleFontSize = 25.sp; // Ex: Fonte do título da categoria
      bookContainerHeight = 240.r; // Ex: Altura do container de cada livro
      bookContainerWidth = 160.r; // Ex: Largura do container de cada livro
    } else {
      // --------------------------------------------------------------------
      // Caso a orientação seja HORIZONTAL (Landscape)
      // --------------------------------------------------------------------
      greetingFontSize = 22.sp; // Ex: Fonte do "Olá, convidado" menor
      categoryFontSize = 16.sp; // Ex: Fonte do "Categoria" menor
      categoryHeight = 500.h; // Ex: Altura do container de categorias menor
      categoryImageWidth =
          200.w; // Ex: Largura da imagem de cada categoria maior
      categoryImageHeight =
          330.w; // Ex: Altura da imagem de cada categoria maior
      categoryTitleFontSize = 22.sp; // Ex: Fonte do título da categoria menor
      bookContainerHeight =
          400.r; // Ex: Altura do container de cada livro maior
      bookContainerWidth =
          300.r; // Ex: Largura do container de cada livro maior
    }

    // ------------------------------------------------------------------------------
    // 4) Agora que definimos as variáveis, podemos usá-las abaixo
    //    em vez de valores fixos. Assim, tudo muda dependendo da orientação.
    // ------------------------------------------------------------------------------

    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------------------
              // TÍTULO / SAUDAÇÃO
              // ----------------------------------------------------------------
              Padding(
                padding: EdgeInsets.only(top: 18.0.h, left: 15.w, right: 15.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    userId != null
                        ? FutureBuilder<ProfileModel?>(
                            future: HttpService().getUserProfile(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return CustomRichText(
                                  context: context,
                                  fontsize1: greetingFontSize,
                                  fontsize2: greetingFontSize,
                                  txt1: "${S.of(context).home_GREETINGS}\n",
                                  txt2:
                                      "${snapshot.data!.ebookApp[0].name.toTitleCase()}",
                                );
                              } else {
                                return Container(
                                  height: 50,
                                  child: TitleBar(
                                    title: S.of(context).home_Hello,
                                    image: 'assets/images/Home.svg',
                                  ),
                                );
                              }
                            },
                          )
                        : CustomRichText(
                            context: context,
                            fontsize1: greetingFontSize,
                            fontsize2: greetingFontSize,
                            txt1: "${S.of(context).home_GREETINGS}\n",
                            txt2: "Olá, convidado",
                          ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // ----------------------------------------------------------------
              // TÍTULO: "CATEGORIA"
              // ----------------------------------------------------------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: CustomRichText(
                  context: context,
                  fontsize1: categoryFontSize,
                  fontsize2: categoryFontSize,
                  txt2: S.of(context).home_CATEGORY,
                ),
              ),

              // ----------------------------------------------------------------
              // LISTA DE CATEGORIAS
              // ----------------------------------------------------------------
              SizedBox(
                height: categoryHeight,
                child: FutureBuilder<AllCategory?>(
                    future: HttpService().getAllCategory(),
                    builder: (context, snapshot) {
                      // Quando a requisição estiver completa...
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.ebookApp.length,
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => NewCategoryScreen(
                                        catId: int.parse(
                                          snapshot.data!.ebookApp[index].cid,
                                        ),
                                        categoryName: snapshot
                                            .data!.ebookApp[index].categoryName,
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: SafeCategoryImageWidget(
                                          imageUrl: snapshot.data!
                                              .ebookApp[index].categoryImage,
                                          width: categoryImageWidth,
                                          height: categoryImageHeight,
                                        ),
                                      ),
                                      Container(
                                        width: categoryImageWidth,
                                        alignment: Alignment.bottomCenter,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0.r),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.black12,
                                              Colors.black,
                                            ],
                                            begin: Alignment.center,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 15.h),
                                          child: Text(
                                            snapshot.data!.ebookApp[index]
                                                .categoryName,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: categoryTitleFontSize,
                                              fontFamily: "Gilroy-Bold",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          // Caso não tenha dados de categoria
                          return Center(
                            child: Text(S.of(context).search_NO_BOOKS_FOUND),
                          );
                        }
                      } else {
                        // Enquanto carrega, mostra o Shimmer (efeito de carregamento)
                        return Shimmer.fromColors(
                          child: Container(
                            width: categoryImageWidth,
                            height: categoryImageHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            margin: EdgeInsets.all(8.0),
                          ),
                          baseColor: shimmerBaseColor(),
                          highlightColor: shimmerHighlightColor(),
                        );
                      }
                    }),
              ),

              // ----------------------------------------------------------------
              // SEÇÕES DE LIVROS (Blocos horizontais)
              // ----------------------------------------------------------------
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 20.0.h),

                        /// FutureBuilder para buscar as "seções" de livros
                        FutureBuilder<CategoryId?>(
                          future: HttpService().getCatId(),
                          builder: (context, snapshot) {
                            // Quando a requisição de seções estiver completa
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.ebookApp.length,
                                  itemBuilder: (BuildContext context, index) {
                                    return FutureBuilder<CategoryById?>(
                                      future: HttpService().getCategoryById(
                                        bookId:
                                            snapshot.data!.ebookApp[index].id,
                                      ),
                                      builder: (context, bookData) {
                                        // Quando a requisição dos livros de cada seção estiver completa
                                        if (bookData.connectionState ==
                                            ConnectionState.done) {
                                          // Verifica se há livros
                                          if (bookData.hasData &&
                                              bookData.data != null &&
                                              bookData
                                                  .data!.ebookApp.isNotEmpty) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Título da seção e botão "ver tudo"
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 10.r,
                                                    top: 20.r,
                                                    left: 10.r,
                                                    right: 10.r,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                        child: Text(
                                                          '${snapshot.data!.ebookApp[index].sectionTitle}',
                                                          style: TextStyle(
                                                            color:
                                                                comboWhiteAndBlack(),
                                                            fontSize: 18.sp,
                                                            fontFamily:
                                                                'Gilroy-SemiBold',
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          Get.to(
                                                            ViewBookScreen(
                                                              id: snapshot
                                                                  .data!
                                                                  .ebookApp[
                                                                      index]
                                                                  .id,
                                                              title: snapshot
                                                                  .data!
                                                                  .ebookApp[
                                                                      index]
                                                                  .sectionTitle,
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          S
                                                              .of(context)
                                                              .home_SeeAll,
                                                          style: TextStyle(
                                                            color:
                                                                comboWhiteAndBlack(),
                                                            fontFamily:
                                                                "Gilroy-Medium",
                                                            fontSize: 15.sp,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                // Lista horizontal de livros
                                                SizedBox(
                                                  height: bookContainerHeight,
                                                  child: ListView.builder(
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    itemCount: bookData
                                                        .data!.ebookApp.length,
                                                    itemBuilder:
                                                        (context, index222) {
                                                      final book = bookData
                                                          .data!
                                                          .ebookApp[index222];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Get.to(
                                                            () {
                                                              return DetailsScreen(
                                                                authorName: book
                                                                    .authorName,
                                                                authorDescription:
                                                                    book.authorDescription,
                                                                bookCoverImg: book
                                                                    .bookCoverImg,
                                                                bookTitle: book
                                                                    .bookTitle,
                                                                bookDescription:
                                                                    book.bookDescription,
                                                                id: int.parse(
                                                                    book.id),
                                                                rating: book
                                                                    .rateAvg,
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          height:
                                                              bookContainerHeight,
                                                          width:
                                                              bookContainerWidth,
                                                          margin:
                                                              EdgeInsets.all(
                                                                  8.r),
                                                          child: Imageview(
                                                            image: book
                                                                .bookCoverImg,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            // Caso não haja livros na seção
                                            return SizedBox.shrink();
                                          }
                                        } else {
                                          // Enquanto carrega os livros, mostra Shimmer
                                          return Shimmer.fromColors(
                                            baseColor: shimmerBaseColor(),
                                            highlightColor:
                                                shimmerHighlightColor(),
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                vertical: 10.r,
                                                horizontal: 10.r,
                                              ),
                                              height: bookContainerHeight,
                                              color: comboBlackAndWhite(),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              } else {
                                // Caso não haja seções
                                return Center(
                                  child:
                                      Text(S.of(context).search_NO_BOOKS_FOUND),
                                );
                              }
                            } else {
                              // Enquanto carrega as seções, mostra Shimmer
                              return Shimmer.fromColors(
                                baseColor: shimmerBaseColor(),
                                highlightColor: shimmerHighlightColor(),
                                child: Center(
                                  child: Container(
                                    height: 240.w,
                                    width: 160.r,
                                    child: Icon(
                                      Icons.all_inclusive_outlined,
                                      size: 30.h.w,
                                      color: comboBlackAndWhite(),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
