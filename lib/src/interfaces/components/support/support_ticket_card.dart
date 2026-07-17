import 'package:flutter/material.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/support_ticket_model.dart';
import '../../../data/providers/screen_size_provider.dart';

class SupportTicketCard extends StatelessWidget {
  final SupportTicketModel ticket;
  final ScreenSizeData screenSize;
  final VoidCallback onTap;

  const SupportTicketCard({
    super.key,
    required this.ticket,
    required this.screenSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedId = ticket.id.length > 8
        ? '#${ticket.id.substring(ticket.id.length - 8).toUpperCase()}'
        : '#${ticket.id.toUpperCase()}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kStrokeColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Category label & Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        ticket.categoryIcon,
                        size: 16,
                        color: ticket.categoryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ticket.categoryDisplayName,
                        style: kSmallTitleB.copyWith(
                          color: kTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.statusDisplayName,
                      style: kSmallTitleB.copyWith(
                        color: ticket.statusColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Middle: Subject + Arrow
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      style: kSubHeadingM.copyWith(
                        color: kTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: kStrokeColor,
                    size: 14,
                  ),
                ],
              ),

              if (ticket.messages.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  ticket.messages.last.message,
                  style: kSmallTitleL.copyWith(
                    color: kSecondaryTextColor,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 10),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF3F4F6),
              ),
              const SizedBox(height: 8),

              // Bottom: ID & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedId,
                    style: kSmallTitleB.copyWith(
                      color: kSecondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    _formatDate(ticket.updatedAt),
                    style: kSmallTitleL.copyWith(
                      color: kSecondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24 && now.day == date.day) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
