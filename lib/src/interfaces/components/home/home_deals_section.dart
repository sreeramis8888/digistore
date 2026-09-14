import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import 'deal_offer_card.dart';
import 'section_title.dart';

/// Home revamp deal carousel (Figma Style B white cards).
class HomeDealsSection extends ConsumerWidget {
  final String title;
  final List<OfferModel> offers;
  final VoidCallback? onViewAllTap;

  const HomeDealsSection({
    super.key,
    required this.title,
    required this.offers,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (offers.isEmpty) return const SizedBox.shrink();

    final screenSize = ref.watch(screenSizeProvider);
    final hPad = screenSize.responsivePadding(16);
    final gap = screenSize.responsivePadding(12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: title,
          onViewAll: onViewAllTap,
          revampStyle: true,
        ),
        SizedBox(height: screenSize.responsivePadding(8)),
        SizedBox(
          height: screenSize.responsivePadding(216),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            itemCount: offers.length,
            separatorBuilder: (_, _) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              return DealOfferCard(offer: offers[index]);
            },
          ),
        ),
      ],
    );
  }
}
