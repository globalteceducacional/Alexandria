import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAlert extends StatelessWidget {
  final Widget child;

  const CustomAlert({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final viewsSize = MediaQuery.of(context).size;

    final deviceWidth = orientation == Orientation.portrait
        ? viewsSize.width
        : viewsSize.height;

    return MediaQuery(
      data: const MediaQueryData(),
      child: GestureDetector(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 0.5,
            sigmaY: 0.5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        width: deviceWidth * 0.9,
                        child: GestureDetector(
                          onTap: () {},
                          child: Card(
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0.r),
                              ),
                            ),
                            child: child,
                          ),
                        ),
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
