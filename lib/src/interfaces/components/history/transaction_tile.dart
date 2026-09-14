import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/screen_size_provider.dart';
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
    final isEarned = type == 'earned' || type == 'bonus' || (transaction.amount != null && transaction.amount! > 0);

    final title = transaction.description?.trim().isNotEmpty == true
        ? transaction.description!.trim()
        : (transaction.source?.type != null
            ? _formatType(transaction.source!.type!)
            : _formatType(type));

    final dateFormatted = _formatTransactionDate(transaction.createdAt);

    return TransactionTile(
      isEarned: isEarned,
      title: title,
      subtitle: dateFormatted,
      points: transaction.amount?.abs().toString() ?? '0',
      date: dateFormatted,
    );
  }

  static String _formatTransactionDate(DateTime? date) {
    if (date == null) return '-';
    final now = DateTime.now();
    final local = date.toLocal();
    final isToday =
        local.year == now.year && local.month == now.month && local.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day;

    final timeStr = DateFormat('h:mm a').format(local);
    if (isToday) {
      return 'Today at $timeStr';
    } else if (isYesterday) {
      return 'Yesterday at $timeStr';
    } else {
      return '${DateFormat('d MMM').format(local)} at $timeStr';
    }
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

    final iconBg = isEarned ? const Color(0xFFE6FFFA) : const Color(0xFFFEF2F2);
    final iconColor = isEarned ? const Color(0xFF07838C) : const Color(0xFFEF4444);
    final badgeBg = isEarned ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    final badgeTextColor = isEarned ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: screenSize.responsivePadding(10)),
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(16),
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: screenSize.responsivePadding(40),
                  height: screenSize.responsivePadding(40),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isEarned
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: screenSize.responsivePadding(12)),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenSize.responsivePadding(2)),
                      Text(
                        subtitle,
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: screenSize.responsivePadding(12)),
          // Amount Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(8),
              vertical: screenSize.responsivePadding(4),
            ),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${isEarned ? '+' : '-'}$points',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: badgeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

