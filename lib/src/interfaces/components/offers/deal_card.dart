import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digistore/src/data/utils/interactive_feedback_button.dart';
import '../advanced_network_image.dart';
import '../../../data/models/offer_model.dart';

class DealCard extends ConsumerWidget {
  final String? id;
  final String title;
  final String subtitle;
  final String shopName;
  final String? shopLogo;
  final String badgeText;
  final String? dealOfTheHour;
  final Color avatarColor;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final String? imageUrl;
  final bool hideShopName;
  final List<String>? terms;
  final DateTime? validTo;
  final OfferModel? rawOffer;

  const DealCard({
    super.key,
    this.id,
    required this.title,
    required this.subtitle,
    required this.shopName,
    this.shopLogo,
    required this.badgeText,
    this.dealOfTheHour,
    required this.avatarColor,
    this.margin,
    this.width,
    this.imageUrl,
    this.hideShopName = false,
    this.terms,
    this.validTo,
    this.rawOffer,
  });

  factory DealCard.fromOffer(
    OfferModel offer, {
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    final badgeText = offer.discountType == 'percentage'
        ? '${offer.discountValue?.toInt() ?? 0}%\nOFF'
        : '₹${offer.discountValue?.toInt() ?? 0}\nOFF';

    return DealCard(
      id: offer.id,
      title: offer.title ?? '',
      subtitle: offer.description ?? '',
      shopName: offer.partnerId?.businessDetails?.businessName ?? '',
      shopLogo: offer.partnerId?.businessInfo?.businessLogo,
      badgeText: badgeText,
      avatarColor: kPrimaryLightColor,
      imageUrl: offer.images?.isNotEmpty == true ? offer.images![0] : null,
      width: width,
      margin: margin,
      terms: offer.terms,
      validTo: offer.validTo,
      rawOffer: offer,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return InteractiveFeedbackButton(
      onPressed: () {
        Navigator.of(context).pushNamed(
          'offerDetail',
          arguments:
              rawOffer?.toJson() ??
              {
                'id': id,
                'title': title,
                'subtitle': subtitle,
                'shopName': shopName,
                'shopLogo': shopLogo,
                'imageUrl': imageUrl,
                'description': subtitle,
                'terms': terms,
                'validTo': validTo?.toIso8601String(),
              },
        );
      },
      scaleFactor: 0.98,
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
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AdvancedNetworkImage(
                    imageUrl: imageUrl ?? '',
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
                  if (!hideShopName) ...[
                    SizedBox(height: screenSize.responsivePadding(12)),
                    Row(
                      children: [
                        Container(
                          width: screenSize.responsivePadding(20),
                          height: screenSize.responsivePadding(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: avatarColor,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: shopLogo != null
                              ? AdvancedNetworkImage(
                                  imageUrl: shopLogo!,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.store, size: 12, color: kWhite),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
