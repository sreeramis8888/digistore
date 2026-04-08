import 'package:flutter/material.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../offers/deal_card.dart';
import '../../../data/models/offer_model.dart';

class PartnerRecentOffers extends StatelessWidget {
  final ScreenSizeData screenSize;
  final List<OfferModel>? offers;

  const PartnerRecentOffers({super.key, required this.screenSize, this.offers});

  @override
  Widget build(BuildContext context) {
    if (offers == null || offers!.isEmpty) {
      return const Center(child: Text('No offers available'));
    }

    return SizedBox(
      height: screenSize.responsivePadding(220),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: offers!.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final offer = offers![index];
          return SizedBox(width: 160, child: DealCard.fromOffer(offer));
        },
      ),
    );
  }
}
