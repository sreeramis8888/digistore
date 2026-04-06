import 'package:digistore/src/data/providers/offers_provider.dart';
import 'package:digistore/src/data/services/toast_service.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/primary_button.dart';

class PartnerRedemptionPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;

  const PartnerRedemptionPage({super.key, required this.args});

  @override
  ConsumerState<PartnerRedemptionPage> createState() => _PartnerRedemptionPageState();
}

class _PartnerRedemptionPageState extends ConsumerState<PartnerRedemptionPage> {
  String phoneNumber = '';
  bool isOtpSent = false;
  bool isLoading = false;
  DateTime? expiresAt;

  Future<void> _generateOtp() async {
    if (phoneNumber.isEmpty) {
      ToastService().showToast(
        context,
        'Enter customer phone number',
        type: ToastType.warning,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final offerId = widget.args['id'] as String?;
    if (offerId == null) {
      setState(() {
        isLoading = false;
      });
      ToastService().showToast(
        context,
        'Invalid offer details',
        type: ToastType.error,
      );
      return;
    }

    final response = await ref
        .read(offersProvider.notifier)
        .generateRedemptionOtp(offerId, phoneNumber);

    if (response.success && response.data != null) {
      setState(() {
        isOtpSent = true;
        isLoading = false;
        final expiresStr = response.data!['data']['expiresAt'];
        if (expiresStr != null) {
          expiresAt = DateTime.tryParse(expiresStr);
        }
      });
      if (mounted) {
        ToastService().showToast(
          context,
          response.data!['data']['message'] ?? 'OTP sent successfully',
          type: ToastType.success,
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ToastService().showToast(
          context,
          response.message ?? 'Failed to send OTP',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final String title = widget.args['title'] ?? 'Offer';
    final String subtitle = widget.args['subtitle'] ?? '';
    final String? imageUrl = widget.args['imageUrl'];

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
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.responsivePadding(32)),
              Text(
                'Customer Redemption',
                style: kSubHeadingM.copyWith(fontSize: 20),
              ),
              SizedBox(height: screenSize.responsivePadding(8)),
              Text(
                isOtpSent
                   ? 'Customer will receive OTP on their phone'
                    : 'Enter customer\'s phone number to send OTP',
                textAlign: TextAlign.center,
                style: kBodyTitleM.copyWith(color: kSecondaryTextColor),
              ),
              SizedBox(height: screenSize.responsivePadding(32)),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8F0FF)),
                ),
                padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                child: Row(
                  children: [
                    Container(
                      width: screenSize.responsivePadding(60),
                      height: screenSize.responsivePadding(40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? AdvancedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: kPrimaryColor.withOpacity(0.1),
                              child: const Icon(Icons.local_offer, size: 20, color: kPrimaryColor),
                            ),
                    ),
                    SizedBox(width: screenSize.responsivePadding(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: kSmallTitleB,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenSize.responsivePadding(2)),
                          Text(
                            subtitle,
                            style: kSmallerTitleM.copyWith(
                              color: kSecondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(32)),
              if (!isOtpSent) ...[
                IntlPhoneField(
                  disableLengthCheck: true,
                  initialCountryCode: 'IN',
                  flagsButtonMargin: EdgeInsets.zero,
                  flagsButtonPadding: EdgeInsets.zero,
                  decoration: InputDecoration(
                    hintText: 'Enter customer number',
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
                SizedBox(height: screenSize.responsivePadding(32)),
                PrimaryButton(
                  text: 'Generate OTP',
                  isLoading: isLoading,
                  onPressed: _generateOtp,
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.responsivePadding(32),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'WAITING FOR OTP',
                        style: kBodyTitleM.copyWith(fontSize: 14),
                      ),
                      SizedBox(height: screenSize.responsivePadding(16)),
                      const Icon(Icons.timer_outlined, size: 64, color: kPrimaryColor),
                      SizedBox(height: screenSize.responsivePadding(24)),
                      if (expiresAt != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Expiring at: ',
                              style: kSmallTitleM.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                            Text(
                              '${expiresAt!.hour.toString().padLeft(2, '0')}:${expiresAt!.minute.toString().padLeft(2, '0')}',
                              style: kSmallTitleM.copyWith(
                                color: const Color(0xFF4A89FF),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  'Ask customer for the OTP sent to $phoneNumber',
                  textAlign: TextAlign.center,
                  style: kBodyTitleM.copyWith(color: kSecondaryTextColor),
                ),
                SizedBox(height: screenSize.responsivePadding(32)),
                PrimaryButton(
                  text: 'Verify OTP',
                  onPressed: () {
                    // This will be navigated to verification page which logic should follow soon
                  },
                ),
              ],
              SizedBox(height: screenSize.responsivePadding(24)),
            ],
          ),
        ),
      ),
    );
  }
}
