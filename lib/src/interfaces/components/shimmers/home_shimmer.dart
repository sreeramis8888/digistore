import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../home/section_title.dart';

class HomeShimmer extends ConsumerWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final baseColor = Colors.grey[200]!;
    final highlightColor = Colors.grey[50]!;

    return _buildCustomerShimmer(screenSize, baseColor, highlightColor);
  }

  Widget _buildCustomerShimmer(
    ScreenSizeData screenSize,
    Color base,
    Color highlight,
  ) {
    final hPad = screenSize.responsivePadding(16);
    final gap = screenSize.responsivePadding(12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.responsivePadding(20)),
        const SectionTitle(title: 'Deal of the Hour', revampStyle: true),
        SizedBox(height: screenSize.responsivePadding(8)),
        SizedBox(
          height: screenSize.responsivePadding(290),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => SizedBox(width: gap),
            itemBuilder: (_, _) => _shimmerRect(
              screenSize.responsivePadding(200),
              screenSize.responsivePadding(290),
              base,
              highlight,
              radius: 20,
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(28)),
        const SectionTitle(title: 'Explore Categories', revampStyle: true),
        SizedBox(height: screenSize.responsivePadding(8)),
        SizedBox(
          height: screenSize.responsivePadding(126),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, _) => SizedBox(width: gap),
            itemBuilder: (_, _) => _shimmerRect(
              screenSize.responsivePadding(140),
              screenSize.responsivePadding(126),
              base,
              highlight,
              radius: 16,
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(28)),
        const SectionTitle(title: 'Featured Shops', revampStyle: true),
        SizedBox(height: screenSize.responsivePadding(8)),
        SizedBox(
          height: screenSize.responsivePadding(146),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => SizedBox(width: gap),
            itemBuilder: (_, _) => _shimmerRect(
              screenSize.responsivePadding(160),
              screenSize.responsivePadding(146),
              base,
              highlight,
              radius: 20,
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(24)),
        const SectionTitle(title: 'Rewards For You', revampStyle: true),
        SizedBox(height: screenSize.responsivePadding(8)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            children: List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: i == 2 ? 0 : 10),
                child: _shimmerRect(
                  double.infinity,
                  84,
                  base,
                  highlight,
                  radius: 16,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(40)),
      ],
    );
  }

  Widget _shimmerRect(
    double width,
    double height,
    Color base,
    Color highlight, {
    double radius = 6,
  }) {
    return Shimmer.fromColors(
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
    );
  }
}
