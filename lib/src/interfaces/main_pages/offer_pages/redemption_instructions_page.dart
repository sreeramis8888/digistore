import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';

class RedemptionInstructionsPage extends ConsumerWidget {
  final Map<String, dynamic>? args;
  const RedemptionInstructionsPage({super.key, this.args});

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
            Icons.arrow_back_ios_new,
            size: 20,
            color: kTextColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenSize.responsivePadding(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.responsivePadding(40)),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                  boxShadow: [
                    BoxShadow(
                      color: kGrey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      size: 64,
                      color: kPrimaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Redemption Steps',
                      style: kSubHeadingM.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 32),
                    _buildInstructionStep(
                      'Step 1',
                      'Visit the store that is providing this offer.',
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 24),
                    _buildInstructionStep(
                      'Step 2',
                      'Ask the merchant for OTP generation and share the 6-digit code sent to your phone.',
                      Icons.sms_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              PrimaryButton(
                text: 'Got it',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String step, String instruction, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: kPrimaryColor),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step,
                style: kSmallerTitleB.copyWith(
                  color: kPrimaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                instruction,
                style: kSmallerTitleM.copyWith(
                  color: kSecondaryTextColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
