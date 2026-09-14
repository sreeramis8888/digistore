import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';
import '../../../../src/data/providers/user_provider.dart';
import '../../../../src/data/utils/location_utils.dart';
import '../../../../src/data/utils/launch_url.dart';
import '../../../../src/data/providers/reviews_provider.dart';
import '../advanced_network_image.dart';

import '../../../../src/data/models/business_info.dart';

class ShopHeader extends ConsumerStatefulWidget {
  final String shopName;
  final ShopModel? shop;
  final BusinessBranch? selectedBranch;

  const ShopHeader({
    super.key,
    required this.shopName,
    this.shop,
    this.selectedBranch,
  });

  @override
  ConsumerState<ShopHeader> createState() => _ShopHeaderState();
}

class _ShopHeaderState extends ConsumerState<ShopHeader> {
  String? _roadDistance;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _calculateRoadDistance();
  }

  @override
  void didUpdateWidget(ShopHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedBranch != widget.selectedBranch ||
        oldWidget.shop != widget.shop) {
      _calculateRoadDistance();
    }
  }

  Future<void> _calculateRoadDistance() async {
    if (!mounted) return;

    if (widget.selectedBranch == null && widget.shop?.roadDistance != null) {
      setState(() {
        _roadDistance = widget.shop!.roadDistance;
        _isCalculating = false;
      });
      return;
    }

    final branches = widget.shop?.businessInfo?.branches ?? [];
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

    final user = ref.read(userProvider);
    final userLat = user?.location?.coordinates?.lat;
    final userLng = user?.location?.coordinates?.lng;
    final shopCoords =
        widget.selectedBranch?.location?.coordinates ??
        primaryBranch?.location?.coordinates;

    setState(() {
      _roadDistance = null;
    });

    if (userLat != null &&
        userLng != null &&
        shopCoords != null &&
        shopCoords.length >= 2) {
      setState(() => _isCalculating = true);

      final result = await LocationUtils.calculateRoadDistanceAndDuration(
        fromLat: userLat,
        fromLng: userLng,
        toLat: shopCoords[1],
        toLng: shopCoords[0],
      );

      if (mounted && result != null) {
        setState(() {
          _roadDistance = result['distance']!.toStringAsFixed(1);
          _isCalculating = false;
        });
      } else if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProvider, (previous, next) {
      final prevLat = previous?.location?.coordinates?.lat;
      final prevLng = previous?.location?.coordinates?.lng;
      final nextLat = next?.location?.coordinates?.lat;
      final nextLng = next?.location?.coordinates?.lng;
      
      if (prevLat != nextLat || prevLng != nextLng) {
        _calculateRoadDistance();
      }
    });

    final screenSize = ref.watch(screenSizeProvider);
    final rating = widget.shop?.businessInfo?.rating ?? 0.0;
    final totalSalesRaw = widget.shop?.businessInfo?.totalReviews ?? 0;

    // Watch reviews provider to get live total
    final reviewsAsync = ref.watch(reviewsProvider(shopId: widget.shop?.id));
    final fetchedSales = reviewsAsync.value?.total ?? 0;
    final totalSales = fetchedSales > 0 ? fetchedSales : totalSalesRaw;
    final branches = widget.shop?.businessInfo?.branches ?? [];
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

    final address =
        widget.selectedBranch?.address ??
        primaryBranch?.address ??
        widget.shop?.businessDetails?.address ??
        'No address provided';

    final user = ref.watch(userProvider);
    final userLat = user?.location?.coordinates?.lat;
    final userLng = user?.location?.coordinates?.lng;
    final shopCoords =
        widget.selectedBranch?.location?.coordinates ??
        primaryBranch?.location?.coordinates;

    String distanceLabel = '';
    if (_roadDistance != null) {
      distanceLabel = ' ($_roadDistance km)';
    } else if (_isCalculating) {
      distanceLabel = ' (calculating...)';
    } else if (userLat != null &&
        userLng != null &&
        shopCoords != null &&
        shopCoords.length >= 2) {
      final initialDistance = widget.shop?.distance ?? LocationUtils.calculateDistance(
        userLat,
        userLng,
        shopCoords[1],
        shopCoords[0],
      );
      distanceLabel = ' (${initialDistance.toStringAsFixed(1)} km)';
    } else if (widget.shop?.distance != null) {
      distanceLabel = ' (${widget.shop!.distance!.toStringAsFixed(1)} km)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenSize.responsivePadding(52),
              height: screenSize.responsivePadding(52),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kWhite,
                border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.shop?.businessInfo?.businessLogo != null
                    ? AdvancedNetworkImage(
                        imageUrl: widget.shop!.businessInfo!.businessLogo!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.storefront, color: kPrimaryColor, size: 28),
              ),
            ),
            SizedBox(width: screenSize.responsivePadding(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.shopName,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.shop?.businessInfo?.tagline != null &&
                      widget.shop!.businessInfo!.tagline!.trim().isNotEmpty) ...[
                    SizedBox(height: screenSize.responsivePadding(2)),
                    Text(
                      widget.shop!.businessInfo!.tagline!.trim(),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (widget.shop?.isFeatured == true) ...[
              SizedBox(width: screenSize.responsivePadding(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(8),
                  vertical: screenSize.responsivePadding(4),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFD97706)),
                    SizedBox(width: screenSize.responsivePadding(3)),
                    const Text(
                      'Featured',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xFF92400E),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: screenSize.responsivePadding(10)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15,
              color: Color(0xFF6B7280),
            ),
            SizedBox(width: screenSize.responsivePadding(4)),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    ...previousChildren,
                    ?currentChild,
                  ],
                ),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: SizedBox(
                  width: double.infinity,
                  key: ValueKey('$address$distanceLabel'),
                  child: Text(
                    '$address${distanceLabel.isNotEmpty ? ' · ${distanceLabel.replaceAll(RegExp(r'[()]'), '').trim()}' : ''}',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.responsivePadding(12)),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
        SizedBox(height: screenSize.responsivePadding(12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(10),
                    vertical: screenSize.responsivePadding(5),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 16),
                      SizedBox(width: screenSize.responsivePadding(4)),
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : 'New',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      if (totalSales > 0) ...[
                        SizedBox(width: screenSize.responsivePadding(4)),
                        Text(
                          '($totalSales reviews)',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.shop?.businessInfo?.yearsOfExperience != null &&
                    widget.shop!.businessInfo!.yearsOfExperience! > 0) ...[
                  SizedBox(width: screenSize.responsivePadding(8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(8),
                      vertical: screenSize.responsivePadding(4),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.shop!.businessInfo!.yearsOfExperience}+ yrs exp',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final phone =
                      widget.selectedBranch?.phone ??
                      widget.shop?.businessInfo?.contactPhone;
                  if (phone != null && phone.isNotEmpty) {
                    launchPhone(phone);
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(16),
                    vertical: screenSize.responsivePadding(8),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07982C),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF07982C).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.call, size: 14, color: Colors.white),
                      SizedBox(width: screenSize.responsivePadding(6)),
                      const Text(
                        'Call',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
