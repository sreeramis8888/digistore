import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/router/nav_router.dart';

class PartnerQuickActions extends ConsumerWidget {
  final ScreenSizeData screenSize;

  const PartnerQuickActions({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _quickActionCard(
                'Verify OTP',
                'assets/svg/verify_otp.svg',
                const Color(0xFF10B981),
                onTap: () {
                  ref.read(selectedIndexProvider.notifier).updateIndex(1);
                },
              ),
              SizedBox(width: screenSize.responsivePadding(16)),
              _quickActionCard(
                'Create an Offer',
                'assets/svg/create_offer.svg',
                const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.pushNamed(context, 'createOffer');
                },
              ),
            ],
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _quickActionCard(
                'Create a product',
                'assets/svg/create_product.svg',
                const Color(0xFFEC4899),
                onTap: () {
                  Navigator.pushNamed(context, 'createProduct');
                },
              ),
              SizedBox(width: screenSize.responsivePadding(16)),
              _quickActionCard(
                'Sales Calculator',
                'assets/svg/sales_calculator.svg',
                const Color(0xFFF97316),
                onTap: () {
                  Navigator.pushNamed(context, 'salesCalculator');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard(
    String title,
    String svgAsset,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
                    child: SvgPicture.asset(
                      svgAsset,
                      width: 16,
                      height: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Icon(
                      Icons.arrow_outward,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(12)),
              Text(
                title,
                style: kSmallTitleB.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
