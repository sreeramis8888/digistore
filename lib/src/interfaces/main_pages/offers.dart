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

class OffersPage extends ConsumerWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(260);
    final aspectRatio = itemWidth / itemHeight;

    final selectedCategoryIndex = ref.watch(selectedOffersCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    String? categoryId;
    categoriesAsync.whenData((categories) {
      if (selectedCategoryIndex > 0 && selectedCategoryIndex <= categories.length) {
        categoryId = categories[selectedCategoryIndex - 1].id;
      }
    });

    final offersAsync = ref.watch(offersProvider(categoryId: categoryId));

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
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (GlobalVariables.isMerchant) ...[
              SizedBox(height: screenSize.responsivePadding(16)),
              const HomeSearchBar(hintText: "Search for 'offers'"),
            ] else
              const OffersFilterChips(),
            SizedBox(height: screenSize.responsivePadding(16)),
            Expanded(
              child: offersAsync.when(
                data: (paginated) => GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: screenSize.responsivePadding(16),
                    crossAxisSpacing: screenSize.responsivePadding(16),
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: paginated.offers.length,
                  itemBuilder: (context, index) {
                    final o = paginated.offers[index];
                    return DealCard.fromOffer(o);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
