import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../components/offers/offers_filter_chips.dart';
import '../components/cards/deal_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/screen_size_provider.dart';

class OffersPage extends ConsumerWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final offers = [
      {'title': 'Fresh Bakes Deal', 'subtitle': 'Buy one bun Get one free', 'shopName': 'HomeGoods', 'badge': 'BUY 1\nGET 1', 'deal': 'Deal of the Hour', 'color': Colors.indigo},
      {'title': 'Special Salon Offer', 'subtitle': 'Try any haircut Get 30% off', 'shopName': 'Glow Saloon', 'badge': '30%\nOFF', 'deal': null, 'color': Colors.blueGrey},
      {'title': 'Big Grocery Savings', 'subtitle': 'Shop for ₹500 or more and Save ₹100', 'shopName': 'DailyMart', 'badge': '₹100\nOFF', 'deal': null, 'color': Colors.indigo},
      {'title': 'Big Grocery Savings', 'subtitle': 'Shop for ₹500 or more and Save ₹100', 'shopName': 'DailyMart', 'badge': '₹100\nOFF', 'deal': 'Deal of the Hour', 'color': Colors.indigo},
      {'title': 'Big Grocery Savings', 'subtitle': 'Shop for ₹500 or more and Save ₹100', 'shopName': 'DailyMart', 'badge': '₹100\nOFF', 'deal': null, 'color': Colors.indigo},
      {'title': 'Beverage Bonanza', 'subtitle': 'Mix and match 3 drinks -> Get 20% Off', 'shopName': 'DailyMart', 'badge': '20%\nOFF', 'deal': null, 'color': Colors.indigo},
    ];

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text('Offers',  style: kSubHeadingM.copyWith(color: Color(0xFF373737)),),
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const OffersFilterChips(),
            SizedBox(height: screenSize.responsivePadding(16)),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: screenSize.responsivePadding(16),
                  crossAxisSpacing: screenSize.responsivePadding(16),
                  childAspectRatio: 0.65, 
                ),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final o = offers[index];
                  return DealCard(
                    title: o['title'] as String,
                    subtitle: o['subtitle'] as String,
                    shopName: o['shopName'] as String,
                    badgeText: o['badge'] as String,
                    dealOfTheHour: o['deal'] as String?,
                    avatarColor: o['color'] as Color,
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
