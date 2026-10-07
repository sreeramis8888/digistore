import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../../data/utils/rating_label.dart';
import '../../main_pages/services/service_details_page.dart';
import '../advanced_network_image.dart';

class ServiceCard extends ConsumerWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final bool hideShopInfo;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.hideShopInfo = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final imageUrl = service.images.isNotEmpty ? service.images.first : '';
    final rawPartnerName = service.partner?.name?.trim();
    final shopName = hideShopInfo
        ? null
        : ((rawPartnerName != null &&
                  rawPartnerName.isNotEmpty &&
                  rawPartnerName.toLowerCase() != 'setgo partner')
              ? rawPartnerName
              : null);

    String categoryName = service.categoryName ?? service.category ?? '';
    if (categoryName.isEmpty ||
        RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(categoryName)) {
      final targetId =
          service.categoryId ??
          (RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(categoryName)
              ? categoryName
              : null);
      if (targetId != null && categoriesAsync.hasValue) {
        final matched = categoriesAsync.value
            ?.where((c) => c.id == targetId)
            .firstOrNull;
        if (matched?.name != null && matched!.name!.isNotEmpty) {
          categoryName = matched.name!;
        }
      }
    }
    if (categoryName.isEmpty ||
        RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(categoryName)) {
      categoryName = 'Service';
    }

    final priceStr = service.hasOffer && service.offerPrice != null
        ? '₹ ${service.offerPrice!.toInt()}'
        : '₹ ${service.originalPrice.toInt()}';
    final hasRating = RatingLabel.hasRating(
      service.rating,
      reviewCount: service.reviewsCount,
    );
    final ratingLabel = RatingLabel.compact(
      service.rating,
      reviewCount: service.reviewsCount,
    );

    return InteractiveFeedbackButton(
      onPressed:
          onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceDetailsPage(service: service),
              ),
            );
          },
      scaleFactor: 0.98,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: SizedBox(
                    width: double.infinity,
                    child: AdvancedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      disableFade: true,
                      errorWidget: Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Center(
                          child: Icon(
                            Icons.spa_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenSize.responsivePadding(12),
                    screenSize.responsivePadding(10),
                    screenSize.responsivePadding(12),
                    screenSize.responsivePadding(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        service.name,
                        style: kSmallTitleSB.copyWith(
                          color: const Color(0xFF111827),
                          fontSize: 15,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (shopName != null) ...[
                        SizedBox(height: screenSize.responsivePadding(4)),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 13,
                              color: Color(0xFF1C274C),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                shopName,
                                style: kSmallerTitleM.copyWith(
                                  color: const Color(0xFF111827),
                                  fontSize: 11,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: screenSize.responsivePadding(4)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  priceStr,
                                  style: kSmallerTitleM.copyWith(
                                    color: const Color(0xFF4E4E4E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ratingLabel,
                                      style: kSmallerTitleL.copyWith(
                                        color: const Color(0xFF4E4E4E),
                                        fontSize: 11,
                                        fontWeight: hasRating
                                            ? FontWeight.w400
                                            : FontWeight.w600,
                                      ),
                                    ),
                                    if (hasRating) ...[
                                      const SizedBox(width: 2),
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: Color(0xFFFFCB2B),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (categoryName.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34C759),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  categoryName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kSmallerTitleB.copyWith(
                                    color: kWhite,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
