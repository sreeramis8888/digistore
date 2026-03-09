import 'package:flutter/material.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class MerchantQuickActions extends StatelessWidget {
  final ScreenSizeData screenSize;

  const MerchantQuickActions({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _quickActionCard(
          'Verify OTP',
          Icons.qr_code_scanner,
          const Color(0xFF10B981),
        ),
        SizedBox(width: screenSize.responsivePadding(16)),
        _quickActionCard(
          'Create a product',
          Icons.shopping_bag_outlined,
          const Color(0xFFEC4899),
        ),
        SizedBox(width: screenSize.responsivePadding(16)),
        _quickActionCard(
          'Create a Offer',
          Icons.local_offer_outlined,
          const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _quickActionCard(String title, IconData icon, Color color) {
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
                const Icon(
                  Icons.arrow_outward,
                  size: 16,
                  color: Color(0xFF9CA3AF),
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
}
