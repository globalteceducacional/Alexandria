import 'package:elearn/consttants.dart';
import 'package:elearn/generated/l10n.dart';
import 'package:elearn/screens/explore.dart';
import 'package:elearn/screens/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../databasefavourite/db.dart';

class Download extends StatefulWidget {
  @override
  _DownloadState createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      appBar: AppBar(
          elevation: 10.0,
          centerTitle: true,
          backgroundColor: comboBlackAndWhite(),
          title: Text(
            S.of(context).setting_DOWNLOAD,
            style: TextStyle(
                color: comboWhiteAndBlack(), fontFamily: "Gilroy-SemiBold"),
          ),
          leading: Padding(
              padding: EdgeInsets.only(left: 10.0.w),
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: comboWhiteAndBlack()),
              ))),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.retrieveDownLoad(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data!.isNotEmpty) {
                return GridView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.r),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.w,
                    childAspectRatio: 160.w / 260.w,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        if (snapshot.data![index]['link']
                            .toString()
                            .contains('epub')) {
                          // EPUB viewer temporariamente desabilitado
                          // Get.to(
                          //   () {
                          //     return EpuB(
                          //         id: snapshot.data![index]['id'],
                          //         path: snapshot.data![index]['link']);
                          //   },
                          // );
                          Get.snackbar(
                            "Aviso",
                            "Visualizador EPUB temporariamente desabilitado",
                            backgroundColor: Colors.amber,
                            colorText: Colors.black,
                          );
                        } else {
                          Get.to(() {
                            return PdfViewerPage(
                                bookid: snapshot.data![index]['id'],
                                bookTitle: snapshot.data![index]['title'],
                                image: snapshot.data![index]['image']);
                          });
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Imageview(
                                image: "${snapshot.data![index]['image']}",
                                height: 240.w,
                                width: 160.w,
                                radius: 10.r,
                              ),
                              InkWell(
                                onTap: () async {
                                  await DatabaseHelper.instance.deleteDownLoad(
                                      snapshot.data![index]['id']);
                                  setState(() {});
                                },
                                child: Container(
                                  width: 35.w,
                                  height: 35.w,
                                  margin: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.delete_forever,
                                      size: 22.w, color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            snapshot.data![index]['title'],
                            maxLines: 2,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 15.sp,
                              fontFamily: "Gilroy-SemiBold",
                              color: comboWhiteAndBlack(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text(
                    S.of(context).no_download,
                    style: TextStyle(
                        color: comboWhiteAndBlack(),
                        fontFamily: "Gilroy-Medium"),
                  ),
                );
              }
            } else {
              return GridView.builder(
                shrinkWrap: true,
                physics: new NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(8.r),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 4,
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.70,
                ),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: shimmerBaseColor(),
                    highlightColor: shimmerHighlightColor(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
  }
}
