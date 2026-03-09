import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../components/merchant/merchant_menu_item.dart';
import '../../components/merchant/merchant_action_card.dart';
import '../../components/merchant/merchant_profile_header.dart';

class MerchantProfilePage extends ConsumerWidget {
  const MerchantProfilePage({super.key});

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
              MerchantProfileHeader(screenSize: screenSize),
              SizedBox(height: screenSize.responsivePadding(16)),
              Row(
                children: [
                  MerchantActionCard(
                    screenSize: screenSize,
                    title: 'Offers',
                    iconData: Icons.discount_outlined,
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  MerchantActionCard(
                    screenSize: screenSize,
                    title: 'Products',
                    iconData: Icons.inventory_2_outlined,
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  MerchantActionCard(
                    screenSize: screenSize,
                    title: 'History',
                    iconData: Icons.history_rounded,
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
                    MerchantMenuItem(
                      title: 'Account',
                      icon: const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize: screenSize,
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
                    MerchantMenuItem(
                      title: 'Help & Support',
                      icon: const Icon(
                        Icons.headphones_outlined,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize: screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    MerchantMenuItem(
                      title: 'Terms & Privacy Policy',
                      icon: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize: screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    MerchantMenuItem(
                      title: 'About app',
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize: screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    MerchantMenuItem(
                      title: 'FAQ',
                      icon: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize: screenSize,
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
                child: MerchantMenuItem(
                  title: 'Logout',
                  icon: const Icon(
                    Icons.headphones_outlined,
                    color: Color(0xFF6B7280),
                    size: 22,
                  ),
                  screenSize: screenSize,
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
