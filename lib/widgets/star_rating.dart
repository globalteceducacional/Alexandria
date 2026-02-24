import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:elearn/consttants.dart';

/// Widget para seleção de avaliação por estrelas (1-5)
class StarRating extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onRatingChanged;
  final int maxStars;
  final double starSize;
  final Color? filledColor;
  final Color? unfilledColor;

  const StarRating({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.maxStars = 5,
    this.starSize = 40,
    this.filledColor,
    this.unfilledColor,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int currentRating;

  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final filledStarColor = widget.filledColor ?? const Color(0xFFFFD700);
    final unfilledStarColor = widget.unfilledColor ?? comboLightGreyAndGrey();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.maxStars, (index) {
        int starNumber = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              currentRating = starNumber;
            });
            widget.onRatingChanged(starNumber);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(
              starNumber <= currentRating ? Icons.star : Icons.star_border,
              color: starNumber <= currentRating
                  ? filledStarColor
                  : unfilledStarColor,
              size: widget.starSize,
            ),
          ),
        );
      }),
    );
  }
}

/// Widget para exibir apenas estrelas (sem interação)
class DisplayStarRating extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double starSize;
  final Color filledColor;
  final Color unfilledColor;

  const DisplayStarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.starSize = 20,
    this.filledColor = const Color(0xFFFFD700),
    this.unfilledColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    double remainder = rating - fullStars;
    bool hasHalfStar = remainder >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxStars, (index) {
        if (index < fullStars) {
          // Estrela completa
          return Icon(
            Icons.star,
            color: filledColor,
            size: starSize,
          );
        } else if (index == fullStars && hasHalfStar) {
          // Meia estrela
          return Icon(
            Icons.star_half,
            color: filledColor,
            size: starSize,
          );
        } else {
          // Estrela vazia
          return Icon(
            Icons.star_border,
            color: unfilledColor,
            size: starSize,
          );
        }
      }),
    );
  }
}
