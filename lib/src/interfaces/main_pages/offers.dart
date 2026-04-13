import 'package:digistore/src/interfaces/animations/index.dart';
import 'package:digistore/src/interfaces/components/shimmers/card_shimmers.dart';
import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../components/offers/offers_filter_chips.dart';
import '../components/offers/deal_card.dart';
import '../../data/utils/global_variables.dart';
import '../components/home/home_search_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/screen_size_provider.dart';

import '../../data/providers/offers_provider.dart';
import '../../data/providers/category_provider.dart';
import '../../data/router/nav_router.dart';
import '../components/empty_state.dart';
import '../components/primary_button.dart';
import 'partner/create_offer_page.dart';

class OffersPage extends ConsumerStatefulWidget {
  const OffersPage({super.key});

  @override
  ConsumerState<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends ConsumerState<OffersPage> {
  String? _lastCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(offersProvider.notifier).fetchOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(235);
    final aspectRatio = itemWidth / itemHeight;

    final selectedCategoryIndex = ref.watch(selectedOffersCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    String? categoryId;
    categoriesAsync.whenData((categories) {
      if (selectedCategoryIndex > 0 &&
          selectedCategoryIndex <= categories.length) {
        categoryId = categories[selectedCategoryIndex - 1].id;
      }
    });

    if (categoryId != _lastCategoryId) {
      _lastCategoryId = categoryId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(offersProvider.notifier).fetchOffers(categoryId: categoryId);
      });
    }

    final offersState = ref.watch(offersProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          'Offers',
          style: kBodyTitleM.copyWith(color: const Color(0xFF373737)),
        ),
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (GlobalVariables.isPartner)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
                vertical: screenSize.responsivePadding(8),
              ),
              child: PrimaryButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateOfferPage(),
                    ),
                  );
                },
                width: screenSize.responsivePadding(120),
                text: 'Create Offer',
                textSize: 12,
                backgroundColor: kPrimaryColor,
                textColor: kWhite,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (GlobalVariables.isPartner) ...[
              SizedBox(height: screenSize.responsivePadding(16)),
              const HomeSearchBar(hintText: "Search for 'offers'"),
            ] else
              const OffersFilterChips(),
            SizedBox(height: screenSize.responsivePadding(16)),
            Expanded(
                child: offersState.isLoading
                    ? GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.responsivePadding(16),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: screenSize.responsivePadding(16),
                          crossAxisSpacing: screenSize.responsivePadding(16),
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) =>
                            CardShimmers.dealCardShimmer(screenSize),
                      )
                    : offersState.offers.isEmpty
                    ? EmptyState(
                        imagePath: 'assets/png/empty_offers.png',
                        title: GlobalVariables.isPartner
                            ? 'No offer created yet'
                            : 'No offers found',
                        subtitle: GlobalVariables.isPartner
                            ? 'You haven\'t created any offers yet. Start by creating your first deal!'
                            : 'Check back later for exciting new deals and discounts in this category.',
                      ).fadeIn()
                    : GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.responsivePadding(16),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: screenSize.responsivePadding(16),
                          crossAxisSpacing: screenSize.responsivePadding(16),
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: offersState.offers.length,
                        itemBuilder: (context, index) {
                          final o = offersState.offers[index];
                          return DealCard.fromOffer(o).fadeSlideInFromBottom(
                            delayMilliseconds: index * 50,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
