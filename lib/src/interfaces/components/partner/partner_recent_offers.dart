import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/router/nav_router.dart';
import '../../../data/utils/currency_formatter.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/advanced_network_image.dart';

class PartnerRecentOffers extends ConsumerWidget {
  final ScreenSizeData screenSize;
  final List<OfferModel>? offers;

  const PartnerRecentOffers({
    super.key,
    required this.screenSize,
    this.offers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (offers == null || offers!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Uploaded Offers',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              InkWell(
                onTap: () {
                  ref.read(selectedIndexProvider.notifier).updateIndex(1);
                },
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        SizedBox(
          height: screenSize.responsivePadding(218),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
            ),
            itemCount: offers!.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final offer = offers![index];
              return _buildOfferCard(context, offer);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(BuildContext context, OfferModel offer) {
    final imageUrl = (offer.images != null && offer.images!.isNotEmpty)
        ? offer.images!.first
        : '';

    String badgeText = '';
    if (offer.discountValue != null && offer.discountValue! > 0) {
      final isPercentage = offer.discountType?.toLowerCase() == 'percentage' ||
          offer.discountType?.toLowerCase() == 'percent' ||
          offer.discountType == '%';
      if (isPercentage) {
        final val = offer.discountValue! % 1 == 0
            ? offer.discountValue!.toInt().toString()
            : offer.discountValue!.toStringAsFixed(1);
        badgeText = '$val% OFF';
      } else {
        badgeText = 'Flat ₹${formatCurrency(offer.discountValue)} OFF';
      }
    } else if (offer.title != null && offer.title!.toUpperCase().contains('GET 1')) {
      badgeText = 'BUY 1 GET 1';
    } else if (offer.category?.name != null && offer.category!.name!.isNotEmpty) {
      badgeText = offer.category!.name!;
    } else {
      badgeText = 'SPECIAL OFFER';
    }

    return InteractiveFeedbackButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          'offerDetail',
          arguments: offer.toJson(),
        );
      },
      scaleFactor: 0.98,
      child: Container(
        width: 220,
        height: 218,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container with Badge
            SizedBox(
              width: double.infinity,
              height: 130,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    AdvancedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.zero,
                      disableFade: true,
                    )
                  else
                    Container(
                      color: const Color(0xFFF3F4F6),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.local_offer_outlined,
                        size: 40,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  if (badgeText.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Titles Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      offer.title ?? 'Special Offer',
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.description ?? '',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

