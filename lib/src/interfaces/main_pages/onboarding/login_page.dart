import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';
import '../../components/social_login_button.dart';
import '../../../data/services/secure_storage_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/toast_service.dart';
import '../../components/user_type_toggle.dart';
import '../../../data/providers/user_type_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final userType = ref.watch(userTypeProvider);
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
              const UserTypeToggle(),
              SizedBox(height: screenSize.responsivePadding(32)),
              Text(
                userType == UserType.customer
                    ? 'Customer Login'
                    : 'Partner Login',
                style: kSubHeadingM,
              ),
              SizedBox(height: screenSize.responsivePadding(8)),
              Text(
                'Enter Your Phone number to get started',
                style: kBodyTitleL.copyWith(color: const Color(0XFF797979)),
              ),
              SizedBox(height: screenSize.responsivePadding(32)),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: IntlPhoneField(
                      disableLengthCheck: true,
                      initialCountryCode: 'IN',
                      flagsButtonMargin: EdgeInsets.zero,
                      flagsButtonPadding: EdgeInsets.zero,
                      decoration: InputDecoration(
                        hintText: 'Enter mobile number',
                        hintStyle: kSmallTitleL.copyWith(
                          color: kGrey,
                          letterSpacing: .1,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: kPrimaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (phone) {
                        phoneNumber = phone.completeNumber;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(16)),
              PrimaryButton(
                text: 'Login',
                isLoading: ref.watch(authProvider).isLoading,
                onPressed: () async {
                  if (phoneNumber.isNotEmpty) {
                    try {
                      final storage = ref.read(secureStorageServiceProvider);
                      await storage.saveRegistrationData({
                        'phone': phoneNumber,
                      });

                      final success = await ref
                          .read(authProvider.notifier)
                          .sendOtp(phoneNumber);

                      if (success && context.mounted) {
                        Navigator.of(context).pushNamed('otp');
                      } else if (!success && context.mounted) {
                        final error =
                            ref.read(authProvider).error?.toString() ??
                            'Failed to send OTP';

                        ToastService().showToast(
                          context,
                          error.replaceAll('Exception: ', ''),
                          type: ToastType.error,
                        );
                      }
                    } catch (e, stack) {
                      // Optional: log stack trace for debugging
                      debugPrint('Send OTP Error: $e');
                      debugPrintStack(stackTrace: stack);

                      if (context.mounted) {
                        ToastService().showToast(
                          context,
                          e.toString().replaceAll('Exception: ', ''),
                          type: ToastType.error,
                        );
                      }
                    }
                  } else {
                    ToastService().showToast(
                      context,
                      'Please enter a valid phone number',
                      type: ToastType.warning,
                    );
                  }
                },
              ),
              SizedBox(height: screenSize.responsivePadding(24)),
              Text(
                'or',
                style: kSmallTitleL.copyWith(color: Color(0xFF808080)),
              ),
              SizedBox(height: screenSize.responsivePadding(24)),
              Row(
                children: [
                  Expanded(
                    child: SocialLoginButton(
                      text: 'Login with Google',
                      iconPath: 'assets/svg/google_logo.svg', // Fallback needed
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(16)),
                  Expanded(
                    child: SocialLoginButton(
                      text: 'Login with Apple',
                      iconPath: 'assets/svg/apple_logo.svg', // Fallback needed
                      onTap: () {},
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
