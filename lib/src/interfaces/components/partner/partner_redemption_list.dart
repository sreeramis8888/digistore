import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/models/redemption_model.dart';
import '../advanced_network_image.dart';

class PartnerRedemptionList extends StatelessWidget {
  final ScreenSizeData screenSize;
  final List<RedemptionModel> redemptions;

  const PartnerRedemptionList({
    super.key,
    required this.screenSize,
    required this.redemptions,
  });

  @override
  Widget build(BuildContext context) {
    if (redemptions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenSize.responsivePadding(24),
          ),
          child: Text(
            'No redemption history',
            style: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF99A1AF),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: redemptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _RedemptionRow(redemption: redemptions[index]);
      },
    );
  }
}

class _RedemptionRow extends StatelessWidget {
  final RedemptionModel redemption;

  const _RedemptionRow({required this.redemption});

  ({String label, Color bg, Color fg}) _statusStyle() {
    final status = (redemption.status ?? '').toLowerCase();
    if (status == 'completed' || status == 'verified') {
      return (
        label: 'Verified',
        bg: const Color(0xFFE8F5EC),
        fg: const Color(0xFF07982C),
      );
    }
    if (status == 'rejected' ||
        status == 'failed' ||
        status == 'cancelled' ||
        status == 'declined') {
      return (
        label: 'Rejected',
        bg: const Color(0xFFFDECEC),
        fg: const Color(0xFFFF383C),
      );
    }
    final raw = redemption.status?.trim();
    final label = (raw == null || raw.isEmpty)
        ? 'Pending'
        : '${raw[0].toUpperCase()}${raw.substring(1).toLowerCase()}';
    return (
      label: label,
      bg: const Color(0xFFF3F4F6),
      fg: const Color(0xFF6B7280),
    );
  }

  String _formatRedeemedAt(DateTime? dt) {
    if (dt == null) return 'N/A';
    final time = DateFormat('hh:mm a').format(dt);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return '$time, Today';
    if (diff == 1) return '$time, Yesterday';
    return DateFormat('hh:mm a, dd MMM').format(dt);
  }

  String _shortId(String? id) {
    if (id == null || id.isEmpty) return '—';
    return id.length > 5 ? id.substring(id.length - 5) : id;
  }

  @override
  Widget build(BuildContext context) {
    final offer = redemption.offerId;
    final imageUrl =
        (offer?.images != null && offer!.images!.isNotEmpty)
            ? offer.images!.first
            : '';
    final status = _statusStyle();
    final subtitle = (offer?.description ?? '').trim();

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: imageUrl.isNotEmpty
                      ? AdvancedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          disableFade: true,
                        )
                      : Container(
                          color: const Color(0xFFF3F4F6),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.local_offer_outlined,
                            size: 18,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer?.title ?? 'Redeemed Offer',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.label,
                  style: GoogleFonts.urbanist(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: status.fg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Redeemed on: ${_formatRedeemedAt(redemption.redeemedAt)}',
                  style: GoogleFonts.urbanist(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ID: ${_shortId(redemption.id)}',
                style: GoogleFonts.urbanist(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
