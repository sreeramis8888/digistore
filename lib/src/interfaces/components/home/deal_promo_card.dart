import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../advanced_network_image.dart';
import '../offers/deal_card.dart';

class _PromoTheme {
  final Color background;
  final Color titleColor;
  final Color badgeLabelColor;
  final Color badgeValueColor;

  const _PromoTheme({
    required this.background,
    required this.titleColor,
    required this.badgeLabelColor,
    required this.badgeValueColor,
  });
}

const _promoThemes = [
  _PromoTheme(
    background: Color(0xFFFFEDE0),
    titleColor: Color(0xFF6E1A03),
    badgeLabelColor: Color(0xFF6B7280),
    badgeValueColor: Color(0xFF1A3C34),
  ),
  _PromoTheme(
    background: Color(0xFFFDEAF0),
    titleColor: Color(0xFF4A1228),
    badgeLabelColor: Color(0xFF9B4069),
    badgeValueColor: Color(0xFF4A1228),
  ),
  _PromoTheme(
    background: Color(0xFFFDF0E0),
    titleColor: Color(0xFF4A2800),
    badgeLabelColor: Color(0xFF9B6A2E),
    badgeValueColor: Color(0xFF4A2800),
  ),
];

/// Pastel promo card (Figma Deal of the Hour — Style A).
class DealPromoCard extends ConsumerWidget {
  final OfferModel offer;
  final int index;
  final double? width;

  const DealPromoCard({
    super.key,
    required this.offer,
    this.index = 0,
    this.width,
  });

  void _openDetail(BuildContext context) {
    Navigator.of(context).pushNamed(
      'offerDetail',
      arguments: offer.toJson(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final theme = _promoThemes[index % _promoThemes.length];
    final title = offer.title ?? '';
    final shopName = offer.partnerId?.businessDetails?.businessName ?? '';
    final shopLogo = offer.partnerId?.businessInfo?.businessLogo;
    final imageUrl =
        offer.images?.isNotEmpty == true ? offer.images!.first : null;
    final badge = DealCard.resolveBadgeText(offer);
    final badgeParts = (badge ?? '')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final cardWidth = width ?? screenSize.responsivePadding(200);

    return InteractiveFeedbackButton(
      onPressed: () => _openDetail(context),
      scaleFactor: 0.98,
      child: SizedBox(
        width: cardWidth,
        height: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  screenSize.responsivePadding(16),
                  screenSize.responsivePadding(16),
                  screenSize.responsivePadding(16),
                  screenSize.responsivePadding(12),
                ),
                child: Text(
                  title,
                  style: kSubHeadingEB.copyWith(
                    color: theme.titleColor,
                    fontSize: 18,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AdvancedNetworkImage(
                      imageUrl: imageUrl ?? '',
                      fit: BoxFit.cover,
                      disableFade: true,
                    ),
                    if (badgeParts.isNotEmpty)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: kWhite.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                badgeParts.first.toUpperCase(),
                                style: kSmallerTitleM.copyWith(
                                  color: theme.badgeLabelColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (badgeParts.length > 1)
                                Text(
                                  badgeParts.sublist(1).join(' '),
                                  style: kSmallerTitleB.copyWith(
                                    color: theme.badgeValueColor,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  screenSize.responsivePadding(16),
                  screenSize.responsivePadding(8),
                  screenSize.responsivePadding(16),
                  screenSize.responsivePadding(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.titleColor.withValues(alpha: 0.15),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: shopLogo != null && shopLogo.isNotEmpty
                          ? AdvancedNetworkImage(
                              imageUrl: shopLogo,
                              fit: BoxFit.cover,
                              disableFade: true,
                            )
                          : Icon(
                              Icons.store,
                              size: 12,
                              color: theme.titleColor,
                            ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shopName,
                        style: kSmallerTitleB.copyWith(
                          color: theme.titleColor,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
