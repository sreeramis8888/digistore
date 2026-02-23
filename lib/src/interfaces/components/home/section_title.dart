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
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: kBodyTitleM.copyWith(color: titleColor ?? kTextColor),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: kSmallTitleM.copyWith(color: Color(0xFF2563EB)),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
