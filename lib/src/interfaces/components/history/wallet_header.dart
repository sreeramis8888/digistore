import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class WalletHeader extends ConsumerWidget {
  const WalletHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Padding(
      padding: EdgeInsets.all(screenSize.responsivePadding(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ABDUL WAHAAB',
                  style: kHeadTitleB,
                ),
                SizedBox(height: screenSize.responsivePadding(4)),
                Text(
                  'Your available points:',
                  style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
              vertical: screenSize.responsivePadding(10),
            ),
            decoration: BoxDecoration(
              color: kBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 20),
                SizedBox(width: screenSize.responsivePadding(8)),
                Text(
                  '3000',
                  style: kHeadTitleB.copyWith(color: kWhite),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
