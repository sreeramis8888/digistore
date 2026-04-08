import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../home/section_title.dart';

class HomeShimmer extends ConsumerWidget {
  final bool isPartner;
  const HomeShimmer({super.key, this.isPartner = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final baseColor = Colors.grey[200]!;
    final highlightColor = Colors.grey[50]!;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isPartner ? 0 : 0),
        child: isPartner
            ? _buildPartnerShimmer(screenSize, baseColor, highlightColor)
            : _buildCustomerShimmer(screenSize, baseColor, highlightColor),
      ),
    );
  }

  Widget _buildCustomerShimmer(
    ScreenSizeData screenSize,
    Color base,
    Color highlight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.responsivePadding(24)),
        _shimmerRect(
          double.infinity,
          screenSize.responsivePadding(180),
          base,
          highlight,
          radius: 20,
          horizontalPadding: 16,
        ),
        SizedBox(height: screenSize.responsivePadding(24)),
        SectionTitle(title: 'Categories', onViewAll: () {}),
        SizedBox(height: screenSize.responsivePadding(6)),
        SizedBox(
          height: screenSize.responsivePadding(120),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, __) =>
                SizedBox(width: screenSize.responsivePadding(16)),
            itemBuilder: (_, __) => _shimmerRect(
              screenSize.responsivePadding(80),
              screenSize.responsivePadding(118),
              base,
              highlight,
              radius: 16,
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(24)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(16),
          ),
          child: Text(
            'Deal of the Hour',
            style: kBodyTitleM.copyWith(
              color: kTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        SizedBox(
          height: screenSize.responsivePadding(200),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) =>
                SizedBox(width: screenSize.responsivePadding(16)),
            itemBuilder: (_, __) => _shimmerRect(
              screenSize.responsivePadding(160),
              screenSize.responsivePadding(200),
              base,
              highlight,
              radius: 16,
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(24)),
        SectionTitle(title: 'Featured Shops', onViewAll: () {}),
        SizedBox(height: screenSize.responsivePadding(10)),
        SizedBox(
          height: screenSize.responsivePadding(120),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) =>
                SizedBox(width: screenSize.responsivePadding(16)),
            itemBuilder: (_, __) => Column(
              children: [
                _shimmerRect(
                  screenSize.responsivePadding(80),
                  screenSize.responsivePadding(80),
                  base,
                  highlight,
                  radius: 12,
                ),
                SizedBox(height: screenSize.responsivePadding(8)),
                _shimmerRect(60, 12, base, highlight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerShimmer(
    ScreenSizeData screenSize,
    Color base,
    Color highlight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.responsivePadding(16)),
        Text(
          'Welcome Back!',
          style: kSmallTitleSB.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
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
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: List.generate(
            3,
            (index) => _shimmerRect(
              double.infinity,
              double.infinity,
              base,
              highlight,
              radius: 16,
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(24)),
        Text(
          "Quick Actions",
          style: kSmallTitleB.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == 2 ? 0 : screenSize.responsivePadding(16),
                ),
                child: _shimmerRect(
                  double.infinity,
                  screenSize.responsivePadding(100),
                  base,
                  highlight,
                  radius: 16,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(24)),
        Text(
          "Recently Uploaded Offers",
          style: kSmallTitleB.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        _shimmerRect(double.infinity, 100, base, highlight, radius: 12),
        SizedBox(height: screenSize.responsivePadding(16)),
        _shimmerRect(double.infinity, 100, base, highlight, radius: 12),
      ],
    );
  }

  Widget _shimmerRect(
    double width,
    double height,
    Color base,
    Color highlight, {
    double radius = 6,
    double horizontalPadding = 0,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
