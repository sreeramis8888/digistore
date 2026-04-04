import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../history.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
    final user = ref.watch(userProvider);
    final name = (user?.name != null && user!.name!.isNotEmpty)
        ? user.name!
        : 'Guest User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';
    final phone = (user?.phone != null && user!.phone!.isNotEmpty)
        ? user.phone!
        : '9998877766';
    final locationName = (user?.location?.district != null && user!.location!.district!.isNotEmpty)
        ? user.location!.district!
        : 'Not Set';

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
                      initial,
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
                            Text(name, style: kBodyTitleM),
                            Text(
                              ' • $phone',
                              style: kSmallTitleL.copyWith(
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
                              locationName,
                              style: kSmallTitleL.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        'myAccount',
                        arguments: {'isEditMode': true},
                      );
                    },
                    child: SvgPicture.asset('assets/svg/edit.svg'),
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
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'myAccount',
                          arguments: {'isEditMode': false},
                        );
                      },
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
                      onTap: () {
                        Navigator.pushNamed(context, 'claimedRewards');
                      },
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryPage(),
                          ),
                        );
                      },
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
