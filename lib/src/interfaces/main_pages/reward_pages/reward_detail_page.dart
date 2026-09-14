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
import '../../components/full_screen_gallery.dart';
import '../../components/shops/shop_gallery.dart';
import '../../../data/services/toast_service.dart';
import '../../../data/providers/rewards_provider.dart';
import '../../../data/utils/global_variables.dart';
import '../../components/guest_login_dialog.dart';
import '../../../data/utils/interactive_feedback_button.dart';

class RewardDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;

  const RewardDetailPage({super.key, required this.args});

  @override
  ConsumerState<RewardDetailPage> createState() => _RewardDetailPageState();
}

class _RewardDetailPageState extends ConsumerState<RewardDetailPage> {
  bool _isLoading = false;

  Future<void> _redeem(BuildContext context) async {
    final args = widget.args;
    final rewardId = args['id'] ?? args['_id'];

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
      final response =
          await ref.read(rewardActionProvider.notifier).redeemReward(rewardIdToUse);

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
  }

  void _openGallery({
    required List<String> images,
    required String? initialUrl,
  }) {
    if (images.isEmpty) return;
    final initialIndex = initialUrl != null
        ? images.indexOf(initialUrl).clamp(0, images.length - 1)
        : 0;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenGallery(
            images: images,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final screenSize = ref.watch(screenSizeProvider);
    final String title = args['title'] ?? 'Unknown Reward';
    final String subtitle = args['description'] ?? args['subtitle'] ?? '';
    final String? imageUrl = args['imageUrl'] ?? args['image'];
    final String shopName = args['shopName'] ?? '';
    final IconData? icon = args['icon'];
    final String points =
        args['points']?.toString() ?? args['pointsCost']?.toString() ?? '0';
    final bool isClaimed = args['isClaimed'] == true;
    final String? couponCode = args['couponCode'];
    final double? value = (args['value'] as num? ??
            args['discountValue'] as num? ??
            args['discount'] as num? ??
            args['discountPercent'] as num? ??
            args['discountAmount'] as num?)
        ?.toDouble();
    final String? valueType =
        (args['valueType'] as String? ?? args['discountType'] as String?);
    final String? category = args['category'] as String?;
    final String? requiredTier = args['requiredTier']?.toString();
    final int? stock = (args['stock'] as num?)?.toInt();
    final int? maxPerUser = (args['maxPerUser'] as num?)?.toInt();
    final rawTerms = args['terms'] ??
        args['termsAndConditions'] ??
        args['terms_and_conditions'] ??
        args['conditions'] ??
        args['rules'];
    final List<String> terms = [];
    if (rawTerms is List) {
      terms.addAll(
        rawTerms
            .map((e) => e is Map
                ? (e['text'] ?? e['title'] ?? e['term'] ?? e.values.first)
                    .toString()
                : e.toString())
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
      galleryImages.addAll((args['images'] as List)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty));
    } else if (args['gallery'] is List) {
      galleryImages.addAll((args['gallery'] as List)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty));
    } else if (args['galleryImages'] is List) {
      galleryImages.addAll((args['galleryImages'] as List)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty));
    }

    final benefit = formatRewardBenefit(
      value: value,
      valueType: valueType,
      category: category,
    );
    final formattedCategory = formatRewardCategory(category);
    final formattedRequiredTier = formatRewardCategory(requiredTier);

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

    final displayShopName = (shopName.isNotEmpty &&
            shopName != title &&
            shopName.toLowerCase() != category?.toLowerCase() &&
            shopName.toLowerCase() != formattedCategory.toLowerCase())
        ? shopName
        : (formattedCategory.isNotEmpty ? formattedCategory : 'Reward');

    final heroHeight = MediaQuery.of(context).orientation == Orientation.landscape
        ? MediaQuery.of(context).size.height * 0.45
        : screenSize.responsivePadding(240);

