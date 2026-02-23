import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryCard extends ConsumerWidget {
  final Map<String, dynamic> category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Container(
      width: screenSize.responsivePadding(80),
      height: screenSize.responsivePadding(118),
      padding: EdgeInsets.symmetric(
        vertical: screenSize.responsivePadding(12),
        horizontal: screenSize.responsivePadding(4),
      ),
      decoration: BoxDecoration(
        color: kWhite,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: screenSize.responsivePadding(55),
            height: screenSize.responsivePadding(55),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category['color'] as Color,
            ),
            child: Center(
              child: SvgPicture.asset(
                category['icon'] as String,
                width: 20,
                height: 20,
              ),
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(8)),
          Text(
            category['name'] as String,
            style: kSmallTitleL.copyWith(fontSize: 11, height: 1.2),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}
