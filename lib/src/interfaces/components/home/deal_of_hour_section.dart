import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import 'deal_offer_card.dart';
import 'deal_promo_card.dart';
import 'section_title.dart';

enum DealOfHourVariant {
  /// Pastel promo cards (Figma Style A)
  promo,
  /// White image cards (Figma Style B)
  cards,
}

/// Deal of the Hour carousel. Use [promo] then [cards] with the same offers
/// (categories sit between them in the home layout).
class DealOfHourSection extends ConsumerWidget {
  final List<OfferModel> offers;
  final DealOfHourVariant variant;
  final VoidCallback? onViewAllTap;

  const DealOfHourSection({
    super.key,
    required this.offers,
    this.variant = DealOfHourVariant.promo,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (offers.isEmpty) return const SizedBox.shrink();

    final screenSize = ref.watch(screenSizeProvider);
    final hPad = screenSize.responsivePadding(16);
    final gap = screenSize.responsivePadding(12);
    final isPromo = variant == DealOfHourVariant.promo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Deal of the Hour',
          onViewAll: onViewAllTap,
          revampStyle: true,
        ),
        SizedBox(height: screenSize.responsivePadding(8)),
        SizedBox(
          height: isPromo
              ? screenSize.responsivePadding(290)
              : screenSize.responsivePadding(216),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            itemCount: offers.length,
            separatorBuilder: (_, _) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              if (isPromo) {
                return DealPromoCard(
                  offer: offers[index],
                  index: index,
                );
              }
              return DealOfferCard(offer: offers[index]);
            },
          ),
        ),
      ],
    );
  }
}
