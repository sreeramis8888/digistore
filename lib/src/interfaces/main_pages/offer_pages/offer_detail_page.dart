import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/providers/offers_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/providers/user_type_provider.dart';
import '../../../data/services/toast_service.dart';
import '../../../data/utils/date_formatter.dart';
import '../../../data/utils/global_variables.dart';
import '../../components/advanced_network_image.dart';
import '../../components/confirmation_dialog.dart';
import '../../components/full_screen_gallery.dart';
import '../../components/guest_login_dialog.dart';
import '../partner/create_offer_page.dart';

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

  void _openGallery({
    required List<String> images,
    required String? initialUrl,
  }) {
    if (images.isEmpty) return;
    final initialIndex = initialUrl != null
        ? images.indexOf(initialUrl).clamp(0, images.length - 1)
        : 0;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenGallery(
            images: images,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _navigateToShop(String partnerId) async {
    if (isNavigatingToShop || partnerId.isEmpty) return;
    setState(() {
      isNavigatingToShop = true;
    });

    try {
      final shop = await ref.read(getShopByPartnerIdProvider(partnerId).future);
      if (!mounted) return;
      if (shop != null) {
        Navigator.of(context).pushNamed('shopDetail', arguments: shop);
      } else {
        ToastService().showToast(
          context,
          'No such shop found for this offer.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastService().showToast(
        context,
        'Error loading shop: $e',
        type: ToastType.error,
      );
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

    final ShopModel? fetchedShop = partnerId.isNotEmpty
        ? ref.watch(getShopByPartnerIdProvider(partnerId)).value
        : null;

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

    final dealsJson = widget.args['deals'];
    DealsModel? deals;
    if (cachedOffer?.deals != null) {
      deals = cachedOffer!.deals;
    } else if (dealsJson != null) {
      if (dealsJson is Map<String, dynamic>) {
        deals = DealsModel.fromJson(dealsJson);
      } else if (dealsJson is Map) {
        deals = DealsModel.fromJson(Map<String, dynamic>.from(dealsJson));
      }
    }

    String? activeDealText;
    if (deals != null) {
      if (deals.dealOfMonth?.isActive == true) {
        activeDealText = 'Deal of the Month';
      } else if (deals.dealOfWeek?.isActive == true) {
        activeDealText = 'Deal of the Week';
      } else if (deals.dealOfDay?.isActive == true) {
        activeDealText = 'Deal of the Day';
      } else if (deals.dealOfHour?.isActive == true) {
        activeDealText = 'Deal of the Hour';
      }
    }

    List<String> images = [];
    if (widget.args['images'] is List &&
        (widget.args['images'] as List).isNotEmpty) {
      images = (widget.args['images'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      images = [imageUrl];
    }

    final rawShopName =
        widget.args['shopName'] ??
        widget.args['partnerId']?['businessDetails']?['businessName'] ??
        '';
    final String effectiveShopName = rawShopName.isNotEmpty
        ? rawShopName
        : (fetchedShop?.businessDetails?.businessName ?? 'Partner Shop');

    final rawShopLogo =
        widget.args['shopLogo'] ??
        widget.args['partnerId']?['businessInfo']?['businessLogo'];
    final String? effectiveShopLogo = (rawShopLogo != null && rawShopLogo.isNotEmpty)
        ? rawShopLogo
        : (fetchedShop?.businessInfo?.businessLogo ?? fetchedShop?.businessInfo?.coverImage);

    final rawAddress = [
      if (partnerIdObj is Map && partnerIdObj['addressLine1'] != null && partnerIdObj['addressLine1'].toString().isNotEmpty)
        partnerIdObj['addressLine1'].toString(),
      if (partnerIdObj is Map && partnerIdObj['city'] != null && partnerIdObj['city'].toString().isNotEmpty)
        partnerIdObj['city'].toString(),
    ].join(', ');
    final String effectiveShopAddress = rawAddress.isNotEmpty
        ? rawAddress
        : (fetchedShop?.businessDetails?.address ?? '');

    final IconData? icon = widget.args['icon'];
    final String? logoText = widget.args['logoText'];
    final Color? logoColor = widget.args['logoColor'];

    final priceRange = widget.args['priceRange'];
    final discountRange = widget.args['discountRange'];

    final branchApplicability = widget.args['branchApplicability'];
    final branchLocationsObj = widget.args['branchLocations'];
    final List branchLocations =
        branchLocationsObj is List ? branchLocationsObj : [];

    bool isAllBranches = false;
    List specificBranches = [];

    if (branchApplicability != null && branchApplicability is Map) {
      if (branchApplicability['type'] == 'all') {
        isAllBranches = true;
      } else if (branchApplicability['type'] == 'specific') {
        final branchIdsObj = branchApplicability['branchIds'];
        final List branchIds = branchIdsObj is List ? branchIdsObj : [];
        final List<String> stringBranchIds =
            branchIds.map((e) => e.toString()).toList();

        specificBranches = branchLocations.where((branch) {
          if (branch is! Map) return false;
          final String bId = branch['branchId']?.toString() ?? '';
          return stringBranchIds.contains(bId);
        }).toList();
      }
    }

    bool hasPriceRange = priceRange != null &&
        priceRange.toString() != 'null' &&
        (priceRange is Map ? priceRange.isNotEmpty : priceRange.toString().isNotEmpty);
    bool hasDiscountRange = discountRange != null &&
        discountRange.toString() != 'null' &&
        (discountRange is Map
            ? discountRange.isNotEmpty
            : discountRange.toString().isNotEmpty);

    String getPriceRangeText() {
      if (priceRange is Map) {
        final min = priceRange['min'] ?? 0;
        final max = priceRange['max'] ?? 0;
        final minStr = (min is num) ? min.toStringAsFixed(2) : min.toString();
        final maxStr = (max is num) ? max.toStringAsFixed(2) : max.toString();
        return '₹$minStr - ₹$maxStr';
      }
      if (priceRange is num) {
        return priceRange.toStringAsFixed(2);
      }
      return priceRange.toString();
    }

    String getDiscountRangeText() {
      final rawType = widget.args['discountType'];
      final discountType = rawType?.toString().toLowerCase();
      final isFlat = discountType == 'flat' ||
          discountType == 'amount' ||
          discountType == 'fixed';

      if (discountRange is Map) {
        final min = discountRange['min'] ?? 0;
        final max = discountRange['max'] ?? 0;
        final minStr = (min is num && min % 1 != 0)
            ? min.toStringAsFixed(1)
            : min.toString();
        final maxStr = (max is num && max % 1 != 0)
            ? max.toStringAsFixed(1)
            : max.toString();
        if (min == max) {
          return isFlat ? '₹$minStr OFF' : '$minStr% OFF';
        }
        return isFlat ? '₹$minStr - ₹$maxStr OFF' : '$minStr% - $maxStr% OFF';
      }
      if (discountRange is num) {
        final val = (discountRange % 1 != 0)
            ? discountRange.toStringAsFixed(1)
            : discountRange.toString();
        return isFlat ? '₹$val OFF' : '$val% OFF';
      }
      return discountRange.toString();
    }

    String? categoryName;
    final catObj = cachedOffer?.category?.name ?? widget.args['category'];
    if (catObj is String && catObj.isNotEmpty) {
      categoryName = catObj;
    } else if (catObj is Map && catObj['name'] != null) {
      categoryName = catObj['name'].toString();
    } else if (catObj is CategoryModel) {
      categoryName = catObj.name;
    }

    final List<String> subcategories = [];
    final rawSubs = widget.args['subcategories'] ??
        cachedOffer?.subcategories ??
        widget.args['subcategory'] ??
        cachedOffer?.subcategory ??
        widget.args['partnerId']?['serviceCategories'] ??
        cachedOffer?.partnerId?.serviceCategories;

    void addSubcategory(dynamic s) {
      if (s == null) return;
      if (s is String && s.trim().isNotEmpty && s != 'null') {
        final val = s.trim();
        if (!subcategories.contains(val)) subcategories.add(val);
      } else if (s is Map) {
        final name = s['name'] ??
            s['category'] ??
            s['title'] ??
            s['subCategoryName'];
        if (name != null &&
            name.toString().trim().isNotEmpty &&
            name.toString() != 'null') {
          final val = name.toString().trim();
          if (!subcategories.contains(val)) subcategories.add(val);
        }
      }
    }

    if (rawSubs is List) {
      for (final s in rawSubs) {
        addSubcategory(s);
      }
    } else if (rawSubs is String && rawSubs.trim().isNotEmpty) {
      if (rawSubs.trim().startsWith('[')) {
        try {
          final decoded = json.decode(rawSubs);
          if (decoded is List) {
            for (final s in decoded) {
              addSubcategory(s);
            }
          }
        } catch (_) {
          addSubcategory(rawSubs);
        }
      } else {
        addSubcategory(rawSubs);
      }
    } else if (rawSubs is Map) {
      addSubcategory(rawSubs);
    }

    final floatingTagText = activeDealText ??
        categoryName ??
        (subcategories.isNotEmpty ? subcategories.first : null);

    final validToStr = widget.args['validTo'] ?? cachedOffer?.validTo?.toString();
    final validToDate = validToStr != null ? DateTime.tryParse(validToStr)?.toLocal() : null;

    final termsList = (widget.args['terms'] is List)
        ? (widget.args['terms'] as List).map((e) => e.toString()).toList()
        : <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF373737),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Offer Details',
          style: GoogleFonts.urbanist(
            color: const Color(0xFF373737),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image Banner (200px height with border and floating tag)
                  GestureDetector(
                    onTap: images.isNotEmpty
                        ? () => _openGallery(
                              images: images,
                              initialUrl: images.isNotEmpty
                                  ? images[_currentImageIndex.clamp(0, images.length - 1)]
                                  : null,
                            )
                        : null,
                    child: Container(
                      width: double.infinity,
                      height: screenSize.responsivePadding(200),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (images.isNotEmpty)
                            CarouselSlider(
                              options: CarouselOptions(
                                height: screenSize.responsivePadding(200),
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
                                return SizedBox(
                                  width: double.infinity,
                                  child: AdvancedNetworkImage(
                                    imageUrl: img,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.zero,
                                    disableFade: true,
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            Container(
                              color: const Color(0xFFE5E7EB),
                              alignment: Alignment.center,
                              child: icon != null
                                  ? Icon(icon, size: 64, color: kPrimaryColor)
                                  : (logoText != null && logoColor != null)
                                  ? Container(
                                      color: logoColor,
                                      alignment: Alignment.center,
                                      child: Text(
                                        logoText,
                                        style: GoogleFonts.urbanist(
                                          color: logoColor == Colors.white
                                              ? kTextColor
                                              : Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: Color(0xFF9CA3AF),
                                    ),
                            ),

                          // Floating Tag Pill (Top-Left)
                          if (floatingTagText != null && floatingTagText.isNotEmpty)
                            Positioned(
                              top: 10,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  floatingTagText,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF292929),
                                  ),
                                ),
                              ),
                            ),

                          // Carousel Dots Indicator (Bottom-Center)
                          if (images.length > 1)
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: images.asMap().entries.map((entry) {
                                  final isActive = _currentImageIndex == entry.key;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: isActive ? 18.0 : 6.0,
                                    height: 6.0,
                                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.0),
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Shop Info Card (Top rounded 24px, Merchant Header, Divider, Offer Titles)
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      screenSize.responsivePadding(20),
                      screenSize.responsivePadding(16),
                      screenSize.responsivePadding(20),
                      screenSize.responsivePadding(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Merchant / Shop Header Row
                        if (!(widget.args['hideShopInfo'] ?? false) && !isPartner) ...[
                          InkWell(
                            onTap: partnerId.isNotEmpty
                                ? () => _navigateToShop(partnerId)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                // Logo (52x52 Circle with 2px border)
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                      width: 2,
                                    ),
                                    color: const Color(0xFFF3F4F6),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: effectiveShopLogo != null && effectiveShopLogo.isNotEmpty
                                      ? AdvancedNetworkImage(
                                          imageUrl: effectiveShopLogo,
                                          fit: BoxFit.cover,
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.storefront,
                                            color: Color(0xFF6B7280),
                                            size: 24,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        effectiveShopName,
                                        style: GoogleFonts.urbanist(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF111827),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (effectiveShopAddress.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Color(0xFF6B7280),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                effectiveShopAddress,
                                                style: GoogleFonts.urbanist(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(0xFF6B7280),
                                                ),
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
                                if (partnerId.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  if (isNavigatingToShop)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF6155F5),
                                        ),
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                ],
                              ],
                            ),
                          ),

                          // Divider
                          const SizedBox(height: 16),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF3F4F6),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Offer Title & Subtitle
                        Text(
                          title,
                          style: GoogleFonts.urbanist(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        if (subtitle.isNotEmpty &&
                            subtitle != 'null' &&
                            subtitle != 'nil') ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ],

                        // Category & Subcategories chips
                        if (subcategories.isNotEmpty || (categoryName != null && categoryName.isNotEmpty)) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (categoryName != null && categoryName.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    categoryName,
                                    style: GoogleFonts.urbanist(
                                      color: const Color(0xFF6155F5),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ...subcategories.map(
                                (sub) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Text(
                                    sub,
                                    style: GoogleFonts.urbanist(
                                      color: const Color(0xFF374151),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Scratch Card Revealed Banner
                        if (isScratchCard && isScratched && awardedDiscount != null) ...[
                          const SizedBox(height: 16),
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
                                    'Scratch card revealed! You got $awardedDiscount% OFF.',
                                    style: GoogleFonts.urbanist(
                                      color: const Color(0xFF03543F),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Separator Band (8px grey)
                  const SizedBox(
                    width: double.infinity,
                    height: 8,
                    child: ColoredBox(color: Color(0xFFF3F4F6)),
                  ),

                  // Details & Terms Card (Figma Node 2158:2280)
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.all(screenSize.responsivePadding(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details & Terms',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C1C1C),
                          ),
                        ),
                        if (validToDate != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Expires on: ${formatOfferDate(validToDate)}',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1C),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (termsList.isNotEmpty)
                          ...termsList.map(
                            (term) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _buildBulletPoint(term),
                            ),
                          )
                        else if (subtitle.isNotEmpty && subtitle != 'null')
                          Text(
                            subtitle,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF4E4E4E),
                              height: 1.6,
                            ),
                          )
                        else
                          Text(
                            'No specific terms provided.',
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF4E4E4E),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Available At / Branch Locations (Preserved & Modernized)
                  if (isAllBranches || specificBranches.isNotEmpty) ...[
                    const SizedBox(
                      width: double.infinity,
                      height: 8,
                      child: ColoredBox(color: Color(0xFFF3F4F6)),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(screenSize.responsivePadding(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6155F5).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: Color(0xFF6155F5),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Available At',
                                style: GoogleFonts.urbanist(
                                  color: const Color(0xFF6155F5),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (isAllBranches)
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Available on all branches',
                                  style: GoogleFonts.urbanist(
                                    color: const Color(0xFF374151),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          else
                            ...specificBranches.asMap().entries.map((entry) {
                              final index = entry.key;
                              final branch = entry.value;
                              final isLast = index == specificBranches.length - 1;
                              final branchName =
                                  branch['branchName']?.toString() ?? 'Branch';
                              final address =
                                  branch['address']?.toString() ?? '';
                              final city = branch['city']?.toString() ?? '';
                              final locationDetails = [address, city]
                                  .where((e) => e.trim().isNotEmpty)
                                  .join(', ');
                              return Padding(
                                padding:
                                    EdgeInsets.only(bottom: isLast ? 0 : 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2.0),
                                      child: Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                        color: Color(0xFF6155F5),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            branchName,
                                            style: GoogleFonts.urbanist(
                                              color: const Color(0xFF111827),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          if (locationDetails.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              locationDetails,
                                              style: GoogleFonts.urbanist(
                                                color: const Color(0xFF6B7280),
                                                fontSize: 12,
                                              ),
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
                  ],

                  // Offer Highlights / Price & Discount Ranges (Preserved & Modernized)
                  if (hasPriceRange || hasDiscountRange) ...[
                    const SizedBox(
                      width: double.infinity,
                      height: 8,
                      child: ColoredBox(color: Color(0xFFF3F4F6)),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(screenSize.responsivePadding(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6155F5).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFF6155F5),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Offer Highlights',
                                style: GoogleFonts.urbanist(
                                  color: const Color(0xFF6155F5),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
                  ],

                  if (isPartner) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Status: ',
                          style: GoogleFonts.urbanist(
                            color: const Color(0xFF6B7280),
                            fontSize: 13,
                          ),
                        ),
                        _buildStatusChip(offerStatus),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Bar CTA (Figma Node 2158:2286)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              screenSize.responsivePadding(16),
              screenSize.responsivePadding(10),
              screenSize.responsivePadding(16),
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 10
                  : screenSize.responsivePadding(20),
            ),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isPartner && !isOfferActive) || isRedeeming
                    ? null
                    : () {
                        if (GlobalVariables.isGuest) {
                          GuestLoginDialog.show(
                            context,
                            title: 'Login Required',
                            subtitle:
                                'Please login or register to claim offers.',
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
                                .pushNamed('scratchCard',
                                    arguments: offerDetails)
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6155F5),
                  disabledBackgroundColor: const Color(0xFF6155F5).withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isRedeeming
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isPartner ? 'Initiate Redemption' : 'Redeem Now',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, right: 8, left: 4),
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF6B7280),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4E4E4E),
              height: 1.5,
            ),
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
        style: GoogleFonts.urbanist(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildHighlightRow(
      IconData icon, String label, String value, Color color) {
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
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

