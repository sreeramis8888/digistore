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
    final type = (transaction.type ?? 'other').toLowerCase();
    final isEarned = type == 'earned' || type == 'bonus';

    return TransactionTile(
      isEarned: isEarned,
      title: _formatType(type),
      subtitle: transaction.description?.trim().isNotEmpty == true
          ? transaction.description!.trim()
          : (transaction.source?.type != null
              ? _formatType(transaction.source!.type!)
              : 'Points update'),
      points: transaction.amount?.toString() ?? '0',
      date: formatDateTime(transaction.createdAt),
    );
  }

  static String _formatType(String type) {
    if (type.isEmpty) return 'Other';
    return type
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final accent = isEarned ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final accentBg =
        isEarned ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);

    return Container(
      margin: EdgeInsets.only(bottom: screenSize.responsivePadding(10)),
      padding: EdgeInsets.all(screenSize.responsivePadding(14)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.responsivePadding(42),
            height: screenSize.responsivePadding(42),
            decoration: BoxDecoration(
              color: accentBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              color: accent,
              size: 20,
            ),
          ),
          SizedBox(width: screenSize.responsivePadding(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kSmallTitleB.copyWith(
                    color: const Color(0xFF111827),
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(4)),
                Text(
                  subtitle,
                  style: kSmallerTitleL.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 12,
                    height: 1.25,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: screenSize.responsivePadding(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/coin.svg',
                    width: 14,
                    height: 14,
                  ),
                  SizedBox(width: screenSize.responsivePadding(4)),
                  Text(
                    '${isEarned ? '+' : '-'}$points',
                    style: kSmallTitleB.copyWith(
                      color: accent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(4)),
              Text(
                date,
                style: kSmallerTitleL.copyWith(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
