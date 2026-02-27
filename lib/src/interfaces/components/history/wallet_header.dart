import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletHeader extends ConsumerWidget {
  const WalletHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final user = ref.watch(userProvider);
    final name = (user?.name != null && user!.name!.isNotEmpty) ? user.name!.toUpperCase() : 'ABDUL WAHAAB';

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
                  name,
                  style: kHeadTitleM.copyWith(color: Color(0xFF3E3D40)),
                ),
                SizedBox(height: screenSize.responsivePadding(4)),
                Text(
                  'Your available points:',
                  style: kSmallTitleR.copyWith(
                    color: Color(0xFF6B7276),
                    letterSpacing: .1,
                  ),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF709EFF), Color(0xFF3576FF)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SvgPicture.asset('assets/svg/coin.svg', width: 20, height: 20),
                SizedBox(width: screenSize.responsivePadding(8)),
                Text('3000', style: kHeadTitleB.copyWith(color: kWhite)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
