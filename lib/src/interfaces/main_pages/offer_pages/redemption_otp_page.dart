import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../../data/providers/offers_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/services/toast_service.dart';

class RedemptionOtpPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? args;
  const RedemptionOtpPage({super.key, this.args});

  @override
  ConsumerState<RedemptionOtpPage> createState() => _RedemptionOtpPageState();
}

class _RedemptionOtpPageState extends ConsumerState<RedemptionOtpPage> {
  final PinInputController _otpController = PinInputController();
  final TextEditingController _saleAmountController = TextEditingController();
  String otp = '';
  bool isLoading = false;

  Future<void> _verify() async {
    if (otp.length < 6) {
      ToastService().showToast(
        context,
        'Please enter 6-digit OTP',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final offerId = widget.args?['id'] as String?;
      final phone =
          widget.args?['phone'] as String? ?? ref.read(userProvider)?.phone;

      if (offerId == null || phone == null) {
        throw 'Missing offer or phone details';
      }

      final response = await ref
          .read(offersProvider.notifier)
          .verifyRedemptionOtp(
            offerId: offerId,
            userPhone: phone,
            otp: otp,
            saleAmount: double.tryParse(_saleAmountController.text.trim()),
          );

      if (response.success && mounted) {
        ToastService().showToast(context, 'Redemption successful!');
        Navigator.of(context).pushReplacementNamed(
          'partnerRedemptionSuccess',
          arguments: {
            'redemption': response.data!['data'],
            'offer': widget.args,
          },
        );
      } else {
        throw response.message ?? 'Verification failed';
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ToastService().showToast(context, e.toString(), type: ToastType.error);
      }
    }
  }

  @override
  void dispose() {
    _saleAmountController.dispose();
    super.dispose();
  }

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
              SizedBox(height: screenSize.responsivePadding(80)),
              Text(
                'OTP Verification',
                style: kSubHeadingM.copyWith(fontSize: 22),
              ),
              SizedBox(height: screenSize.responsivePadding(8)),
              Text(
                'Ask customer for the 6-digit code\nsent to their phone via SMS.',
                style: kBodyTitleL.copyWith(color: const Color(0XFF797979)),
                textAlign: TextAlign.center,
              ),

              if (widget.args?['phone'] != null) ...[
                Text(
                  'Sent to ${widget.args!['phone']}',
                  style: kSmallTitleM.copyWith(color: kPrimaryColor),
                ),
                SizedBox(height: screenSize.responsivePadding(24)),
              ],

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
                onChanged: (value) {
                  otp = value;
                },
              ),
              SizedBox(height: screenSize.responsivePadding(24)),
              PrimaryButton(
                text: 'Verify',
                isLoading: isLoading,
                onPressed: _verify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
