import 'package:elearn/consttants.dart';
import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  const CustomRichText({
    super.key,
    this.fontsize1,
    this.fontsize2,
    this.txt1,
    this.txt2,
    required this.context,
  });

  final double? fontsize1;
  final double? fontsize2;
  final String? txt1;
  final String? txt2;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      maxLines: 2,
      textAlign: TextAlign.start,
      text: TextSpan(
        style: Theme.of(context).textTheme.headlineLarge,
        children: [
          TextSpan(
            text: txt1,
            style: TextStyle(
              fontSize: fontsize1,
              color: comboWhiteAndBlack(),
              fontFamily: "Gilroy-Bold",
            ),
          ),
          TextSpan(
              text: txt2,
              style: TextStyle(
                color: comboWhiteAndBlack(),
                fontSize: fontsize2,
                fontFamily: "Gilroy-Bold",
              ))
        ],
      ),
    );
  }
}
