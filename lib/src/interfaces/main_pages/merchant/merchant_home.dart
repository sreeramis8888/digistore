import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../components/home/home_search_bar.dart';
import '../../components/offers/deal_card.dart';
import '../../components/shops/shop_product_card.dart';

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
                _buildHeader(screenSize),
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
                _buildOverviewCards(screenSize),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  "Quick Actions",
                  style: kSmallTitleB.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                _buildQuickActions(screenSize),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  "Recently Uploaded Offers",
                  style: kSmallTitleB.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                _buildOffersList(screenSize),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  "Uploaded Products",
                  style: kSmallTitleB.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                _buildProductsList(screenSize),
                SizedBox(height: screenSize.responsivePadding(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ScreenSizeData screenSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/png/shake.png', fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: screenSize.responsivePadding(12)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Freshmart Supermarket', style: kSubHeadingSB),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Ernakulam',
                      style: kSmallTitleL.copyWith(
                        color: const Color(0xFF616161),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Icon(Icons.notifications_none, size: 24, color: kBlack),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(ScreenSizeData screenSize) {
    return Row(
      children: [
        _overviewCard(
          screenSize,
          "Total\nCustomers",
          "90",
          "assets/svg/total_customers.svg",
        ),
        SizedBox(width: screenSize.responsivePadding(12)),
        _overviewCard(
          screenSize,
          "Your\nCommission",
          "1.5k",
          "assets/svg/your_commission.svg",
        ),
        SizedBox(width: screenSize.responsivePadding(12)),
        _overviewCard(
          screenSize,
          "Total Sales\nvia Setgo",
          "12",
          "assets/svg/total_sales.svg",
        ),
      ],
    );
  }

  Widget _overviewCard(
    ScreenSizeData screenSize,
    String title,
    String value,
    String svgAsset,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(screenSize.responsivePadding(12)),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: kSmallTitleB.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
              maxLines: 2,
            ),
            SizedBox(height: screenSize.responsivePadding(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: kBodyTitleL.copyWith(fontSize: 24, color: kBlue),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SvgPicture.asset(
                  svgAsset,
                  height: 36,
                  width: 36,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ScreenSizeData screenSize) {
    return Row(
      children: [
        _quickActionCard(
          screenSize,
          'Verify OTP',
          Icons.qr_code_scanner,
          const Color(0xFF10B981),
        ),
        SizedBox(width: screenSize.responsivePadding(16)),
        _quickActionCard(
          screenSize,
          'Create a product',
          Icons.shopping_bag_outlined,
          const Color(0xFFEC4899),
        ),
        SizedBox(width: screenSize.responsivePadding(16)),
        _quickActionCard(
          screenSize,
          'Create a Offer',
          Icons.local_offer_outlined,
          const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _quickActionCard(
    ScreenSizeData screenSize,
    String title,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        height: 100,
        padding: EdgeInsets.all(screenSize.responsivePadding(12)),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: kWhite, size: 16),
                ),
                Icon(
                  Icons.arrow_outward,
                  size: 16,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
            Text(
              title,
              style: kSmallTitleB.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersList(ScreenSizeData screenSize) {
    return SizedBox(
      height: screenSize.responsivePadding(210),
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
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

  Widget _buildProductsList(ScreenSizeData screenSize) {
    final products = const [
      {'name': 'Fresh Juice', 'image': 'assets/png/shake.png', 'price': '₹ 30'},
      {'name': 'Onion', 'image': 'assets/png/waffle.png', 'price': '₹ 30/Kg'},
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final p = products[index];
          return SizedBox(
            width: 140,
            child: ShopProductCard(
              index: index,
              name: p['name'],
              image: p['image'],
              price: p['price'],
            ),
          );
        },
      ),
    );
  }
}
