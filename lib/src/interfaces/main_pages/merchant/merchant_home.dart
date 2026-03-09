import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../components/home/home_search_bar.dart';
import '../../components/merchant/merchant_home_header.dart';
import '../../components/merchant/merchant_overview_cards.dart';
import '../../components/merchant/merchant_quick_actions.dart';
import '../../components/merchant/merchant_recent_offers.dart';
import '../../components/merchant/merchant_uploaded_products.dart';

class MerchantHomePage extends ConsumerWidget {
  const MerchantHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.responsivePadding(16)),
                MerchantHomeHeader(screenSize: screenSize),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  'Welcome Back,  Fami',
                  style: kSmallTitleSB.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                HomeSearchBar(
                  hintText: "Search for 'offers'",
                  padding: EdgeInsets.zero,
                  onTap: () {},
                ),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  "Today's Overview",
                  style: kSmallTitleB.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                MerchantOverviewCards(screenSize: screenSize),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  "Quick Actions",
                  style: kSmallTitleB.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                MerchantQuickActions(screenSize: screenSize),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  "Recently Uploaded Offers",
                  style: kSmallTitleB.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                MerchantRecentOffers(screenSize: screenSize),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  "Uploaded Products",
                  style: kSmallTitleB.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                MerchantUploadedProducts(screenSize: screenSize),
                SizedBox(height: screenSize.responsivePadding(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
