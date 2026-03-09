import 'package:flutter/material.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/offers/deal_card.dart';

class MerchantRecentOffers extends StatelessWidget {
  final ScreenSizeData screenSize;

  const MerchantRecentOffers({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenSize.responsivePadding(210),
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: const [
          SizedBox(
            width: 160,
            child: DealCard(
              title: 'Big Grocery Savings',
              subtitle: 'Shop for ₹500 or more and Save ₹100',
              shopName: 'DailyMart',
              badgeText: '₹100\nOFF',
              avatarColor: kPrimaryLightColor,
              hideShopName: true,
            ),
          ),
          SizedBox(width: 16),
          SizedBox(
            width: 160,
            child: DealCard(
              title: 'Fresh Bakes Deal',
              subtitle: 'Buy one bun Get one free',
              shopName: 'Fresh Bakes',
              badgeText: 'BUY 1\nGET 1',
              avatarColor: kPrimaryLightColor,
              hideShopName: true,
            ),
          ),
        ],
      ),
    );
  }
}
