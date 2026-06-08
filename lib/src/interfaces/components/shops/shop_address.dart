import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';
import '../../../../src/data/utils/launch_url.dart';

import '../../../../src/data/models/business_info.dart';

class ShopAddress extends ConsumerWidget {
  final ShopModel? shop;
  final BusinessBranch? selectedBranch;

  const ShopAddress({super.key, this.shop, this.selectedBranch});

  void _openDirections() {
    final branches = shop?.businessInfo?.branches ?? [];
    BusinessBranch? primaryBranch;
    for (final b in branches) {
      if (b.isPrimary == true) {
        primaryBranch = b;
        break;
      }
    }
    if (primaryBranch == null && branches.isNotEmpty) {
      primaryBranch = branches.first;
    }

    final shopCoords = selectedBranch?.location?.coordinates ?? primaryBranch?.location?.coordinates;
    if (shopCoords != null && shopCoords.length >= 2) {
      final lat = shopCoords[1];
      final lng = shopCoords[0];
      launchURL('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    
    final branches = shop?.businessInfo?.branches ?? [];
    BusinessBranch? primaryBranch;
    for (final b in branches) {
      if (b.isPrimary == true) {
        primaryBranch = b;
        break;
      }
    }
    if (primaryBranch == null && branches.isNotEmpty) {
      primaryBranch = branches.first;
    }

    final location = selectedBranch?.location ?? primaryBranch?.location;
    
    String addressText = 'No address provided';
    String? cityStateText;
    
    if (selectedBranch != null && selectedBranch!.address != null) {
      addressText = selectedBranch!.address!;
      if (location?.city != null || location?.state != null || location?.pincode != null) {
        cityStateText = '${location?.city ?? ''} ${location?.state ?? ''} ${location?.pincode ?? ''}'.trim();
      }
    } else if (primaryBranch != null) {
      addressText = primaryBranch.address ?? 'No address provided';
      if (location?.city != null || location?.state != null || location?.pincode != null) {
        cityStateText = '${location?.city ?? ''} ${location?.state ?? ''} ${location?.pincode ?? ''}'.trim();
      }
    } else if (shop?.businessDetails?.address != null) {
      addressText = shop!.businessDetails!.address!;
      if (shop?.businessDetails?.pincode != null) {
        cityStateText = 'Pincode: ${shop?.businessDetails?.pincode}';
      }
    } else if (shop?.coverageAreas?.districts?.isNotEmpty == true) {
      addressText = shop!.coverageAreas!.districts!.join(', ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Column(
            key: ValueKey(addressText),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                addressText,
                style: kSmallTitleR.copyWith(color: kSecondaryTextColor, height: 1.5),
              ),
              if (cityStateText != null && cityStateText!.isNotEmpty) ...[
                SizedBox(height: screenSize.responsivePadding(4)),
                Text(
                  cityStateText!,
                  style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(12)),
        InkWell(
          onTap: _openDirections,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: screenSize.responsivePadding(120),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPrimaryColor.withAlpha(76)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions,
                    color: kPrimaryColor,
                    size: 32,
                  ),
                  SizedBox(height: screenSize.responsivePadding(8)),
                  Text(
                    'Get Directions',
                    style: kSmallTitleM.copyWith(color: kPrimaryColor),
                  ),
                  SizedBox(height: screenSize.responsivePadding(4)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      selectedBranch?.name ?? shop?.businessDetails?.businessName ?? 'Shop Location',
                      key: ValueKey(selectedBranch?.name ?? shop?.businessDetails?.businessName),
                      style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
