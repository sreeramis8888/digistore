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
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFF96D4FB)],
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.responsivePadding(12),
          horizontal: screenSize.responsivePadding(4),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB0DFF9), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: screenSize.responsivePadding(55),
              height: screenSize.responsivePadding(55),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5F5F5).withOpacity(.55),
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
      ),
    );
  }
}
