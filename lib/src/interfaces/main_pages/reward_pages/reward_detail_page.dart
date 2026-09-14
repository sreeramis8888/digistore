import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/providers/rewards_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/services/toast_service.dart';
import '../../../data/utils/currency_formatter.dart';
import '../../../data/utils/date_formatter.dart';
import '../../../data/utils/global_variables.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/advanced_network_image.dart';
import '../../components/full_screen_gallery.dart';
import '../../components/guest_login_dialog.dart';
import '../../components/shops/shop_gallery.dart';

class RewardDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;

  const RewardDetailPage({super.key, required this.args});

  @override
  ConsumerState<RewardDetailPage> createState() => _RewardDetailPageState();
}

class _RewardDetailPageState extends ConsumerState<RewardDetailPage> {
  bool _isLoading = false;
  bool _isNavigatingToShop = false;

  Future<void> _navigateToShop(String partnerId) async {
    if (_isNavigatingToShop || partnerId.isEmpty) return;
    setState(() => _isNavigatingToShop = true);

    try {
      final shop = await ref.read(getShopByPartnerIdProvider(partnerId).future);
      if (!mounted) return;
      if (shop != null) {
        Navigator.of(context).pushNamed('shopDetail', arguments: shop);
      } else {
        ToastService().showToast(
          context,
          'No such shop found for this reward.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastService().showToast(
        context,
        'Error loading shop: $e',
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isNavigatingToShop = false);
      }
    }
  }

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
    final int? stock = (args['stock'] as num?)?.toInt();
    final int? maxPerUser = (args['maxPerUser'] as num?)?.toInt();

    final partnerIdObj = args['partnerId'];
    final String partnerId = (partnerIdObj is Map)
        ? (partnerIdObj['_id'] ?? partnerIdObj['id'] ?? '')
        : (partnerIdObj?.toString() ?? '');

    final ShopModel? fetchedShop = partnerId.isNotEmpty
        ? ref.watch(getShopByPartnerIdProvider(partnerId)).value
        : null;

    final rawShopName = args['shopName'] ??
        (partnerIdObj is Map && partnerIdObj['businessDetails'] is Map
            ? partnerIdObj['businessDetails']['businessName']
            : null) ??
        '';
    final formattedCategory = formatRewardCategory(category);
    final String displayShopName = rawShopName.toString().isNotEmpty &&
            rawShopName != title &&
            rawShopName.toString().toLowerCase() != category?.toLowerCase() &&
            rawShopName.toString().toLowerCase() != formattedCategory.toLowerCase()
        ? rawShopName.toString()
        : (fetchedShop?.businessDetails?.businessName ??
            (formattedCategory.isNotEmpty ? formattedCategory : 'Reward'));

    final rawShopLogo = args['shopLogo'] ??
        args['partnerLogo'] ??
        args['logo'] ??
        (partnerIdObj is Map && partnerIdObj['businessInfo'] is Map
            ? partnerIdObj['businessInfo']['businessLogo']
            : null);
    final String? effectiveShopLogo = (rawShopLogo != null && rawShopLogo.toString().isNotEmpty)
        ? rawShopLogo.toString()
        : (fetchedShop?.businessInfo?.businessLogo ?? fetchedShop?.businessInfo?.coverImage);

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

