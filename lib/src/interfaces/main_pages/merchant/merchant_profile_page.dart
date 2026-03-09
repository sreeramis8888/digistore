import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';

class MerchantProfilePage extends ConsumerWidget {
  const MerchantProfilePage({super.key});

  Widget _buildMenuItem(
    String title,
    Widget icon,
    ScreenSizeData screenSize, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
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
            Expanded(
              child: Text(title, style: kSmallTitleL.copyWith(color: kBlack)),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: screenSize.responsivePadding(14),
              color: const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    ScreenSizeData screenSize,
    String title,
    IconData iconData,
  ) {
    return Expanded(
      child: Container(
        height: screenSize.responsivePadding(90),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: const Color(0xFF6B7280), size: 24),
            SizedBox(height: screenSize.responsivePadding(8)),
            Text(
              title,
              style: kSmallTitleL.copyWith(
                color: kBlack,
                fontWeight: FontWeight.w500,
              ),
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
        centerTitle: false,
        titleSpacing: 0,
        title: Text('Profile', style: kSubHeadingSB.copyWith(fontSize: 16)),
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
              SizedBox(height: screenSize.responsivePadding(16)),
              Container(
                padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/png/shake.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.storefront,
                                color: kSecondaryColor,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenSize.responsivePadding(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Freshmart Supermarket',
                                  style: kBodyTitleM.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryLightColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Daily Needs',
                                  style: kSmallTitleL.copyWith(
                                    fontSize: 10,
                                    color: kSecondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ernakulam',
                                style: kSmallTitleL.copyWith(
                                  color: const Color(0xFF616161),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'merchantAccount',
                          arguments: {'isEditMode': true},
                        );
                      },
                      child: SvgPicture.asset('assets/svg/edit.svg'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(16)),
              Row(
                children: [
                  _buildActionCard(
                    screenSize,
                    'Offers',
                    Icons.discount_outlined,
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  _buildActionCard(
                    screenSize,
                    'Products',
                    Icons.inventory_2_outlined,
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  _buildActionCard(
                    screenSize,
                    'History',
                    Icons.history_rounded,
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(16)),
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      'Account',
                      const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'merchantAccount',
                          arguments: {'isEditMode': false},
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'Help & Support',
                      const Icon(
                        Icons.headphones_outlined,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'Terms & Privacy Policy',
                      const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'About app',
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'FAQ',
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(16)),
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: _buildMenuItem(
                  'Logout',
                  const Icon(
                    Icons.headphones_outlined,
                    color: Color(0xFF6B7280),
                    size: 22,
                  ),
                  screenSize,
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
