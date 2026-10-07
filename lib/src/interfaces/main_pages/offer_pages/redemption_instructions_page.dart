import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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

enum _RedemptionView { instructions, otp, qr }

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
  bool _isInitiatingOtp = false;
  bool _isGeneratingQr = false;
  bool _isVerifying = false;

  _RedemptionView _view = _RedemptionView.instructions;
  Uint8List? _qrImageBytes;
  DateTime? _qrExpiresAt;
  Timer? _qrTicker;
  Duration _qrRemaining = Duration.zero;

  @override
  void dispose() {
    _qrTicker?.cancel();
    _otpController.dispose();
    _saleAmountController.dispose();
    super.dispose();
  }

  String? get _offerId {
    final id = widget.args?['id'] ?? widget.args?['_id'];
    return id?.toString();
  }

  void _resetToInstructions() {
    _qrTicker?.cancel();
    setState(() {
      _view = _RedemptionView.instructions;
      _redemptionId = null;
      _qrImageBytes = null;
      _qrExpiresAt = null;
      _qrRemaining = Duration.zero;
      _otp = '';
      _otpController.clear();
    });
  }

  void _startQrCountdown(DateTime expiresAt) {
    _qrTicker?.cancel();
    void tick() {
      final left = expiresAt.difference(DateTime.now());
      if (!mounted) return;
      setState(() {
        _qrRemaining = left.isNegative ? Duration.zero : left;
      });
      if (left.isNegative || left == Duration.zero) {
        _qrTicker?.cancel();
      }
    }

    tick();
    _qrTicker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  Uint8List? _decodeQrDataUrl(String? dataUrl) {
    if (dataUrl == null || dataUrl.isEmpty) return null;
    final marker = 'base64,';
    final idx = dataUrl.indexOf(marker);
    final raw = idx >= 0 ? dataUrl.substring(idx + marker.length) : dataUrl;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _initiateRedemption() async {
    final offerId = _offerId;
    if (offerId == null || offerId.isEmpty) {
      ToastService().showToast(
        context,
        'Invalid offer details',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isInitiatingOtp = true);

    final response = await ref
        .read(offersProvider.notifier)
        .customerInitiateRedemption(offerId);

    setState(() => _isInitiatingOtp = false);

    if (response.success && mounted) {
      final dataMap = response.data?['data'] is Map
          ? response.data!['data']
          : response.data;
      final redId = dataMap?['redemptionId'] ?? dataMap?['id'];
      if (redId != null) {
        setState(() {
          _redemptionId = redId.toString();
          _view = _RedemptionView.otp;
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

  Future<void> _generateQr() async {
    final offerId = _offerId;
    if (offerId == null || offerId.isEmpty) {
      ToastService().showToast(
        context,
        'Invalid offer details',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isGeneratingQr = true);

    final response = await ref
        .read(offersProvider.notifier)
        .customerInitiateQrRedemption(offerId);

    setState(() => _isGeneratingQr = false);

    if (!mounted) return;

    if (response.success) {
      final dataMap = response.data?['data'] is Map
          ? Map<String, dynamic>.from(response.data!['data'] as Map)
          : (response.data is Map
                ? Map<String, dynamic>.from(response.data as Map)
                : <String, dynamic>{});

      final qrBytes = _decodeQrDataUrl(dataMap['qrCode']?.toString());
      if (qrBytes == null) {
        ToastService().showToast(
          context,
          'QR code could not be generated. Please try again.',
          type: ToastType.error,
        );
        return;
      }

      DateTime? expiresAt;
      final rawExpiry = dataMap['expiresAt'];
      if (rawExpiry != null) {
        expiresAt = DateTime.tryParse(rawExpiry.toString())?.toLocal();
      }
      expiresAt ??= DateTime.now().add(const Duration(minutes: 5));

      setState(() {
        _redemptionId = (dataMap['redemptionId'] ?? dataMap['id'])?.toString();
        _qrImageBytes = qrBytes;
        _qrExpiresAt = expiresAt;
        _view = _RedemptionView.qr;
      });
      _startQrCountdown(expiresAt);

      ToastService().showToast(
        context,
        dataMap['message']?.toString() ??
            'Show this QR code to the partner for scanning',
        type: ToastType.success,
      );
    } else {
      ToastService().showToast(
        context,
        response.message ?? 'Failed to generate QR code',
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

  String _formatRemaining(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final title = switch (_view) {
      _RedemptionView.instructions => 'Redemption Steps',
      _RedemptionView.otp => 'Enter Merchant OTP',
      _RedemptionView.qr => 'Show QR to Merchant',
    };

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
                      color: kGrey.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _view == _RedemptionView.qr
                          ? Icons.qr_code_2_rounded
                          : Icons.storefront_rounded,
                      size: 64,
                      color: kPrimaryColor,
                    ),
                    const SizedBox(height: 24),
                    Text(title, style: kSubHeadingM.copyWith(fontSize: 22)),
                    const SizedBox(height: 32),
                    if (_view == _RedemptionView.instructions) ...[
                      _buildInstructionStep(
                        'Step 1',
                        'Visit the store that is providing this offer.',
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 24),
                      _buildInstructionStep(
                        'Step 2',
                        'Ask the merchant and click below to send an OTP to their phone, or generate a QR for them to scan.',
                        Icons.sms_outlined,
                      ),
                    ] else if (_view == _RedemptionView.otp) ...[
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
                    ] else ...[
                      Text(
                        'Show this QR code to the cashier. They will scan it in the partner app to complete your redemption.',
                        style: kSmallerTitleM.copyWith(
                          color: kSecondaryTextColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_qrImageBytes != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Image.memory(
                            _qrImageBytes!,
                            width: screenSize.responsivePadding(220),
                            height: screenSize.responsivePadding(220),
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                        ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (_qrRemaining.inSeconds <= 60
                                      ? Colors.orange
                                      : kPrimaryColor)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: _qrRemaining.inSeconds <= 60
                                  ? Colors.orange.shade800
                                  : kPrimaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _qrRemaining.inSeconds > 0
                                  ? 'Expires in ${_formatRemaining(_qrRemaining)}'
                                  : 'QR expired — generate a new one',
                              style: kSmallerTitleB.copyWith(
                                color: _qrRemaining.inSeconds <= 60
                                    ? Colors.orange.shade800
                                    : kPrimaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_qrExpiresAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Valid until ${_qrExpiresAt!.hour.toString().padLeft(2, '0')}:${_qrExpiresAt!.minute.toString().padLeft(2, '0')}',
                          style: kSmallerTitleM.copyWith(
                            color: kSecondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
              if (_view == _RedemptionView.instructions) ...[
                PrimaryButton(
                  text: 'Initiate Redemption (Send OTP)',
                  isLoading: _isInitiatingOtp,
                  isEnabled: !_isGeneratingQr,
                  onPressed: _initiateRedemption,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: (_isGeneratingQr || _isInitiatingOtp)
                        ? null
                        : _generateQr,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      side: const BorderSide(color: kPrimaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _isGeneratingQr
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: kPrimaryColor,
                            ),
                          )
                        : const Icon(Icons.qr_code_2_rounded, size: 20),
                    label: Text(
                      'Generate QR',
                      style: kSmallTitleR.copyWith(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: kSmallerTitleM.copyWith(color: kSecondaryTextColor),
                  ),
                ),
              ] else if (_view == _RedemptionView.otp) ...[
                PrimaryButton(
                  text: 'Verify & Complete Redemption',
                  isLoading: _isVerifying,
                  onPressed: _verifyOtp,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _resetToInstructions,
                  child: Text(
                    'Cancel / Go Back',
                    style: kSmallerTitleM.copyWith(color: kSecondaryTextColor),
                  ),
                ),
              ] else ...[
                if (_qrRemaining.inSeconds <= 0)
                  PrimaryButton(
                    text: 'Generate New QR',
                    isLoading: _isGeneratingQr,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: kWhite,
                      size: 20,
                    ),
                    onPressed: _generateQr,
                  )
                else
                  PrimaryButton(
                    text: 'Done',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _resetToInstructions,
                  child: Text(
                    'Back to options',
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
            color: kPrimaryColor.withValues(alpha: 0.1),
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