    final allImages = <String>[];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      allImages.add(imageUrl);
    }
    for (final img in galleryImages) {
      if (!allImages.contains(img)) allImages.add(img);
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: kRewardPageBg,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: kWhite,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF111827),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reward Detail',
          style: kSmallTitleB.copyWith(
            color: const Color(0xFF111827),
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: allImages.isNotEmpty
                            ? () => _openGallery(
                                  images: allImages,
                                  initialUrl: imageUrl,
                                )
                            : null,
                        child: SizedBox(
                          width: double.infinity,
                          height: heroHeight,
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? AdvancedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.zero,
                                  disableFade: true,
                                )
                              : Container(
                                  color: const Color(0xFFE5E7EB),
                                  alignment: Alignment.center,
                                  child: icon != null
                                      ? Icon(icon, size: 80, color: kRewardCtaPurple)
                                      : const Icon(
                                          Icons.image_not_supported,
                                          size: 80,
                                          color: kGrey,
                                        ),
                                ),
                        ),
                      ),
                      if (formattedCategory.isNotEmpty)
                        Positioned(
                          left: 16,
                          top: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              formattedCategory,
                              style: kSmallerTitleM.copyWith(
                                color: kWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        screenSize.responsivePadding(16),
                        screenSize.responsivePadding(20),
                        screenSize.responsivePadding(16),
                        screenSize.responsivePadding(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF111827),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? AdvancedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        disableFade: true,
                                      )
                                    : const Icon(
                                        Icons.storefront,
                                        color: kWhite,
                                        size: 20,
                                      ),
                              ),
                              SizedBox(width: screenSize.responsivePadding(12)),
                              Expanded(
                                child: Text(
                                  displayShopName,
                                  style: kSmallTitleB.copyWith(
                                    color: const Color(0xFF111827),
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenSize.responsivePadding(14)),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE5E7EB),
                          ),
                          SizedBox(height: screenSize.responsivePadding(14)),
                          Text(
                            title,
                            style: kBodyTitleB.copyWith(
                              color: const Color(0xFF111827),
                              fontSize: 22,
                              height: 1.25,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            SizedBox(height: screenSize.responsivePadding(6)),
                            Text(
                              subtitle,
                              style: kSmallerTitleL.copyWith(
                                color: const Color(0xFF111827),
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ],
                          if (benefit.isNotEmpty ||
                              formattedRequiredTier.isNotEmpty) ...[
                            SizedBox(height: screenSize.responsivePadding(12)),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (benefit.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kRewardCtaPurple.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: kRewardCtaPurple.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.card_giftcard,
                                          size: 14,
                                          color: kRewardCtaPurple,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          benefit,
                                          style: kSmallerTitleB.copyWith(
                                            color: kRewardCtaPurple,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (formattedRequiredTier.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F5F7),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.workspace_premium_outlined,
                                          size: 14,
                                          color: Color(0xFF4B5563),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Tier: $formattedRequiredTier',
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
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.responsivePadding(8)),
                  Container(
                    width: double.infinity,
                    color: kWhite,
                    padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details & Terms',
                          style: kSmallTitleB.copyWith(
                            color: const Color(0xFF111827),
                            fontSize: 16,
                          ),
                        ),
                        if (formattedExpiry != null &&
                            formattedExpiry.isNotEmpty) ...[
                          SizedBox(height: screenSize.responsivePadding(12)),
                          Text.rich(
                            TextSpan(
                              style: kSmallerTitleL.copyWith(
                                color: const Color(0xFF111827),
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(text: 'Expires on: '),
                                TextSpan(
                                  text: formattedExpiry,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (stock != null || maxPerUser != null) ...[
                          SizedBox(height: screenSize.responsivePadding(10)),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              if (stock != null)
                                Text(
                                  'Stock: $stock',
                                  style: kSmallerTitleL.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 13,
                                  ),
                                ),
                              if (maxPerUser != null)
                                Text(
                                  'Max per user: $maxPerUser',
                                  style: kSmallerTitleL.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (terms.isNotEmpty) ...[
                          SizedBox(height: screenSize.responsivePadding(12)),
                          ...terms.map(
                            (term) => Padding(
                              padding: EdgeInsets.only(
                                bottom: screenSize.responsivePadding(10),
                              ),
                              child: _buildBulletPoint(term),
                            ),
                          ),
                        ] else if (subtitle.isNotEmpty) ...[
                          SizedBox(height: screenSize.responsivePadding(12)),
                          _buildBulletPoint(subtitle),
                        ],
                        if (galleryImages.isNotEmpty) ...[
                          SizedBox(height: screenSize.responsivePadding(8)),
                          ShopGallery(images: galleryImages),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.responsivePadding(24)),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: kRewardPageBg,
            padding: EdgeInsets.fromLTRB(
              screenSize.responsivePadding(16),
              screenSize.responsivePadding(8),
              screenSize.responsivePadding(16),
              (bottomInset > 0 ? bottomInset : 16).toDouble(),
            ),
            child: !isClaimed
                ? InteractiveFeedbackButton(
                    onPressed: _isLoading ? null : () => _redeem(context),
                    scaleFactor: 0.98,
                    child: Container(
                      height: screenSize.responsivePadding(52),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kRewardCtaPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(kWhite),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Get it for $points',
                                  style: kSmallTitleB.copyWith(
                                    color: kWhite,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SvgPicture.asset(
                                  'assets/svg/coin.svg',
                                  height: 16,
                                ),
                              ],
                            ),
                    ),
                  )
                : couponCode != null
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: kRewardCtaPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Your Coupon Code: $couponCode',
                            style: kBodyTitleB.copyWith(
                              color: kRewardCtaPurple,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, right: 10, left: 2),
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF9CA3AF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: kSmallerTitleL.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.45,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
