import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../../data/providers/offers_provider.dart';
import '../../../data/services/toast_service.dart';

class RedemptionInstructionsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? args;
  const RedemptionInstructionsPage({super.key, this.args});

  @override
  ConsumerState<RedemptionInstructionsPage> createState() =>
      _RedemptionInstructionsPageState();
}

class _RedemptionInstructionsPageState
    extends ConsumerState<RedemptionInstructionsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PinInputController _otpController = PinInputController();
  final TextEditingController _saleAmountController = TextEditingController();
  String _otp = '';
  String? _redemptionId;
  bool _isInitiating = false;
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    _saleAmountController.dispose();
    super.dispose();
  }

  Future<void> _initiateRedemption() async {
    final offerId = (widget.args?['id'] ?? widget.args?['_id']) as String?;
    if (offerId == null || offerId.isEmpty) {
      ToastService().showToast(
        context,
        'Invalid offer details',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isInitiating = true);

    final response = await ref
        .read(offersProvider.notifier)
        .customerInitiateRedemption(offerId);

    setState(() => _isInitiating = false);

    if (response.success && mounted) {
      final dataMap = response.data?['data'] is Map
          ? response.data!['data']
          : response.data;
      final redId = dataMap?['redemptionId'] ?? dataMap?['id'];
      if (redId != null) {
        setState(() {
          _redemptionId = redId.toString();
        });
        ToastService().showToast(
          context,
          dataMap?['message'] ?? 'OTP sent to merchant\'s phone!',
          type: ToastType.success,
        );
      } else {
        ToastService().showToast(
          context,
          dataMap?['message'] ?? 'Redemption initiated successfully',
          type: ToastType.success,
        );
      }
    } else if (mounted) {
      ToastService().showToast(
        context,
        response.message ?? 'Failed to initiate redemption',
        type: ToastType.error,
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_redemptionId == null) return;
    if (_otp.length < 6) {
      ToastService().showToast(
        context,
        'Please enter the 6-digit OTP from the merchant',
        type: ToastType.warning,
      );
      return;
    }

    if (_formKey.currentState?.validate() == false) return;

    setState(() => _isVerifying = true);

    final response = await ref
        .read(offersProvider.notifier)
        .customerVerifyRedemptionOtp(
          redemptionId: _redemptionId!,
          otp: _otp,
          saleAmount: double.tryParse(_saleAmountController.text.trim()),
        );

    setState(() => _isVerifying = false);

    if (response.success && mounted) {
      ToastService().showToast(
        context,
        'Redemption completed successfully!',
        type: ToastType.success,
      );
      Navigator.of(context).pushReplacementNamed(
        'partnerRedemptionSuccess',
        arguments: {
          'redemption': response.data?['data'] ?? response.data,
          'offer': widget.args,
        },
      );
    } else if (mounted) {
      ToastService().showToast(
        context,
        response.message ?? 'Verification failed',
        type: ToastType.error,
      );
    }
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
              SizedBox(height: screenSize.responsivePadding(20)),
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
                      _redemptionId == null
                          ? 'Redemption Steps'
                          : 'Enter Merchant OTP',
                      style: kSubHeadingM.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 32),
                    if (_redemptionId == null) ...[
                      _buildInstructionStep(
                        'Step 1',
                        'Visit the store that is providing this offer.',
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 24),
                      _buildInstructionStep(
                        'Step 2',
                        'Ask the merchant and click below to send an OTP to their phone.',
                        Icons.sms_outlined,
                      ),
                    ] else ...[
                      Text(
                        'We sent a 6-digit code to the merchant\'s phone. Ask the merchant for the code and enter it below to complete redemption.',
                        style: kSmallerTitleM.copyWith(
                          color: kSecondaryTextColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            PrimaryTextField(
                              controller: _saleAmountController,
                              label: 'Bill / Sale Amount (Optional)',
                              hint: 'Enter amount (₹)',
                              type: TextFieldType.number,
                              prefixIcon: const Icon(
                                Icons.currency_rupee_rounded,
                                color: kPrimaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: MaterialPinField(
                                length: 6,
                                pinController: _otpController,
                                keyboardType: TextInputType.number,
                                theme: MaterialPinTheme(
                                  shape: MaterialPinShape.outlined,
                                  borderRadius: BorderRadius.circular(12),
                                  cellSize: const Size(42, 50),
                                  focusedBorderColor: kPrimaryColor,
                                  disabledBorderColor: const Color(0xFFE2E8F0),
                                  borderColor: const Color(0xFFE2E8F0),
                                  fillColor: kWhite,
                                  filledFillColor: const Color(0xFFF8FAFC),
                                  focusedFillColor: kWhite,
                                  cursorColor: kPrimaryColor,
                                ),
                                onChanged: (value) => _otp = value,
                                onCompleted: (value) => _otp = value,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
              if (_redemptionId == null) ...[
                PrimaryButton(
                  text: 'Initiate Redemption (Send OTP)',
                  isLoading: _isInitiating,
                  onPressed: _initiateRedemption,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: kSmallerTitleM.copyWith(color: kSecondaryTextColor),
                  ),
                ),
              ] else ...[
                PrimaryButton(
                  text: 'Verify & Complete Redemption',
                  isLoading: _isVerifying,
                  onPressed: _verifyOtp,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _redemptionId = null),
                  child: Text(
                    'Cancel / Go Back',
                    style: kSmallerTitleM.copyWith(color: kSecondaryTextColor),
                  ),
                ),
              ],
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
