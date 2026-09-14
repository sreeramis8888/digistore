import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../advanced_network_image.dart';
import '../offers/deal_card.dart';

/// White image deal card (Figma Deal of the Hour — Style B).
class DealOfferCard extends ConsumerWidget {
  final OfferModel offer;
  final double? width;

  const DealOfferCard({
    super.key,
    required this.offer,
    this.width,
  });

  String? get _badgeSingleLine {
    final raw = DealCard.resolveBadgeText(offer);
    if (raw == null || raw.isEmpty) return null;
    return raw.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).pushNamed(
      'offerDetail',
      arguments: offer.toJson(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final title = offer.title ?? '';
    final shopName = offer.partnerId?.businessDetails?.businessName ?? '';
    final shopLogo = offer.partnerId?.businessInfo?.businessLogo;
    final imageUrl =
        offer.images?.isNotEmpty == true ? offer.images!.first : null;
    final badge = _badgeSingleLine;
    final cardWidth = width ?? screenSize.responsivePadding(220);

    return InteractiveFeedbackButton(
      onPressed: () => _openDetail(context),
      scaleFactor: 0.98,
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: screenSize.responsivePadding(130),
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AdvancedNetworkImage(
                    imageUrl: imageUrl ?? '',
                    fit: BoxFit.cover,
                    disableFade: true,
                  ),
                  if (badge != null && badge.isNotEmpty)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF07982C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: kSmallerTitleEB.copyWith(
                            color: kWhite,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: kSmallTitleB.copyWith(
                      color: const Color(0xFF111827),
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenSize.responsivePadding(10)),
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          color: kPrimaryLightColor,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: shopLogo != null && shopLogo.isNotEmpty
                            ? AdvancedNetworkImage(
                                imageUrl: shopLogo,
                                fit: BoxFit.cover,
                                disableFade: true,
                              )
                            : const Icon(
                                Icons.store,
                                size: 10,
                                color: kWhite,
                              ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          shopName,
                          style: kSmallerTitleM.copyWith(
                            color: const Color(0xFF111827),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
