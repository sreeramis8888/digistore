import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/utils/global_variables.dart';
import '../../components/partner/partner_menu_item.dart';
import '../../components/partner/partner_action_card.dart';
import '../../components/partner/partner_profile_header.dart';

class PartnerProfilePage extends ConsumerWidget {
  const PartnerProfilePage({super.key});

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
              PartnerProfileHeader(screenSize: screenSize),
              SizedBox(height: screenSize.responsivePadding(16)),
              Row(
                children: [
                  PartnerActionCard(
                    screenSize: screenSize,
                    title: 'Offers',
                    iconData: Icons.discount_outlined,
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  PartnerActionCard(
                    screenSize: screenSize,
                    title: 'Products',
                    iconData: Icons.inventory_2_outlined,
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  PartnerActionCard(
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
                    PartnerMenuItem(
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
                          'partnerAccount',
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
                    PartnerMenuItem(
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
                    PartnerMenuItem(
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
                    PartnerMenuItem(
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
                    PartnerMenuItem(
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
                child: PartnerMenuItem(
                  title: 'Logout',
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: kRed,
                    size: 22,
                  ),
                  screenSize: screenSize,
                  onTap: () async {
                    await ref.read(userProvider.notifier).clearUser();
                    ref.read(partnerProvider.notifier).clearPartner();
                    GlobalVariables.clear();
                    GlobalVariables.setPartnerMode(false);
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        'login',
                        (route) => false,
                      );
                    }
                  },
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
