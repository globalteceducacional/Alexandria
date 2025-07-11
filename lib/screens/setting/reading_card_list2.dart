import 'package:elearn/consttants.dart';
import 'package:elearn/databasefavourite/db.dart';
import 'package:elearn/generated/l10n.dart';
import 'package:elearn/screens/explore.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReadingListCard2 extends StatefulWidget {
  final int index;
  final String image;
  final String bookTitle;
  final String authorName;
  final int bookid;
  final int authid;
  final String rating;
  final String authorDescription;
  final String bookDescription;
  final double radius;
  final VoidCallback onTap;

  ReadingListCard2({
    Key? key,
    required this.index,
    required this.image,
    required this.bookTitle,
    required this.bookid,
    required this.authorName,
    required this.authid,
    required this.authorDescription,
    required this.bookDescription,
    required this.rating,
    required this.onTap,
    required this.radius,
  }) : super(key: key);

  @override
  _ReadingListCard2State createState() => _ReadingListCard2State();
}

class _ReadingListCard2State extends State<ReadingListCard2> {
  @override
  void initState() {
    getDatabase();
    // Código do EpubViewer temporariamente comentado
    // EpubViewer.setConfig(
    //     themeColor: Colors.black,
    //     identifier: "book",
    //     scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
    //     allowSharing: true,
    //     enableTts: true,
    //     nightMode: true);
    super.initState();
  }

  bool fav = false;

  getDatabase() async {
    fav = await DatabaseHelper.instance.likeOrNot(widget.bookid.toString());
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 5.h),
        padding: EdgeInsets.all(8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Imageview(
              image: widget.image,
              width: 100.w,
              height: 150.w,
              radius: 8.r,
            ),
            SizedBox(width: 20.w),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bookTitle,
                    maxLines: 2,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 15.sp,
                      fontFamily: "Gilroy-SemiBold",
                      color: comboWhiteAndBlack(),
                    ),
                  ),
                  Text(
                    "Por ${widget.authorName.toLowerCase()}",
                    style: TextStyle(
                        color: comboWhiteAndBlack(),
                        overflow: TextOverflow.ellipsis,
                        fontFamily: "Gilroy-Medium"),
                  ),
                  RatingBar(
                    itemSize: 30.h,
                    initialRating: double.parse(widget.rating),
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    ratingWidget: RatingWidget(
                      full: Icon(
                        Icons.star_rounded,
                        color: Colors.orange,
                      ),
                      half: Icon(
                        Icons.star_half,
                        color: Colors.orange,
                      ),
                      empty: Icon(
                        Icons.star_border_rounded,
                        color: Colors.orange,
                      ),
                    ),
                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    onRatingUpdate: (rating) {
                      if (userId != null) {
                        HttpService().submitRating(
                            rating: rating, bookid: widget.bookid.toString());
                      } else {
                        customSnackBar(context);
                      }
                    },
                  ),
                ],
              ),
            ),
            userId == null
                ? Expanded(
                    flex: 1,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      splashRadius: 20.r,
                      onPressed: () async {
                        customSnackBar(context);
                      },
                      icon: Icon(
                        Icons.favorite_border,
                        color: comboWhiteAndBlack(),
                      ),
                    ),
                  )
                : Expanded(
                    flex: 1,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      splashRadius: 20.r,
                      onPressed: () async {
                        if (fav) {
                          await DatabaseHelper.instance
                              .deleteTodo(id: widget.bookid);
                        } else {
                          await DatabaseHelper.instance.insertTodo(
                            Todo(
                              id: widget.bookid,
                              rating: widget.rating,
                              authorDescription: widget.authorDescription,
                              bookDescription: widget.bookDescription,
                              image: widget.image,
                              authorName: widget.authorName,
                              bookid: widget.bookid,
                              title: widget.bookTitle,
                            ),
                          );
                          showToast(
                              msg: S.of(context).detail_screen_ADD_FAVOURITE);
                        }
                        getDatabase().whenComplete(() {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      },
                      icon: Icon(
                        fav ? Icons.favorite : Icons.favorite_border,
                        color: comboWhiteAndBlack(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
