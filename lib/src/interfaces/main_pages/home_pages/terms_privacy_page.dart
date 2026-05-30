import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../animations/index.dart';

class TermsPrivacyPage extends ConsumerWidget {
  const TermsPrivacyPage({super.key});

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
          'Terms & Privacy Policy',
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
                    _buildSection(
                      title: '1. Introduction',
                      body: 'Welcome to Setgo. By accessing and using our application, you agree to comply with and be bound by the following terms and conditions. Please read them carefully.',
                    ).fadeIn(delayMilliseconds: 100),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: '2. User Accounts',
                      body: 'To use certain features of the app, you must register for an account using your mobile phone number. You are responsible for maintaining the confidentiality of your account details and verifying information correct to the best of your knowledge.',
                    ).fadeIn(delayMilliseconds: 150),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: '3. Loyalty Points and Rewards',
                      body: 'Loyalty points, vouchers, and rewards claimed through Setgo are subject to merchant availability and specific terms set by partners. Points have no monetary cash value and are non-transferable.',
                    ).fadeIn(delayMilliseconds: 200),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: '4. Privacy & Data Collection',
                      body: 'We respect your privacy and process personal details (e.g. name, location, phone number) in accordance with industry standards. Data is used to customize deals near you and improve in-app experiences.',
                    ).fadeIn(delayMilliseconds: 250),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: '5. Changes to Terms',
                      body: 'Setgo Innovations reserves the right to modify these terms at any time. Continued usage of the application following updates constitutes your acceptance of the revised policies.',
                    ).fadeIn(delayMilliseconds: 300),
                    const SizedBox(height: 40),
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
          colors: [Color(0xFF33B3C5), Color(0xFF1E3A81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A81).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
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
                        'Terms & Privacy',
                        style: kLargeTitleB.copyWith(
                          color: kWhite,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: screenSize.responsivePadding(8)),
                      Text(
                        'Last updated: May 2026. Learn about your rights, data security, and service rules.',
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
                    Icons.gavel_rounded,
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

  Widget _buildSection({required String title, required String body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kStrokeColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: kSmallTitleB.copyWith(color: kTextColor, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: kSmallTitleL.copyWith(
              color: kSecondaryTextColor,
              height: 1.5,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}
