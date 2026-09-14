import 'package:setgo/src/interfaces/components/advanced_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/utils/interactive_feedback_button.dart';

class ShopGridCard extends ConsumerWidget {
  final String category;
  final String shopName;
  final String address;
  final String distance;
  final String rating;
  final Color avatarColor;
  final IconData avatarIcon;
  final String? logoUrl;
  final String? imageUrl;
  final ShopModel? shop;

  const ShopGridCard({
    super.key,
    required this.category,
    required this.shopName,
    required this.address,
    required this.distance,
    required this.rating,
    required this.avatarColor,
    required this.avatarIcon,
    this.logoUrl,
    this.imageUrl,
    this.shop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final parsedRating = double.tryParse(rating);
    final formattedRating = parsedRating != null && parsedRating > 0
        ? parsedRating.toStringAsFixed(1)
        : rating;

    return InteractiveFeedbackButton(
      onPressed: () {
        Navigator.of(
          context,
        ).pushNamed('shopDetail', arguments: shop ?? shopName);
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
                    child: (imageUrl != null && imageUrl!.isNotEmpty)
                        ? AdvancedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            disableFade: true,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: avatarColor.withValues(alpha: 0.12),
                            ),
                            child: Center(
                              child: Icon(
                                avatarIcon,
                                size: 36,
                                color: avatarColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                  ),
                  if (category.isNotEmpty)
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
                            color: const Color(0xFF07982C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category,
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
                            shopName,
                            style: kSmallTitleSB.copyWith(
                              color: const Color(0xFF111827),
                              fontSize: 15,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                                  address,
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
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            distance,
                            style: kSmallerTitleM.copyWith(
                              color: const Color(0xFF4E4E4E),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formattedRating,
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
