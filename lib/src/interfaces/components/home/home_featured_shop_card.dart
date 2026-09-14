import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../advanced_network_image.dart';

/// Home revamp Featured Shop card (Figma).
class HomeFeaturedShopCard extends ConsumerWidget {
  final ShopModel shop;
  final double? width;

  const HomeFeaturedShopCard({
    super.key,
    required this.shop,
    this.width,
  });

  String get _name => shop.businessDetails?.businessName ?? '';

  String get _subtitle {
    final type = shop.businessDetails?.businessType?.trim();
    if (type != null && type.isNotEmpty) return type;

    final tagline = shop.businessInfo?.tagline?.trim();
    if (tagline != null && tagline.isNotEmpty) return tagline;

    final categories = shop.serviceCategories;
    if (categories != null && categories.isNotEmpty) return categories.first;

    final tags = shop.tags;
    if (tags != null && tags.isNotEmpty) return tags.first;

    return '';
  }

  String get _coverUrl {
    final cover = shop.businessInfo?.coverImage?.trim();
    if (cover != null && cover.isNotEmpty) return cover;

    final images = shop.businessInfo?.businessImages;
    if (images != null && images.isNotEmpty) return images.first;

    return shop.businessInfo?.businessLogo ?? '';
  }

  String get _logoUrl => shop.businessInfo?.businessLogo ?? '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final cardWidth = width ?? screenSize.responsivePadding(160);
    final hasLogo = _logoUrl.trim().isNotEmpty;

    return InteractiveFeedbackButton(
      onPressed: () {
        Navigator.of(context).pushNamed('shopDetail', arguments: shop);
      },
      scaleFactor: 0.98,
      child: SizedBox(
        width: cardWidth,
        height: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenSize.responsivePadding(90),
                width: double.infinity,
                child: AdvancedNetworkImage(
                  imageUrl: _coverUrl,
                  fit: BoxFit.cover,
                  disableFade: true,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenSize.responsivePadding(8)),
                  child: Row(
                    children: [
                      if (hasLogo) ...[
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimaryLightColor,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AdvancedNetworkImage(
                            imageUrl: _logoUrl,
                            fit: BoxFit.cover,
                            disableFade: true,
                          ),
                        ),
                        SizedBox(width: screenSize.responsivePadding(8)),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _name,
                              style: kSmallTitleB.copyWith(
                                color: const Color(0xFF111827),
                                fontSize: 14,
                                height: 1.15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _subtitle,
                                style: kSmallerTitleL.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 11,
                                  height: 1.15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
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
