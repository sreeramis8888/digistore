import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class TransactionTile extends ConsumerWidget {
  final bool isEarned;
  final String title;
  final String subtitle;
  final String points;
  final String date;

  const TransactionTile({
    super.key,
    required this.isEarned,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Container(
      margin: EdgeInsets.only(
        bottom: screenSize.responsivePadding(12),
        left: screenSize.responsivePadding(20),
        right: screenSize.responsivePadding(20),
      ),
      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.responsivePadding(40),
            height: screenSize.responsivePadding(40),
            decoration: const BoxDecoration(
              color: kWhite,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isEarned ? Icons.arrow_downward : Icons.arrow_upward,
                color: isEarned ? kGreen : kRed,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: screenSize.responsivePadding(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: kBodyTitleM),
                SizedBox(height: screenSize.responsivePadding(4)),
                Text(
                  subtitle,
                  style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 16),
                  SizedBox(width: screenSize.responsivePadding(4)),
                  Text(
                    '${isEarned ? '+' : ''}$points',
                    style: kBodyTitleB.copyWith(color: isEarned ? kGreen : kRed),
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(4)),
              Text(
                date,
                style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
