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
        const Text(
          'About',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(10)),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        if (specialties.isNotEmpty) ...[
          SizedBox(height: screenSize.responsivePadding(14)),
          const Text(
            'Specialties',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(8)),
          Wrap(
            spacing: screenSize.responsivePadding(8),
            runSpacing: screenSize.responsivePadding(8),
            children: specialties.map((s) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(12),
                  vertical: screenSize.responsivePadding(5),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (achievements.isNotEmpty) ...[
          SizedBox(height: screenSize.responsivePadding(14)),
          const Text(
            'Highlights & Achievements',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
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
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Color(0xFF07982C),
                      ),
                    ),
                    SizedBox(width: screenSize.responsivePadding(8)),
                    Expanded(
                      child: Text(
                        a,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
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
