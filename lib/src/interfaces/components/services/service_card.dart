import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../main_pages/services/service_details_page.dart';
import '../advanced_network_image.dart';

class ServiceCard extends ConsumerWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);
    final imageUrl = service.images.isNotEmpty ? service.images.first : '';
    final rawPartnerName = service.partner?.name?.trim();
    final shopName = (rawPartnerName != null &&
            rawPartnerName.isNotEmpty &&
            rawPartnerName.toLowerCase() != 'setgo partner')
        ? rawPartnerName
        : null;

    String categoryName = service.categoryName ?? service.category ?? '';
    if (categoryName.isEmpty || RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(categoryName)) {
      final targetId = service.categoryId ?? (RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(categoryName) ? categoryName : null);
      if (targetId != null && categoriesAsync.hasValue) {
        final matched = categoriesAsync.value?.where((c) => c.id == targetId).firstOrNull;
        if (matched?.name != null && matched!.name!.isNotEmpty) {
          categoryName = matched.name!;
        }
      }
    }
    if (categoryName.isEmpty || RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(categoryName)) {
      categoryName = 'Service';
    }

    final priceStr = service.hasOffer && service.offerPrice != null
        ? '₹ ${service.offerPrice!.toInt()}'
        : '₹ ${service.originalPrice.toInt()}';
    final rating = service.rating > 0
        ? service.rating.toStringAsFixed(1)
        : null;

    return InteractiveFeedbackButton(
      onPressed: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceDetailsPage(service: service),
              ),
            );
          },
      scaleFactor: 0.98,
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: screenSize.responsivePadding(115),
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
                  if (categoryName.isNotEmpty)
                    Positioned(
                      left: 12,
                      top: 12,
                      right: 12,
                      child: Align(
                        alignment: Alignment.topLeft,
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
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            priceStr,
                            style: kSmallerTitleM.copyWith(
                              color: const Color(0xFF4E4E4E),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (rating != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  rating,
                                  style: kSmallerTitleL.copyWith(
                                    color: const Color(0xFF4E4E4E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFFFCB2B),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
