import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class SectionTitle extends ConsumerWidget {
  final String title;
  final VoidCallback? onViewAll;
  final Color? titleColor;

  const SectionTitle({
    super.key,
    required this.title,
    this.onViewAll,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(20),
        vertical: screenSize.responsivePadding(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: kHeadTitleB.copyWith(color: titleColor ?? kTextColor),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: kBodyTitleM.copyWith(color: kBlue),
                  ),
                  const Icon(Icons.chevron_right, color: kBlue, size: 20),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
