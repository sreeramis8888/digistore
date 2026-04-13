import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class CardShimmers {
  static Widget _shimmerRect(
    double width,
    double height, {
    double radius = 8,
    EdgeInsets? margin,
    Color? baseColor,
    Color? highlightColor,
  }) {
    final base = baseColor ?? Colors.grey[200]!;
    final highlight = highlightColor ?? Colors.grey[50]!;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  static Widget _shimmerCircle(
    double size, {
    EdgeInsets? margin,
    Color? baseColor,
    Color? highlightColor,
  }) {
    final base = baseColor ?? Colors.grey[200]!;
    final highlight = highlightColor ?? Colors.grey[50]!;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: size,
        height: size,
        margin: margin,
        decoration: const BoxDecoration(
          color: kWhite,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  static Widget dealCardShimmer(ScreenSizeData screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerRect(
            double.infinity,
            screenSize.responsivePadding(120),
            radius: 12,
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.responsivePadding(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerRect(double.infinity, 16, radius: 4),
                SizedBox(height: screenSize.responsivePadding(8)),
                _shimmerRect(screenSize.width * 0.3, 12, radius: 4),
                SizedBox(height: screenSize.responsivePadding(12)),
                Row(
                  children: [
                    _shimmerCircle(screenSize.responsivePadding(20)),
                    SizedBox(width: screenSize.responsivePadding(8)),
                    _shimmerRect(screenSize.width * 0.2, 10, radius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget shopCardShimmer(ScreenSizeData screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerRect(
            double.infinity,
            screenSize.responsivePadding(120),
            radius: 12,
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.responsivePadding(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _shimmerCircle(screenSize.responsivePadding(24)),
                    SizedBox(width: screenSize.responsivePadding(8)),
                    _shimmerRect(screenSize.width * 0.25, 14, radius: 4),
                  ],
                ),
                SizedBox(height: screenSize.responsivePadding(8)),
                _shimmerRect(double.infinity, 12, radius: 4),
                SizedBox(height: screenSize.responsivePadding(4)),
                _shimmerRect(screenSize.width * 0.4, 12, radius: 4),
                SizedBox(height: screenSize.responsivePadding(8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _shimmerRect(40, 10, radius: 4),
                    _shimmerRect(30, 10, radius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget rewardCardShimmer(ScreenSizeData screenSize) {
    return Container(
      padding: EdgeInsets.all(screenSize.responsivePadding(5)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: screenSize.responsivePadding(10)),
              _shimmerRect(screenSize.width * 0.2, 14, radius: 4),
              SizedBox(height: screenSize.responsivePadding(4)),
              _shimmerRect(screenSize.width * 0.3, 10, radius: 4),
            ],
          ),
          _shimmerRect(
            screenSize.responsivePadding(60),
            screenSize.responsivePadding(60),
            radius: 8,
          ),
          _shimmerRect(
            double.infinity,
            screenSize.responsivePadding(35),
            radius: 8,
          ),
        ],
      ),
    );
  }

  static Widget transactionTileShimmer(ScreenSizeData screenSize) {
    return Container(
      margin: EdgeInsets.only(
        bottom: screenSize.responsivePadding(12),
        left: screenSize.responsivePadding(20),
        right: screenSize.responsivePadding(20),
      ),
      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _shimmerCircle(screenSize.responsivePadding(40)),
          SizedBox(width: screenSize.responsivePadding(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerRect(screenSize.width * 0.3, 14, radius: 4),
                SizedBox(height: screenSize.responsivePadding(4)),
                _shimmerRect(screenSize.width * 0.5, 12, radius: 4),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _shimmerRect(40, 14, radius: 4),
              SizedBox(height: screenSize.responsivePadding(4)),
              _shimmerRect(50, 10, radius: 4),
            ],
          ),
        ],
      ),
    );
  }

  static Widget filterChipShimmer(ScreenSizeData screenSize) {
    return Container(
      margin: EdgeInsets.only(right: screenSize.responsivePadding(8)),
      child: _shimmerRect(
        screenSize.responsivePadding(100),
        screenSize.responsivePadding(40),
        radius: 8,
      ),
    );
  }
}
