import 'package:setgo/src/data/utils/interactive_feedback_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class SectionTitle extends ConsumerWidget {
  final String title;
  final VoidCallback? onViewAll;
  final Color? titleColor;
  /// When true, matches Digistore-Pay home: ExtraBold 20 title + green View All.
  final bool revampStyle;

  const SectionTitle({
    super.key,
    required this.title,
    this.onViewAll,
    this.titleColor,
    this.revampStyle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final viewAllColor =
        revampStyle ? kHeroAccentGreen : const Color(0xFF2563EB);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
        vertical: revampStyle ? 0 : screenSize.responsivePadding(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: revampStyle
                  ? kHeadTitleEB.copyWith(
                      color: titleColor ?? const Color(0xFF111827),
                      fontSize: 20,
                    )
                  : kBodyTitleM.copyWith(color: titleColor ?? kTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onViewAll != null)
            InteractiveFeedbackButton(
              onPressed: onViewAll,
              scaleFactor: 0.9,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: kSmallTitleM.copyWith(
                      color: viewAllColor,
                      fontWeight:
                          revampStyle ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: viewAllColor,
                    size: revampStyle ? 14 : 20,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
