import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/primary_button.dart';
import '../../../data/utils/global_variables.dart';
import '../../../data/utils/date_formatter.dart';

import '../../../data/providers/offers_provider.dart';
import '../../../data/providers/user_type_provider.dart';
import '../../../data/services/toast_service.dart';
import '../../components/guest_login_dialog.dart';
import '../../components/confirmation_dialog.dart';
import '../partner/create_offer_page.dart';
import '../../../data/providers/shops_provider.dart';

class OfferDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;

  const OfferDetailPage({super.key, required this.args});

  @override
  ConsumerState<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends ConsumerState<OfferDetailPage> {
  bool isRedeeming = false;
  bool isNavigatingToShop = false;
  int _currentImageIndex = 0;

  Future<void> _navigateToShop(BuildContext context, String partnerId) async {
    if (isNavigatingToShop) return;
    setState(() {
      isNavigatingToShop = true;
    });

    try {
      final shop = await ref.read(getShopByPartnerIdProvider(partnerId).future);
      if (shop != null) {
        if (mounted) {
          Navigator.of(context).pushNamed('shopDetail', arguments: shop);
        }
      } else {
        if (mounted) {
          ToastService().showToast(
            context,
            'No such shop found for this offer.',
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService().showToast(
          context,
          'Error loading shop: $e',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isNavigatingToShop = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final userType = ref.watch(userTypeProvider);
    final isPartner = userType == UserType.partner || GlobalVariables.isPartner;
    final String offerStatus = widget.args['status'] ?? 'active';
    final bool isOfferActive = offerStatus.toLowerCase() == 'active';
    final String title = widget.args['title'] ?? '';
    final String subtitle =
        widget.args['subtitle'] ?? widget.args['description'] ?? '';
    final String? imageUrl =
        widget.args['imageUrl'] ??
        ((widget.args['images'] is List &&
                (widget.args['images'] as List).isNotEmpty)
            ? widget.args['images'][0]
            : null);

    final partnerIdObj = widget.args['partnerId'];
    final String partnerId = (partnerIdObj is Map)
        ? (partnerIdObj['_id'] ?? partnerIdObj['id'] ?? '')
        : (partnerIdObj?.toString() ?? '');

    final offersState = ref.watch(offersProvider);
    final currentOfferId = widget.args['_id'] ?? widget.args['id'];
    final cachedOffer =
        offersState.offers.where((o) => o.id == currentOfferId).firstOrNull ??
        offersState.exploreOffers
            .where((o) => o.id == currentOfferId)
            .firstOrNull;

    final bool isScratchCard =
        cachedOffer?.isScratchCard ??
        (widget.args['isScratchCard'] == true ||
            widget.args['isScratchCard'] == 'true' ||
            widget.args['offerTypeCode'] == 'SC');

    final bool isScratched =
        cachedOffer?.isScratched ??
        (widget.args['isScratched'] == true ||
            widget.args['isScratched'] == 'true');

    final num? awardedDiscount =
        cachedOffer?.awardedDiscount ??
        (widget.args['awardedDiscount'] as num?);

    List<String> images = [];
    if (widget.args['images'] is List &&
        (widget.args['images'] as List).isNotEmpty) {
      images = (widget.args['images'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (imageUrl != null) {
      images = [imageUrl];
    }

    final String shopName =
        widget.args['shopName'] ??
        widget.args['partnerId']?['businessDetails']?['businessName'] ??
        '';
    final String? shopLogo =
        widget.args['shopLogo'] ??
        widget.args['partnerId']?['businessInfo']?['businessLogo'];
    final IconData? icon = widget.args['icon'];
    final String? logoText = widget.args['logoText'];
    final Color? logoColor = widget.args['logoColor'];

    final priceRange = widget.args['priceRange'];
    final requiredTier = widget.args['requiredTier'];
    final discountRange = widget.args['discountRange'];

    final branchApplicability = widget.args['branchApplicability'];
    final branchLocationsObj = widget.args['branchLocations'];
    final List branchLocations = branchLocationsObj is List ? branchLocationsObj : [];
    
    bool isAllBranches = false;
    List specificBranches = [];
    
    if (branchApplicability != null && branchApplicability is Map) {
      if (branchApplicability['type'] == 'all') {
        isAllBranches = true;
      } else if (branchApplicability['type'] == 'specific') {
        final branchIdsObj = branchApplicability['branchIds'];
        final List branchIds = branchIdsObj is List ? branchIdsObj : [];
        final List<String> stringBranchIds = branchIds.map((e) => e.toString()).toList();
        
        specificBranches = branchLocations.where((branch) {
          if (branch is! Map) return false;
          final String bId = branch['branchId']?.toString() ?? '';
          return stringBranchIds.contains(bId);
        }).toList();
      }
    }

    bool hasPriceRange = priceRange != null && priceRange.toString() != 'null' && (priceRange is Map ? priceRange.isNotEmpty : priceRange.toString().isNotEmpty);

    bool hasRequiredTier = requiredTier != null && requiredTier.toString() != 'null' && requiredTier.toString().isNotEmpty;
    bool hasDiscountRange = discountRange != null && discountRange.toString() != 'null' && (discountRange is Map ? discountRange.isNotEmpty : discountRange.toString().isNotEmpty);

    String getPriceRangeText() {
      if (priceRange is Map) {
        final min = priceRange['min'] ?? 0;
        final max = priceRange['max'] ?? 0;
        return '₹$min - ₹$max';
      }
      return priceRange.toString();
    }

    String getDiscountRangeText() {
      if (discountRange is Map) {
        return '${discountRange['min'] ?? 0}% - ${discountRange['max'] ?? 0}% OFF';
      }
      return discountRange.toString();
    }

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: kTextColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Offer Detail',
          style: kSmallerTitleR.copyWith(color: kTextColor, fontSize: 16),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: GlobalVariables.isPartner
            ? [
                Container(
                  height: 32,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateOfferPage(offer: widget.args),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kPrimaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      'Edit',
                      style: kSmallTitleM.copyWith(color: kPrimaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 32,
                  width: 32,
                  margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 18,
                    ),
                    onPressed: () async {
                      final confirm = await showConfirmationDialog(
                        context: context,
                        title: 'Delete Offer',
                        message: 'Are you sure you want to delete this offer?',
                        confirmText: 'Delete',
                        isDestructive: true,
                        onConfirm: () async {
                          try {
                            await ref
                                .read(offersProvider.notifier)
                                .deleteOffer(
                                  widget.args['_id'] ?? widget.args['id'] ?? '',
                                );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Something went wrong')),
                              );
                            }
                          }
                        },
                      );

                      if (confirm == true && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (images.isNotEmpty)
              Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 16 / 9,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: images.length > 1,
                      autoPlay: images.length > 1,
                      autoPlayInterval: const Duration(seconds: 4),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items: images.map((img) {
                      return Builder(
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: AdvancedNetworkImage(
                              imageUrl: img,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.zero,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.asMap().entries.map((entry) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _currentImageIndex == entry.key ? 20.0 : 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: _currentImageIndex == entry.key
                                  ? kPrimaryColor
                                  : const Color(0xFFE5E7EB),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              )
            else
              Container(
                width: double.infinity,
                height: screenSize.responsivePadding(220),
                color: kGreyLight,
                alignment: Alignment.center,
                child: icon != null
                    ? Icon(icon, size: 80, color: kPrimaryColor)
                    : (logoText != null && logoColor != null)
                    ? Container(
                        color: logoColor,
                        alignment: Alignment.center,
                        child: Text(
                          logoText,
                          style: kHeadTitleB.copyWith(
                            color: logoColor == Colors.white
                                ? kTextColor
                                : kWhite,
                            fontSize: 40,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: kGrey,
                      ),
              ),

            Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!(widget.args['hideShopInfo'] ?? false) &&
                      !isPartner) ...[
                    InkWell(
                      onTap: partnerId.isNotEmpty
                          ? () => _navigateToShop(context, partnerId)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 2.0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: kPrimaryColor,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: shopLogo != null
                                  ? AdvancedNetworkImage(
                                      imageUrl: shopLogo,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.storefront,
                                      color: kWhite,
                                      size: 20,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shopName,
                                    style: kBodyTitleB.copyWith(fontSize: 20),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (partnerId.isNotEmpty)
                                    Text(
                                      'Visit Shop',
                                      style: kSmallTitleM.copyWith(
                                        color: kPrimaryColor,
                                        height: 1.2,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (partnerId.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              if (isNavigatingToShop)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      kPrimaryColor,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: kPrimaryColor,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(title, style: kSubHeadingL.copyWith(fontSize: 24)),
                  const SizedBox(height: 8),
                  if (subtitle.isNotEmpty &&
                      subtitle != 'null' &&
                      subtitle != 'nil')
                    Text(
                      subtitle,
                      style: kBodyTitleSB.copyWith(
                        color: kSecondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                  if (subtitle.isNotEmpty &&
                      subtitle != 'null' &&
                      subtitle != 'nil')
                    const SizedBox(height: 16),
                  if (isScratchCard &&
                      isScratched &&
                      awardedDiscount != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEF7EC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF31C48D)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.celebration,
                            color: Color(0xFF03543F),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Scratch card revealed! You got ${awardedDiscount}% OFF.',
                              style: kSmallTitleB.copyWith(
                                color: const Color(0xFF03543F),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 16),

                  if (isAllBranches || specificBranches.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                            spreadRadius: 0,
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.storefront_rounded, color: kPrimaryColor, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Available At',
                                style: kSmallTitleSB.copyWith(color: kPrimaryColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (isAllBranches)
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Available on all branches',
                                  style: kSmallerTitleL.copyWith(color: kTextColor),
                                ),
                              ],
                            )
                          else
                            ...specificBranches.asMap().entries.map((entry) {
                              final index = entry.key;
                              final branch = entry.value;
                              final isLast = index == specificBranches.length - 1;
                              final branchName = branch['branchName']?.toString() ?? 'Branch';
                              final address = branch['address']?.toString() ?? '';
                              final city = branch['city']?.toString() ?? '';
                              final locationDetails = [address, city].where((e) => e.trim().isNotEmpty).join(', ');
                              return Padding(
                                padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2.0),
                                      child: Icon(Icons.location_on_outlined, size: 18, color: kPrimaryColor),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            branchName,
                                            style: kSmallerTitleL.copyWith(color: kTextColor, fontWeight: FontWeight.w600),
                                          ),
                                          if (locationDetails.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              locationDetails,
                                              style: kSmallerTitleM.copyWith(color: kSecondaryTextColor),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (hasPriceRange || hasRequiredTier || hasDiscountRange) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                            spreadRadius: 0,
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.star_rounded, color: kPrimaryColor, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Offer Highlights',
                                style: kSmallTitleSB.copyWith(color: kPrimaryColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (hasRequiredTier)
                            _buildHighlightRow(
                              Icons.shield_rounded,
                              'Required Tier',
                              requiredTier.toString().toUpperCase(),
                              Colors.amber.shade700,
                            ),
                          if (hasRequiredTier && (hasPriceRange || hasDiscountRange))
                            const SizedBox(height: 12),
                          if (hasPriceRange)
                            _buildHighlightRow(
                              Icons.account_balance_wallet_rounded,
                              'Price Range',
                              getPriceRangeText(),
                              Colors.blue.shade600,
                            ),
                          if (hasPriceRange && hasDiscountRange)
                            const SizedBox(height: 12),
                          if (hasDiscountRange)
                            _buildHighlightRow(
                              Icons.local_offer_rounded,
                              'Discount',
                              getDiscountRangeText(),
                              Colors.green.shade600,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text('Details', style: kSmallTitleSB),
                  const SizedBox(height: 12),
                  if (widget.args['validTo'] != null) ...[
                    Text(
                      'Expires on: ${formatOfferDate(DateTime.tryParse(widget.args['validTo'] ?? '')?.toLocal())}',
                      style: kSmallerTitleM.copyWith(
                        color: kSecondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (widget.args['terms'] != null &&
                      (widget.args['terms'] as List).isNotEmpty)
                    ...(widget.args['terms'] as List).map(
                      (term) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildBulletPoint(term.toString()),
                      ),
                    )
                  else
                    _buildBulletPoint('No specific terms provided.'),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    textSize: 14,
                    isLoading: isRedeeming,
                    isEnabled: isPartner ? isOfferActive : true,
                    text: isPartner ? 'Initiate Redemption' : 'Redeem Now',
                    onPressed: () {
                      if (GlobalVariables.isGuest) {
                        GuestLoginDialog.show(
                          context,
                          title: 'Login Required',
                          subtitle: 'Please login or register to claim offers.',
                        );
                        return;
                      }

                      final offerDetails = {
                        ...widget.args,
                        'title': title,
                        'subtitle': subtitle,
                        'imageUrl': imageUrl,
                        'id': widget.args['id'] ?? widget.args['_id'],
                      };
                      if (isPartner) {
                        Navigator.of(context).pushNamed(
                          'partnerRedemption',
                          arguments: offerDetails,
                        );
                      } else {
                        if (isScratchCard && !isScratched) {
                          Navigator.of(context)
                              .pushNamed('scratchCard', arguments: offerDetails)
                              .then((_) {
                                if (mounted) setState(() {});
                              });
                        } else {
                          Navigator.of(context).pushNamed(
                            'redemptionInstructions',
                            arguments: offerDetails,
                          );
                        }
                      }
                    },
                  ),
                  if (isPartner) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Status: ',
                          style: kSmallTitleM.copyWith(
                            color: kSecondaryTextColor,
                          ),
                        ),
                        _buildStatusChip(offerStatus),
                      ],
                    ),
                  ],
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom
                        : 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 8, left: 4),
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: kSecondaryTextColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    String displayStatus = status.replaceAll('_', ' ').toUpperCase();

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = const Color(0xFFDEF7EC);
        textColor = const Color(0xFF03543F);
        break;
      case 'pending_approval':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case 'paused':
        bgColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF374151);
        break;
      case 'expired':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      case 'rejected':
        bgColor = const Color(0xFFFDE8E8);
        textColor = const Color(0xFF9B1C1C);
        break;
      case 'draft':
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF4B5563);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: kSmallTitleL.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildHighlightRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: kSmallerTitleM.copyWith(color: kSecondaryTextColor),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: kSmallTitleSB.copyWith(color: kTextColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
