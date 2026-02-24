import 'package:elearn/widgets/imageview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../epub_viewer_lib/epub_viewer.dart';
// import '../epub_viewer_lib/model/epub_locator.dart';
// import '../epub_viewer_lib/utils/util.dart';

// Placeholder temporário enquanto o vocsy_epub_viewer está desabilitado
class EpuB extends StatelessWidget {
  const EpuB({super.key, required this.id, required this.path});

  final int id;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EPUB Viewer desabilitado"),
      ),
      body: const Center(
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
enum EpubScrollDirection { allDirections }

class ReadingListCard extends StatelessWidget {
  final String bookImage;
  final VoidCallback onTap;

  const ReadingListCard({super.key, required this.bookImage, required this.onTap});

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
        ));
  }
}
