import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/toast_service.dart';
import '../../../data/services/secure_storage_service.dart';
import '../../../data/providers/user_type_provider.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final PinInputController _otpController = PinInputController();
  String otp = '';
  late Future<Map<String, dynamic>?> _registrationDataFuture;

  @override
  void initState() {
    super.initState();
    _registrationDataFuture = ref.read(secureStorageServiceProvider).getRegistrationData();
  }

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
              FutureBuilder<Map<String, dynamic>?>(
                future: _registrationDataFuture,
                builder: (context, snapshot) {
                  final devOtp = snapshot.data?['devOtp'];
                  if (devOtp != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Testing OTP: $devOtp',
                        style: kBodyTitleM.copyWith(color: kPrimaryColor),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
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
                onChanged: (value) {
                  otp = value;
                },
              ),

              SizedBox(height: screenSize.responsivePadding(24)),
              PrimaryButton(
                text: 'Verify',
                isLoading: ref.watch(authProvider).isLoading,
                onPressed: () async {
                  if (otp.length == 6) {
                    final storage = ref.read(secureStorageServiceProvider);
                    final data = await storage.getRegistrationData();
                    final phone = data?['phone'] ?? '';
                    
                    if (phone.isNotEmpty) {
                      final result = await ref.read(authProvider.notifier).verifyOtp(phone, otp);
                      if (result['success'] == true && context.mounted) {
                        await storage.clearRegistrationData();
                        final userType = ref.read(userTypeProvider);
                        if (result['onboardingComplete'] == false && userType == UserType.customer) {
                          Navigator.of(context).pushNamed('profileSetup');
                        } else {
                          // For partners or completed customers, go to navbar
                          Navigator.of(context).pushNamedAndRemoveUntil('navbar', (route) => false);
                        }
                      } else if (result['success'] == false && context.mounted) {
                        ToastService().showToast(
                          context, 
                          (result['message'] as String).replaceAll('Exception: ', ''), 
                          type: ToastType.error,
                        );
                      }
                    } else {
                      ToastService().showToast(
                        context, 
                        'Phone number not found. Please login again.', 
                        type: ToastType.error,
                      );
                    }
                  } else {
                    ToastService().showToast(
                      context, 
                      'Please enter a valid 6-digit OTP', 
                      type: ToastType.warning,
                    );
                  }
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
