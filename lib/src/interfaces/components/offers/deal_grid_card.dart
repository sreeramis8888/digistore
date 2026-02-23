import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class DealGridCard extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String shopName;
  final String badgeText;
  final String? dealOfTheHour;
  final Color avatarColor;

  const DealGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.shopName,
    required this.badgeText,
    this.dealOfTheHour,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Container(
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
              Container(
                height: screenSize.responsivePadding(120),
                decoration: BoxDecoration(
                  color: kGreyLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(child: Icon(Icons.image, color: kGrey, size: 40)),
              ),
              Positioned(
                top: 0,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(8),
                    vertical: screenSize.responsivePadding(6),
                  ),
                  decoration: const BoxDecoration(
                    color: kBlue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    badgeText,
                    style: kSmallerTitleB.copyWith(color: kWhite, fontSize: 10),
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
                      color: Color(0xFFF3E5D8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      dealOfTheHour!,
                      style: kSmallerTitleB.copyWith(color: const Color(0xFF8A6B32)),
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
                        title,
                        style: kBodyTitleB,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenSize.responsivePadding(2)),
                      Text(
                        subtitle,
                        style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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
                          style: kSmallTitleSB,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
