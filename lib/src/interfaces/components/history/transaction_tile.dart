import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';

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

  factory TransactionTile.fromTransaction(TransactionModel transaction) {
    final type = transaction.type ?? 'other';
    final isEarned = type == 'earned' || type == 'bonus';
    
    return TransactionTile(
      isEarned: isEarned,
      title: type[0].toUpperCase() + type.substring(1),
      subtitle: transaction.description ?? '',
      points: transaction.amount?.toString() ?? '0',
      date: formatDateTime(transaction.createdAt),
    );
  }

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
                Text(
                  title,
                  style: kSmallTitleL.copyWith(color: const Color(0xFF101828)),
                ),
                SizedBox(height: screenSize.responsivePadding(4)),
                Text(
                  subtitle,
                  style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
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
                  SvgPicture.asset(
                    'assets/svg/coin.svg',
                    width: 18,
                    height: 18,
                  ),
                  SizedBox(width: screenSize.responsivePadding(4)),
                  Text(
                    '${isEarned ? '+' : ''}$points',
                    style: kBodyTitleM.copyWith(
                      color: isEarned ? kGreen : kRed,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(4)),
              Text(
                date,
                style: kSmallerTitleL.copyWith(color: const Color(0xFF99A1AF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
