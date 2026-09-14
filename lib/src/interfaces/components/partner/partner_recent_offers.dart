import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/router/nav_router.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/advanced_network_image.dart';
import '../offers/deal_card.dart';

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
        CarouselSlider.builder(
          itemCount: offers!.length,
          options: CarouselOptions(
            height: screenSize.responsivePadding(218),
            viewportFraction: 0.62,
            enableInfiniteScroll: false,
            padEnds: false,
          ),
          itemBuilder: (context, index, realIndex) {
            final padding = screenSize.responsivePadding(16);
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? padding : 6,
                right: index == offers!.length - 1 ? padding : 6,
              ),
              child: _buildOfferCard(context, offers![index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOfferCard(BuildContext context, OfferModel offer) {
    final imageUrl = (offer.images != null && offer.images!.isNotEmpty)
        ? offer.images!.first
        : '';

    final rawBadge = DealCard.resolveBadgeText(offer);
    final badgeText = rawBadge == null || rawBadge.isEmpty
        ? ''
        : rawBadge.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

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
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        right: 12,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              badgeText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

