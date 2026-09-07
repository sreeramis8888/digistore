import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';

class ShopAbout extends ConsumerWidget {
  final ShopModel? shop;

  const ShopAbout({super.key, this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final description = shop?.businessInfo?.description ?? 
        'Offering premium services in ${shop?.businessDetails?.businessType ?? 'Shop'} category.';

    final specialties = shop?.businessInfo?.specialties ?? [];
    final achievements = shop?.businessInfo?.achievements ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: kSmallTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Text(
          description,
          style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
        ),
        if (specialties.isNotEmpty) ...[
          SizedBox(height: screenSize.responsivePadding(16)),
          Text('Specialties', style: kSmallTitleM.copyWith(fontSize: 13)),
          SizedBox(height: screenSize.responsivePadding(8)),
          Wrap(
            spacing: screenSize.responsivePadding(6),
            runSpacing: screenSize.responsivePadding(6),
            children: specialties.map((s) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(10),
                  vertical: screenSize.responsivePadding(4),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  s,
                  style: kSmallerTitleL.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF374151),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (achievements.isNotEmpty) ...[
          SizedBox(height: screenSize.responsivePadding(16)),
          Text('Highlights & Achievements', style: kSmallTitleM.copyWith(fontSize: 13)),
          SizedBox(height: screenSize.responsivePadding(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: achievements.map((a) {
              return Padding(
                padding: EdgeInsets.only(bottom: screenSize.responsivePadding(6)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: kPrimaryColor,
                      ),
                    ),
                    SizedBox(width: screenSize.responsivePadding(6)),
                    Expanded(
                      child: Text(
                        a,
                        style: kSmallerTitleL.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
