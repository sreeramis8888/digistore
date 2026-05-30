import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/launch_url.dart';
import '../../animations/index.dart';

class HelpSupportPage extends ConsumerWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: kSubHeadingM.copyWith(color: kTextColor),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Premium Header Gradient Hero
              _buildHeaderSection(screenSize),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16),
                  vertical: screenSize.responsivePadding(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Direct Contacts Grid
                    Text(
                      'Contact Channels',
                      style: kBodyTitleM.copyWith(fontWeight: FontWeight.bold),
                    ).fadeIn(delayMilliseconds: 100),
                    SizedBox(height: screenSize.responsivePadding(12)),
                    _buildContactGrid(screenSize),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ScreenSizeData screenSize) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(8),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3576FF), Color(0xFF1E3A81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A81).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: kWhite.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: kWhite.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.responsivePadding(24)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How can we help\nyou today?',
                        style: kLargeTitleB.copyWith(
                          color: kWhite,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: screenSize.responsivePadding(8)),
                      Text(
                        'Get instant answers, view help guides, or talk to our active customer agents.',
                        style: kSmallerTitleL.copyWith(
                          color: kWhite.withOpacity(0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenSize.responsivePadding(16)),
                Container(
                  padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                  decoration: BoxDecoration(
                    color: kWhite.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: kWhite,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).fadeIn();
  }

  Widget _buildContactGrid(ScreenSizeData screenSize) {
    return Column(
      children: [
        _buildContactCard(
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF2B74E1),
          bgColor: const Color(0xFFEDF4FF),
          title: 'Visit Website',
          value: 'setgoinnovations.com',
          onTap: () => launchURL('https://setgoinnovations.com'),
        ),
        SizedBox(height: screenSize.responsivePadding(12)),
        _buildContactCard(
          icon: Icons.email_outlined,
          iconColor: const Color(0xFFFF6900),
          bgColor: const Color(0xFFFFF1E6),
          title: 'Email Us',
          value: 'contact@setgo.in',
          onTap: () => launchEmail('contact@setgo.in'),
        ),
        SizedBox(height: screenSize.responsivePadding(12)),
        _buildContactCard(
          icon: Icons.phone_in_talk_outlined,
          iconColor: kGreen,
          bgColor: const Color(0xFFE8F8EB),
          title: 'Call Support',
          value: '+918606172633',
          onTap: () => launchPhone('+918606172633'),
        ),
      ],
    ).fadeIn(delayMilliseconds: 180);
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kStrokeColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: kSmallTitleB.copyWith(color: kTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: kSmallTitleL.copyWith(
                      color: kSecondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: kStrokeColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
