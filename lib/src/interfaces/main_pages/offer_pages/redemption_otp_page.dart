import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';

class RedemptionOtpPage extends ConsumerStatefulWidget {
  const RedemptionOtpPage({super.key});

  @override
  ConsumerState<RedemptionOtpPage> createState() => _RedemptionOtpPageState();
}

class _RedemptionOtpPageState extends ConsumerState<RedemptionOtpPage> {
  final PinInputController _otpController = PinInputController();

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: kTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenSize.responsivePadding(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.responsivePadding(80)),
              Text('OTP Verification', style: kSubHeadingM.copyWith(fontSize: 22)),
              SizedBox(height: screenSize.responsivePadding(8)),
              Text(
                'Enter the 6-digit code given by the merchant\nto complete redemption.',
                style: kBodyTitleL.copyWith(color: const Color(0XFF797979)),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenSize.responsivePadding(32)),

              MaterialPinField(
                length: 6,
                pinController: _otpController,
                keyboardType: TextInputType.number,
                theme: MaterialPinTheme(
                  shape: MaterialPinShape.outlined,
                  borderRadius: BorderRadius.circular(12),
                  cellSize: const Size(42, 50),
                  focusedBorderColor: kPrimaryColor,
                  disabledBorderColor: const Color(0xFFE8E8E8),
                  borderColor: const Color(0xFFE8E8E8),
                  fillColor: kWhite,
                  filledFillColor: const Color(0xFFF7F7F7),
                  focusedFillColor: kWhite,
                  cursorColor: kPrimaryColor,
                ),
                onChanged: (value) {},
              ),

              SizedBox(height: screenSize.responsivePadding(24)),
              PrimaryButton(
                text: 'Verify',
                onPressed: () {
                  Navigator.of(context).pushNamed('redemptionVerified');
                },
              ),
              SizedBox(height: screenSize.responsivePadding(24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Resend code in ',
                    style: kSmallTitleL.copyWith(
                      color: const Color(0xFF626165),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '04:13',
                    style: kSmallTitleB.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
