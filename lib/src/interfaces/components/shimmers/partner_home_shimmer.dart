import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class PartnerHomeShimmer extends ConsumerWidget {
  const PartnerHomeShimmer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final baseColor = Colors.grey[200]!;
    final highlightColor = Colors.grey[50]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerRect(
          screenSize.responsivePadding(120),
          screenSize.responsivePadding(20),
          baseColor,
          highlightColor,
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == 2 ? 0 : screenSize.responsivePadding(12),
                ),
                child: _shimmerRect(
                  double.infinity,
                  screenSize.responsivePadding(90),
                  baseColor,
                  highlightColor,
                  radius: 16,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(24)),
        _shimmerRect(
          screenSize.responsivePadding(100),
          screenSize.responsivePadding(20),
          baseColor,
          highlightColor,
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        Row(
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
                  baseColor,
                  highlightColor,
                  radius: 16,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(24)),
        _shimmerRect(
          screenSize.responsivePadding(180),
          screenSize.responsivePadding(20),
          baseColor,
          highlightColor,
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        _shimmerRect(
          double.infinity,
          screenSize.responsivePadding(100),
          baseColor,
          highlightColor,
          radius: 12,
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        _shimmerRect(
          double.infinity,
          screenSize.responsivePadding(100),
          baseColor,
          highlightColor,
          radius: 12,
        ),
        SizedBox(height: screenSize.responsivePadding(24)),
        _shimmerRect(
          screenSize.responsivePadding(140),
          screenSize.responsivePadding(20),
          baseColor,
          highlightColor,
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        _shimmerRect(
          double.infinity,
          screenSize.responsivePadding(120),
          baseColor,
          highlightColor,
          radius: 12,
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
