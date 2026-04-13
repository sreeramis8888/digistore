import 'package:digistore/src/data/utils/interactive_feedback_button.dart';
import 'package:digistore/src/interfaces/components/advanced_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/models/shop_model.dart';

class ShopGridCard extends ConsumerWidget {
  final String category;
  final String shopName;
  final String address;
  final String distance;
  final String rating;
  final Color avatarColor;
  final IconData avatarIcon;
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
    this.imageUrl,
    this.shop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final defaultImages = const [
      'assets/png/swinging_spoon.png',
      'assets/png/good.png',
      'assets/png/chill_bite.png',
      'assets/png/vibe.png',
    ];
    final defaultImage = defaultImages[shopName.hashCode.abs() % defaultImages.length];

    return InteractiveFeedbackButton(
      onPressed: () {
        Navigator.of(context).pushNamed(
          'shopDetail',
          arguments: shop ?? shopName,
        );
      },
      scaleFactor: 0.98,
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: screenSize.responsivePadding(120),
                  width: double.infinity,
                  child: AdvancedNetworkImage(
                    imageUrl: imageUrl ?? defaultImage,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(12),
                      vertical: screenSize.responsivePadding(4),
                    ),
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(74),
                      ),
                    ),
                    child: Text(
                      category,
                      style: kSmallerTitleSB.copyWith(
                        color: kWhite,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenSize.responsivePadding(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: screenSize.responsivePadding(12),
                          backgroundColor: avatarColor,
                          child: Icon(avatarIcon, size: 14, color: kWhite),
                        ),
                        SizedBox(width: screenSize.responsivePadding(8)),
                        Expanded(
                          child: Text(
                            shopName,
                            style: kSmallerTitleM,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: kSecondaryTextColor,
                          ),
                        ),
                        SizedBox(width: screenSize.responsivePadding(4)),
                        Expanded(
                          child: Text(
                            address,
                            style: kSmallerTitleL.copyWith(
                              color: kSecondaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          distance,
                          style: kSmallerTitleM.copyWith(
                            color: kSecondaryTextColor,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              rating,
                              style: kSmallerTitleL.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: 14,
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
    );
  }
}