    final allImages = <String>[];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      allImages.add(imageUrl);
    }
    for (final img in galleryImages) {
      if (!allImages.contains(img)) allImages.add(img);
    }

    final floatingTagText = formattedCategory.isNotEmpty
        ? formattedCategory
        : (benefit.isNotEmpty ? benefit : 'Reward');

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF373737),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reward Detail',
          style: GoogleFonts.urbanist(
            color: const Color(0xFF373737),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image Container (200px height with border and floating tag)
                  GestureDetector(
                    onTap: allImages.isNotEmpty
                        ? () => _openGallery(
                              images: allImages,
                              initialUrl: imageUrl,
                            )
                        : null,
                    child: Container(
                      width: double.infinity,
                      height: screenSize.responsivePadding(200),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            AdvancedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.zero,
                              disableFade: true,
                            )
                          else
                            Container(
                              color: const Color(0xFFE5E7EB),
                              alignment: Alignment.center,
                              child: icon != null
                                  ? Icon(icon, size: 64, color: const Color(0xFF6155F5))
                                  : const Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: Color(0xFF9CA3AF),
                                    ),
                            ),

                          // Floating Tag Pill (Top-Left)
                          if (floatingTagText.isNotEmpty)
                            Positioned(
                              top: 10,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  floatingTagText,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF292929),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Shop Info Card (Top rounded 24px, Merchant Header, Divider, Reward Titles)
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      screenSize.responsivePadding(20),
                      screenSize.responsivePadding(16),
                      screenSize.responsivePadding(20),
                      screenSize.responsivePadding(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shop Header Row
                        InkWell(
                          onTap: partnerId.isNotEmpty
                              ? () => _navigateToShop(partnerId)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFF3F4F6),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                    width: 1.5,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: effectiveShopLogo != null &&
                                        effectiveShopLogo.isNotEmpty
                                    ? AdvancedNetworkImage(
                                        imageUrl: effectiveShopLogo,
                                        fit: BoxFit.cover,
                                      )
                                    : (imageUrl != null && imageUrl.isNotEmpty
                                        ? AdvancedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.storefront,
                                              color: Color(0xFF6B7280),
                                              size: 20,
                                            ),
                                          )),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  displayShopName,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (partnerId.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                if (_isNavigatingToShop)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF6155F5),
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Color(0xFF9CA3AF),
                                  ),
                              ],
                            ],
                          ),
                        ),

                        // Divider
                        const SizedBox(height: 16),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFF3F4F6),
                        ),
                        const SizedBox(height: 16),

                        // Reward Title & Subtitle
                        Text(
                          title,
                          style: GoogleFonts.urbanist(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                            height: 1.25,
                          ),
                        ),
                        if (subtitle.isNotEmpty &&
                            subtitle != 'null' &&
                            subtitle != 'nil') ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF111827),
                              height: 1.35,
                            ),
                          ),
                        ],

                        // Benefit Pill (if available)
                        if (benefit.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6155F5).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF6155F5).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.card_giftcard,
                                  size: 14,
                                  color: Color(0xFF6155F5),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  benefit,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF6155F5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Grey Separator Band (8px)
                  Container(
                    width: double.infinity,
                    height: 8,
                    color: const Color(0xFFF3F4F6),
                  ),

                  // Details & Terms Section
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.all(screenSize.responsivePadding(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details & Terms',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1C1C),
                          ),
                        ),
                        if (formattedExpiry != null &&
                            formattedExpiry.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: const Color(0xFF1C1C1C),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Expires on: ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
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
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              if (stock != null)
                                Text(
                                  'Stock: $stock',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              if (maxPerUser != null)
                                Text(
                                  'Max per user: $maxPerUser',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (terms.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ...terms.map(
                            (term) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildBulletPoint(term),
                            ),
                          ),
                        ] else if (subtitle.isNotEmpty &&
                            subtitle != 'null' &&
                            subtitle != 'nil') ...[
                          const SizedBox(height: 12),
                          _buildBulletPoint(subtitle),
                        ],
                        if (galleryImages.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ShopGallery(images: galleryImages),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Buttons Container (Figma matching)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              screenSize.responsivePadding(16),
              screenSize.responsivePadding(10),
              screenSize.responsivePadding(16),
              (bottomInset > 0 ? bottomInset + 10 : 20).toDouble(),
            ),
            child: !isClaimed
                ? InteractiveFeedbackButton(
                    onPressed: _isLoading ? null : () => _redeem(context),
                    scaleFactor: 0.98,
                    child: Container(
                      height: screenSize.responsivePadding(56),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6155F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Get it for $points',
                                  style: GoogleFonts.urbanist(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  'assets/svg/coin.svg',
                                  width: 16.2,
                                  height: 16.2,
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
                          color: const Color(0xFF6155F5).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF6155F5).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Your Coupon Code: $couponCode',
                            style: GoogleFonts.urbanist(
                              color: const Color(0xFF6155F5),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: screenSize.responsivePadding(56),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Reward Claimed',
                          style: GoogleFonts.urbanist(
                            color: const Color(0xFF6B7280),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
          padding: const EdgeInsets.only(top: 6, right: 10, left: 2),
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
            style: GoogleFonts.urbanist(
              color: const Color(0xFF4E4E4E),
              height: 1.5,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

