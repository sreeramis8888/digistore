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

  static Widget productCardShimmer(ScreenSizeData screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: _shimmerRect(
                double.infinity,
                double.infinity,
                radius: 0,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.responsivePadding(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerRect(double.infinity, 14, radius: 4),
                SizedBox(height: screenSize.responsivePadding(8)),
                _shimmerRect(screenSize.width * 0.15, 14, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget partnerRedemptionItemShimmer(ScreenSizeData screenSize) {
    return Container(
      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerRect(50, 50, radius: 8),
              SizedBox(width: screenSize.responsivePadding(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerRect(120, 16, radius: 4),
                    SizedBox(height: screenSize.responsivePadding(4)),
                    _shimmerRect(80, 12, radius: 4),
                  ],
                ),
              ),
              _shimmerRect(60, 12, radius: 4),
            ],
          ),
          SizedBox(height: screenSize.responsivePadding(10)),
          const Divider(color: Color(0xFFDFDFDF), height: .5),
          SizedBox(height: screenSize.responsivePadding(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerRect(100, 10, radius: 2),
              _shimmerRect(60, 10, radius: 2),
            ],
          ),
        ],
      ),
    );
  }

  static Widget partnerHistoryShimmer(ScreenSizeData screenSize) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenSize.responsivePadding(8)),
            _shimmerRect(180, 16, radius: 4),
            SizedBox(height: screenSize.responsivePadding(16)),
            Row(
              children: [
                Expanded(child: _shimmerRect(double.infinity, 100, radius: 16)),
                SizedBox(width: screenSize.responsivePadding(12)),
                Expanded(child: _shimmerRect(double.infinity, 100, radius: 16)),
                SizedBox(width: screenSize.responsivePadding(12)),
                Expanded(child: _shimmerRect(double.infinity, 100, radius: 16)),
              ],
            ),
            SizedBox(height: screenSize.responsivePadding(24)),
            _shimmerRect(140, 14, radius: 4),
            SizedBox(height: screenSize.responsivePadding(12)),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 4,
              separatorBuilder: (context, index) =>
                  SizedBox(height: screenSize.responsivePadding(12)),
              itemBuilder: (context, index) {
                return partnerRedemptionItemShimmer(screenSize);
              },
            ),
          ],
        ),
      ),
    );
  }
}
