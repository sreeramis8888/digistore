import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Widget _buildMenuItem(String title, Widget icon, ScreenSizeData screenSize) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(16),
          vertical: screenSize.responsivePadding(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: screenSize.responsivePadding(24),
              height: screenSize.responsivePadding(24),
              child: Center(child: icon),
            ),
            SizedBox(width: screenSize.responsivePadding(16)),
            Expanded(child: Text(title, style: kSmallTitleL)),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: screenSize.responsivePadding(14),
              color: kStrokeColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.responsivePadding(12)),
              // Header Row
              Row(
                children: [
                  Container(
                    width: screenSize.responsivePadding(50),
                    height: screenSize.responsivePadding(50),
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'M',
                      style: kLargeTitleM.copyWith(color: kWhite),
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Maria Vinaya', style: kSubHeadingM),
                            Text(
                              ' • 9998877766',
                              style: kBodyTitleM.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.responsivePadding(4)),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: kSecondaryTextColor,
                              size: 16,
                            ),
                            SizedBox(width: screenSize.responsivePadding(4)),
                            Text(
                              'Ernakulam',
                              style: kBodyTitleL.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(screenSize.responsivePadding(8)),
                    decoration: BoxDecoration(
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: kTextColor,
                      size: 20,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenSize.responsivePadding(32)),

              // First Card
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kStrokeColor),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      'My Account',
                      const Icon(
                        Icons.person_outline_rounded,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kStrokeColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'My Claimed Vouchers',
                      const Icon(
                        Icons.sell_outlined,
                        color: kSecondaryTextColor,
                        size: 22,
                      ), // or inventory_2_outlined
                      screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kStrokeColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'My Points',
                      SvgPicture.asset(
                        'assets/svg/coin.svg',
                        width: 22,
                        height: 22,
                      ),
                      screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kStrokeColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'My History',
                      const Icon(
                        Icons.history_rounded,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenSize.responsivePadding(20)),

              // Second Card
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      'Help & Support',
                      const Icon(
                        Icons.headphones_outlined,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kBorder,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'Terms & Privacy Policy',
                      const Icon(
                        Icons.description_outlined,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kBorder,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'About app',
                      const Icon(
                        Icons.info_outline_rounded,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenSize.responsivePadding(40)),
            ],
          ),
        ),
      ),
    );
  }
}
