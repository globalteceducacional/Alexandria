import 'package:elearn/generated/l10n.dart';
import 'package:elearn/model/getsinglecategorybyid.dart';
import 'package:elearn/screens/details_screen.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:elearn/widgets/safe_image_widget.dart';

import '../consttants.dart';

class SingleAuthorView extends StatefulWidget {
  const SingleAuthorView({
    required this.catId,
    required this.title,
    required this.id,
    required this.image,
    required this.name,
    required this.authorDescription,
    Key? key,
  }) : super(key: key);

  final int catId;
  final String title;
  final int id;
  final String image;
  final String name;
  final String authorDescription;

  @override
  _SingleAuthorViewState createState() => _SingleAuthorViewState();
}

class _SingleAuthorViewState extends State<SingleAuthorView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: comboBlackAndWhite(),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          S.of(context).cat_Author,
          style: TextStyle(
            color: comboWhiteAndBlack(),
            fontFamily: "Gilroy-Medium",
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: comboWhiteAndBlack(), size: 24.r),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Seção do perfil do desenvolvedor
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: mode.value ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: mode.value
                        ? Colors.black.withAlpha(30)
                        : Colors.grey.withAlpha(30),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Imagem do desenvolvedor
                  Hero(
                    tag: 'developer-${widget.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: SafeProfileImageWidget(
                          imageUrl:
                              "$apiLink/images/${fixImageUrl(widget.image)}",
                          size: 160.h,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Nome do desenvolvedor
                  Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Gilroy-Bold',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: comboWhiteAndBlack(),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Descrição do desenvolvedor
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: mode.value
                          ? Colors.grey.shade900.withAlpha(50)
                          : Colors.white.withAlpha(80),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: mode.value
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      htmlString(html: widget.authorDescription),
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.4,
                        color: comboWhiteAndBlack(),
                        fontFamily: "Gilroy-Medium",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Título da seção de Sites
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: kLightThemeBackGroundColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Sites deste desenvolvedor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Gilroy-Bold",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de Sites do desenvolvedor
            FutureBuilder<GetSingleCategoryById?>(
              future: HttpService().getSingleAuthorById(authId: widget.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingGrid();
                } else if (snapshot.hasError) {
                  return _buildErrorWidget();
                } else if (!snapshot.hasData ||
                    snapshot.data!.ebookApp.isEmpty) {
                  return _buildEmptyWidget();
                }

                final books = snapshot.data!.ebookApp;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.r),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 20.w,
                    mainAxisSpacing: 20.h,
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _buildGameCard(book);
                  },
                );
              },
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // Widget para exibir o estado de carregamento
  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 20.w,
        mainAxisSpacing: 20.h,
        crossAxisCount: 2,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: shimmerBaseColor(),
          highlightColor: shimmerHighlightColor(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        );
      },
    );
  }

  // Widget para exibir erros
  Widget _buildErrorWidget() {
    return Container(
      margin: EdgeInsets.all(24.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(10),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withAlpha(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Ocorreu um erro ao carregar os Sites',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  // Widget para exibir quando não há Sites
  Widget _buildEmptyWidget() {
    return Container(
      margin: EdgeInsets.all(24.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: mode.value
            ? Colors.grey.shade800.withAlpha(50)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: mode.value ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videogame_asset_off,
            size: 64.r,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            S.of(context).search_NO_BOOKS_FOUND,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: comboWhiteAndBlack(),
              fontFamily: "Gilroy-Medium",
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Este desenvolvedor ainda não tem Sites disponíveis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para exibir um cartão de Site
  Widget _buildGameCard(EbookApp book) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                rating: book.rateAvg,
                bookDescription: book.bookDescription,
                id: int.parse(book.id),
                bookTitle: book.bookTitle,
                bookCoverImg: book.bookCoverImg,
                authorDescription: book.authorDescription,
                authorName: book.authorName,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagem do Site
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  child: SafeBookCoverWidget(
                    imageUrl: book.bookCoverImg.startsWith('http')
                        ? fixImageUrl(book.bookCoverImg)
                        : "$apiLink/images/${fixImageUrl(book.bookCoverImg)}",
                  ),
                ),
              ),

              // Informações do Site
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: mode.value
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        book.bookTitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: comboWhiteAndBlack(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
