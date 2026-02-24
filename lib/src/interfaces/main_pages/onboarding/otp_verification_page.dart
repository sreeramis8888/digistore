import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final PinInputController _otpController = PinInputController();

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenSize.responsivePadding(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.responsivePadding(40)),
              Image.asset(
                'assets/png/setgo.png',
                height: screenSize.responsivePadding(80),
              ),
              SizedBox(height: screenSize.responsivePadding(8)),
              Text(
                'Spend Local. Save Big.',
                style: kSmallerTitleL.copyWith(
                  color: kSecondaryTextColor,
                  fontSize: 10,
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(40)),
              Text('OTP Verification', style: kSubHeadingM),
              SizedBox(height: screenSize.responsivePadding(8)),
              Text(
                'Enter the verification code sent to your number',
                style: kBodyTitleL.copyWith(color: Color(0XFF797979)),
              ),

              SizedBox(height: screenSize.responsivePadding(32)),

              MaterialPinField(
                length: 6,
                pinController: _otpController,
                keyboardType: TextInputType.number,
                theme: MaterialPinTheme(
                  shape: MaterialPinShape.outlined,
                  borderRadius: BorderRadius.circular(12),
                  cellSize: const Size(45, 50),
                  focusedBorderColor: kPrimaryColor,
                  disabledBorderColor: Color(0xFFF7F4F4),
                  borderColor: Color(0xFFF7F4F4),
                  fillColor: Color(0xFFF7F4F4),
                  filledFillColor: const Color(0xFFF5F5F5),
                  focusedFillColor: Color(0xFFF7F4F4),
                  cursorColor: kPrimaryColor,
                ),
                onChanged: (value) {},
              ),

              SizedBox(height: screenSize.responsivePadding(24)),
              PrimaryButton(
                text: 'Verify',
                onPressed: () {
                  Navigator.of(context).pushNamed('profileSetup');
                },
              ),
              SizedBox(height: screenSize.responsivePadding(24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Resend code in ',
                    style: kSmallTitleL.copyWith(
                      color: Color(0xFF626165),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '04:13',
                    style: kBodyTitleM.copyWith(
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
