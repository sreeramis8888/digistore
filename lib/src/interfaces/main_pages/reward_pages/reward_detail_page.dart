import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/currency_formatter.dart';
import '../../../data/utils/date_formatter.dart';
import '../../components/advanced_network_image.dart';
import '../../components/primary_button.dart';
import '../../components/full_screen_gallery.dart';
import '../../components/shops/shop_gallery.dart';

import '../../../data/services/toast_service.dart';
import '../../../data/providers/rewards_provider.dart';
import '../../../data/utils/global_variables.dart';
import '../../components/guest_login_dialog.dart';

class RewardDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;

  const RewardDetailPage({super.key, required this.args});

  @override
  ConsumerState<RewardDetailPage> createState() => _RewardDetailPageState();
}

class _RewardDetailPageState extends ConsumerState<RewardDetailPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final screenSize = ref.watch(screenSizeProvider);
    final String? rewardId = args['id'] ?? args['_id'];
    final String title = args['title'] ?? 'Unknown Reward';
    final String subtitle = args['description'] ?? args['subtitle'] ?? '';
    final String? imageUrl = args['imageUrl'] ?? args['image'];
    final String shopName = args['shopName'] ?? '';
    final IconData? icon = args['icon'];
    final String points = args['points']?.toString() ?? args['pointsCost']?.toString() ?? '0';
    final bool isClaimed = args['isClaimed'] == true;
    final String? couponCode = args['couponCode'];
    final double? value = (args['value'] as num? ??
            args['discountValue'] as num? ??
            args['discount'] as num? ??
            args['discountPercent'] as num? ??
            args['discountAmount'] as num?)
        ?.toDouble();
    final String? valueType = (args['valueType'] as String? ??
        args['discountType'] as String?);
    final String? category = args['category'] as String?;
    final rawTerms = args['terms'] ??
        args['termsAndConditions'] ??
        args['terms_and_conditions'] ??
        args['conditions'] ??
        args['rules'];
    final List<String> terms = [];
    if (rawTerms is List) {
      terms.addAll(
        rawTerms
            .map((e) => e is Map ? (e['text'] ?? e['title'] ?? e['term'] ?? e.values.first).toString() : e.toString())
            .where((s) => s.trim().isNotEmpty),
      );
    } else if (rawTerms is String && rawTerms.trim().isNotEmpty) {
      terms.addAll(
        rawTerms
            .split(RegExp(r'[\r\n]+'))
            .map((s) => s.replaceAll(RegExp(r'^\s*[\d\.\-\*•]+\s*'), '').trim())
            .where((s) => s.isNotEmpty),
      );
    }

    final List<String> galleryImages = [];
    if (args['images'] is List) {
      galleryImages.addAll((args['images'] as List).map((e) => e.toString()).where((s) => s.isNotEmpty));
    } else if (args['gallery'] is List) {
      galleryImages.addAll((args['gallery'] as List).map((e) => e.toString()).where((s) => s.isNotEmpty));
    } else if (args['galleryImages'] is List) {
      galleryImages.addAll((args['galleryImages'] as List).map((e) => e.toString()).where((s) => s.isNotEmpty));
    }

    final benefit = formatRewardBenefit(
      value: value,
      valueType: valueType,
      category: category,
    );
    final formattedCategory = formatRewardCategory(category);

    final rawExpiry = args['expiresAt'] ??
        args['validUntil'] ??
        args['expiryDate'] ??
        args['validTo'] ??
        args['expirationDate'] ??
        args['endDate'];
    String? formattedExpiry;
    if (rawExpiry != null) {
      if (rawExpiry is DateTime) {
        formattedExpiry = formatDate(rawExpiry);
      } else if (rawExpiry is String && rawExpiry.trim().isNotEmpty) {
        final parsed = DateTime.tryParse(rawExpiry);
        formattedExpiry = parsed != null ? formatDate(parsed) : rawExpiry;
      }
    }

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
        title: Text(
          'Reward Detail',
          style: kSmallerTitleB.copyWith(color: kTextColor, fontSize: 16),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (imageUrl != null)
              GestureDetector(
                onTap: () {
                  final allImages = galleryImages.isNotEmpty
                      ? (galleryImages.contains(imageUrl) ? galleryImages : [imageUrl, ...galleryImages])
                      : [imageUrl];
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return FullScreenGallery(
                          images: allImages,
                          initialIndex: allImages.indexOf(imageUrl).clamp(0, allImages.length - 1),
                        );
                      },
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).orientation == Orientation.landscape 
                      ? MediaQuery.of(context).size.height * 0.5 
                      : screenSize.responsivePadding(220),
                  child: AdvancedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).orientation == Orientation.landscape 
                    ? MediaQuery.of(context).size.height * 0.5 
                    : screenSize.responsivePadding(220),
                color: kGreyLight,
                alignment: Alignment.center,
                child: icon != null
                    ? Icon(icon, size: 80, color: kPrimaryColor)
                    : const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: kGrey,
                      ),
              ),

            Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kPrimaryColor,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl != null
                            ? AdvancedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.storefront,
                                color: kWhite,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: kBodyTitleB.copyWith(fontSize: 24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (shopName.isNotEmpty &&
                      shopName != title &&
                      shopName.toLowerCase() != category?.toLowerCase() &&
                      shopName.toLowerCase() != formattedCategory.toLowerCase())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        shopName,
                        style: kBodyTitleSB.copyWith(
                          color: kPrimaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: kBodyTitleSB.copyWith(
                        color: kSecondaryTextColor,
                        fontSize: 14,
                      ),
                    ),

                  if (benefit.isNotEmpty || formattedCategory.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (benefit.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.card_giftcard, size: 14, color: kPrimaryColor),
                                const SizedBox(width: 5),
                                Text(
                                  benefit,
                                  style: kSmallerTitleB.copyWith(
                                    color: kPrimaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (formattedCategory.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F5F7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.category_outlined, size: 14, color: Color(0xFF4B5563)),
                                const SizedBox(width: 5),
                                Text(
                                  formattedCategory,
                                  style: kSmallerTitleM.copyWith(
                                    color: const Color(0xFF374151),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],

                  if (formattedExpiry != null && formattedExpiry.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: kSecondaryTextColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Expires on $formattedExpiry',
                          style: kSmallerTitleM.copyWith(
                            color: kSecondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (galleryImages.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ShopGallery(images: galleryImages),
                  ],

                  if (terms.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Terms & Conditions', style: kSmallTitleSB),
                    const SizedBox(height: 12),
                    ...terms.map(
                      (term) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildBulletPoint(term),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  if (!isClaimed)
                    PrimaryButton(
                      isLoading: _isLoading,
                      textSize: 14,
                      text: 'Get it For $points',
                      trailingIcon: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: SvgPicture.asset(
                          'assets/svg/coin.svg',
                          height: 18,
                        ),
                      ),
                      onPressed: () async {
                        if (GlobalVariables.isGuest) {
                          GuestLoginDialog.show(
                            context,
                            title: 'Login Required',
                            subtitle: 'Please login or register to claim rewards.',
                          );
                          return;
                        }

                        final rewardIdToUse = rewardId ?? args['id'] ?? args['_id'];
                        if (rewardIdToUse == null) {
                          ToastService().showToast(
                            context,
                            'Invalid reward ID',
                            type: ToastType.error,
                          );
                          return;
                        }

                        setState(() => _isLoading = true);
                        try {
                          final response = await ref
                              .read(rewardActionProvider.notifier)
                              .redeemReward(rewardIdToUse);

                          if (!context.mounted) return;

                          if (response.success) {
                            ToastService().showToast(
                              context,
                              response.message ?? 'Reward redeemed successfully!',
                            );
                            Navigator.of(context).pop();
                          } else {
                            ToastService().showToast(
                              context,
                              response.message ?? 'Failed to redeem reward',
                              type: ToastType.error,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            log('Error redeeming reward: $e');
                            ToastService().showToast(
                              context,
                              'An error occurred: $e',
                              type: ToastType.error,
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                    )
                  else if (couponCode != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Your Coupon Code: $couponCode',
                          style: kBodyTitleB.copyWith(color: kPrimaryColor),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom
                        : 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 8, left: 4),
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: kSecondaryTextColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
          ),
        ),
      ],
    );
  }
}
