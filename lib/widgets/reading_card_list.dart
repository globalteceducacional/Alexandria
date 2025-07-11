import 'package:elearn/screens/explore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EpuB extends StatelessWidget {
  EpuB({required this.id, required this.path});

  final int id;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EPUB Viewer desabilitado")),
      body: Center(
        child: Text("O visualizador EPUB está temporariamente desabilitado."),
      ),
    );
  }
}

// Placeholder para EpubLocator
class EpubLocator {
  Map<String, dynamic> toJson() => {};
  static fromJson(Map<String, dynamic> r) => EpubLocator();
}

// Placeholder para EpubScrollDirection
enum EpubScrollDirection { ALLDIRECTIONS }

class ReadingListCard extends StatelessWidget {
  final String bookImage;
  final VoidCallback onTap;

  ReadingListCard({Key? key, required this.bookImage, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 10.r),
        child: Imageview(
          image: bookImage,
          width: 160.r,
          height: 240.r,
          radius: 8.r,
        ),
      ),
    );
  }
}
