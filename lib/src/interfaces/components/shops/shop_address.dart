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
      final parts = <String>[];
      if (shop?.businessDetails?.district != null && shop!.businessDetails!.district!.isNotEmpty) {
        parts.add(shop!.businessDetails!.district!);
      }
      if (shop?.businessDetails?.pincode != null && shop!.businessDetails!.pincode!.isNotEmpty) {
        parts.add('PIN: ${shop!.businessDetails!.pincode!}');
      }
      if (parts.isNotEmpty) {
        cityStateText = parts.join(' • ');
      }
    } else if (shop?.coverageAreas?.districts?.isNotEmpty == true) {
      addressText = shop!.coverageAreas!.districts!.join(', ');
    }

    final branchContact = selectedBranch?.contactPersonName ?? primaryBranch?.contactPersonName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(10)),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: Column(
            key: ValueKey(addressText),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Color(0xFF07838C),
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(6)),
                  Expanded(
                    child: Text(
                      addressText,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (cityStateText != null && cityStateText!.isNotEmpty) ...[
                SizedBox(height: screenSize.responsivePadding(4)),
                Padding(
                  padding: EdgeInsets.only(left: screenSize.responsivePadding(22)),
                  child: Text(
                    cityStateText!,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
              if (branchContact != null && branchContact.isNotEmpty) ...[
                SizedBox(height: screenSize.responsivePadding(4)),
                Padding(
                  padding: EdgeInsets.only(left: screenSize.responsivePadding(22)),
                  child: Text(
                    'Contact: $branchContact',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(14)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openDirections,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: screenSize.responsivePadding(110),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07838C).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_rounded,
                        color: Color(0xFF07838C),
                        size: 24,
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(6)),
                    const Text(
                      'Get Directions',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF07838C),
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(2)),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        selectedBranch?.name ?? shop?.businessDetails?.businessName ?? 'Shop Location',
                        key: ValueKey(selectedBranch?.name ?? shop?.businessDetails?.businessName),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
