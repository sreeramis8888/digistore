import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../advanced_network_image.dart';

class DealCard extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String shopName;
  final String badgeText;
  final String? dealOfTheHour;
  final Color avatarColor;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final String? imageUrl;

  const DealCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.shopName,
    required this.badgeText,
    this.dealOfTheHour,
    required this.avatarColor,
    this.margin,
    this.width,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final defaultImages = const [
      'assets/png/saloon.jpg',
      'assets/jpg/bakes.jpg',
      'assets/jpg/grocery.png',
    ];
    final defaultImage =
        defaultImages[shopName.hashCode.abs() % defaultImages.length];

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          'offerDetail',
          arguments: {
            'title': title,
            'subtitle': subtitle,
            'shopName': shopName,
            'imageUrl': imageUrl,
          },
        );
      },
      child: Container(
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE8E8E8)),
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
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(8),
                      vertical: screenSize.responsivePadding(6),
                    ),
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: kSmallerTitleM.copyWith(
                        color: kWhite,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (dealOfTheHour != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(12),
                        vertical: screenSize.responsivePadding(4),
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0XFFDFEAFF), Color(0xFFFFE5A1)],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        dealOfTheHour ?? '',
                        style: kSmallerTitleM.copyWith(fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: kSmallTitleM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenSize.responsivePadding(2)),
                      Text(
                        subtitle,
                        style: kSmallerTitleL.copyWith(
                          color: kSecondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: screenSize.responsivePadding(12)),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: screenSize.responsivePadding(10),
                        backgroundColor: avatarColor,
                        child: Icon(Icons.store, size: 12, color: kWhite),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
