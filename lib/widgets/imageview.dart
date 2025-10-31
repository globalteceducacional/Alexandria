import 'package:elearn/consttants.dart';
import 'package:elearn/widgets/safe_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Imageview extends StatelessWidget {
  const Imageview({required this.image, this.radius, this.height, this.width});

  final String image;
  final double? radius;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    // Corrigir URL removendo HTML entities
    String fixedImage = fixImageUrl(image);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 8.r),
      child: SafeBookCoverWidget(
        imageUrl: "$apiLink/images/$fixedImage",
        height: height ?? MediaQuery.of(context).size.height * 2,
        width: width ?? MediaQuery.of(context).size.width * 2,
      ),
    );
  }
}
