import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/launch_url.dart';
import '../../animations/index.dart';

class AboutAppPage extends ConsumerWidget {
  const AboutAppPage({super.key});

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
          'About App',
          style: kSubHeadingM.copyWith(color: kTextColor),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // App Logo and Name Hero
              Center(
                child: Hero(
                  tag: 'app_logo_hero',
                  child: Container(
                    width: screenSize.responsivePadding(100),
                    height: screenSize.responsivePadding(100),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3576FF), Color(0xFF33B3C5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3576FF).withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: kWhite,
                      size: 55,
                    ),
                  ),
                ),
              ).fadeIn(delayMilliseconds: 100),

              const SizedBox(height: 20),

              Text(
                'Setgo',
                style: kLargeTitleB.copyWith(fontSize: 26, letterSpacing: 0.5),
              ).fadeIn(delayMilliseconds: 150),
              
              const SizedBox(height: 6),

              Text(
                'Version 1.0.0 (Build 7)',
                style: kSmallerTitleL.copyWith(color: kSecondaryTextColor, fontWeight: FontWeight.w600),
              ).fadeIn(delayMilliseconds: 200),

              const SizedBox(height: 32),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(24),
                ),
                child: Column(
                  children: [
                    Text(
                      'Setgo is a premium rewards, offers, and loyalty platform built to connect users with their favorite local merchants and partners. Claim vouchers, track redemptions, and find the best local deals with style.',
                      style: kSmallTitleL.copyWith(
                        color: kSecondaryTextColor,
                        height: 1.6,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ).fadeIn(delayMilliseconds: 250),

                    const SizedBox(height: 40),

                    // Information details card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kStrokeColor),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            label: 'Publisher',
                            value: 'Setgo Innovations',
                          ),
                          const Divider(height: 1, color: kStrokeColor),
                          _buildDetailRow(
                            label: 'Website',
                            value: 'setgoinnovations.com',
                            onTap: () => launchURL('https://setgoinnovations.com'),
                          ),
                          const Divider(height: 1, color: kStrokeColor),
                          _buildDetailRow(
                            label: 'Support Contact',
                            value: 'anitta.babu@digistorepay.com',
                            onTap: () => launchEmail('anitta.babu@digistorepay.com'),
                          ),
                        ],
                      ),
                    ).fadeIn(delayMilliseconds: 300),

                    const SizedBox(height: 48),

                    Text(
                      '© 2026 Setgo Innovations. All rights reserved.',
                      style: kSmallerTitleL.copyWith(
                        color: kSecondaryTextColor.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ).fadeIn(delayMilliseconds: 350),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: kSmallTitleM.copyWith(color: kSecondaryTextColor, fontSize: 13.5),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                style: kSmallTitleB.copyWith(
                  color: onTap != null ? kPrimaryColor : kTextColor,
                  fontSize: 13.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
