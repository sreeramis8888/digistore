import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/providers/partner_services_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/providers/user_type_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/confirmation_dialog.dart';
import '../../components/full_screen_gallery.dart';
import '../partner/create_service.dart';
import 'book_service_page.dart';

class ServiceDetailsPage extends ConsumerStatefulWidget {
  final ServiceModel service;
  final bool hideShopInfo;

  const ServiceDetailsPage({
    super.key,
    required this.service,
    this.hideShopInfo = false,
  });

  @override
  ConsumerState<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends ConsumerState<ServiceDetailsPage> {
  bool _isNavigatingToShop = false;

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

  Future<void> _navigateToShop(String shopOrPartnerId) async {
    if (_isNavigatingToShop || shopOrPartnerId.isEmpty) return;
    setState(() => _isNavigatingToShop = true);

    try {
      final shop = await ref.read(getShopByPartnerIdProvider(shopOrPartnerId).future);
      if (!mounted) return;
      if (shop != null) {
        Navigator.of(context).pushNamed('shopDetail', arguments: shop);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No shop details found for this service provider.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading shop: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isNavigatingToShop = false);
      }
    }
  }

  List<String> _resolveTags(ServiceModel service) {
    final List<String> tags = [];
    final cat = service.categoryName ?? service.category;
    if (cat != null && cat.trim().isNotEmpty) {
      tags.add(cat.trim());
    }
    if (service.subCategory != null &&
        service.subCategory!.trim().isNotEmpty &&
        !tags.contains(service.subCategory!.trim())) {
      tags.add(service.subCategory!.trim());
    }
    if (service.durationMinutes > 0) {
      tags.add('${service.durationMinutes} mins');
    }
    for (final tag in service.tags) {
      if (tag.trim().isNotEmpty && !tags.contains(tag.trim())) {
        tags.add(tag.trim());
      }
    }
    for (final addOn in service.addOns) {
      if (addOn.name.trim().isNotEmpty && !tags.contains(addOn.name.trim())) {
        tags.add(addOn.name.trim());
      }
    }
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(userTypeProvider);
    final isPartner = userType == UserType.partner;
    final screenSize = ref.watch(screenSizeProvider);
    final service = widget.service;

    final partner = service.partner;
    final partnerId = partner?.id ?? service.partnerId ?? '';
    final targetShopOrPartnerId = partnerId;

    // Fetch full shop data if shop details are minimal
    final ShopModel? fetchedShop = targetShopOrPartnerId.isNotEmpty
        ? ref.watch(getShopByPartnerIdProvider(targetShopOrPartnerId)).value
        : null;

    final String rawPartnerName = partner?.name ?? '';
    final String effectiveShopName = rawPartnerName.isNotEmpty && rawPartnerName != 'SetGo Partner'
        ? rawPartnerName
        : (fetchedShop?.businessDetails?.businessName ?? rawPartnerName.ifEmpty('Partner Shop'));

    final String? rawPartnerLogo = partner?.logo;
    final String? effectiveShopLogo = (rawPartnerLogo != null && rawPartnerLogo.isNotEmpty)
        ? rawPartnerLogo
        : (fetchedShop?.businessInfo?.businessLogo ?? fetchedShop?.businessInfo?.coverImage);

    final rawPartnerAddress = [
      if (partner?.addressLine1 != null && partner!.addressLine1!.isNotEmpty) partner.addressLine1!,
      if (partner?.city != null && partner!.city!.isNotEmpty) partner.city!,
    ].join(', ');
    final String effectiveShopAddress = rawPartnerAddress.isNotEmpty
        ? rawPartnerAddress
        : (fetchedShop?.businessDetails?.address ?? '');

    final hasOffer = service.hasOffer && service.offerPrice != null;
    final displayPrice = hasOffer
        ? (service.offerPrice!.truncateToDouble() == service.offerPrice
            ? service.offerPrice!.toStringAsFixed(0)
            : service.offerPrice!.toStringAsFixed(2))
        : (service.originalPrice.truncateToDouble() == service.originalPrice
            ? service.originalPrice.toStringAsFixed(0)
            : service.originalPrice.toStringAsFixed(2));

    final showShop = !isPartner &&
        !widget.hideShopInfo &&
        (targetShopOrPartnerId.isNotEmpty || effectiveShopName.isNotEmpty);

    final description = service.description ?? '';
    final tags = _resolveTags(service);

    final imageUrl = service.images.isNotEmpty ? service.images.first : '';
    final allImages = service.images.isNotEmpty
        ? service.images
        : (imageUrl.isNotEmpty ? [imageUrl] : <String>[]);

    // Services of this shop for "You May Also Like"
    final shopServicesAsync = targetShopOrPartnerId.isNotEmpty
        ? ref.watch(storeServicesProvider(targetShopOrPartnerId))
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF373737), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Service Details',
          style: GoogleFonts.urbanist(
            color: const Color(0xFF373737),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: isPartner
            ? [
                Container(
                  height: 32,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateServicePage(existingService: service),
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
                        title: 'Delete Service',
                        message: 'Are you sure you want to delete this service?',
                        confirmText: 'Delete',
                        isDestructive: true,
                        onConfirm: () async {
                          try {
                            if (service.id != null) {
                              await ref
                                    .read(partnerServicesProvider.notifier)
                                    .deleteService(service.id!);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
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
                  // Service Hero Image
                  GestureDetector(
                    onTap: allImages.isNotEmpty
                        ? () => _openGallery(images: allImages, initialUrl: imageUrl)
                        : null,
                    child: Container(
                      width: double.infinity,
                      height: screenSize.responsivePadding(300),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1),
                        ),
                      ),
                      child: (imageUrl.isNotEmpty)
                          ? AdvancedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              disableFade: true,
                            )
                          : Container(
                              color: const Color(0xFFE5E7EB),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Separator
                  const SizedBox(
                    width: double.infinity,
                    height: 8,
                    child: ColoredBox(color: Color(0xFFF3F4F6)),
                  ),

                  // Core Info Card (Title, Price, Merchant)
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(20),
                      vertical: screenSize.responsivePadding(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: GoogleFonts.urbanist(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: screenSize.responsivePadding(6)),
                        Text(
                          '₹$displayPrice',
                          style: GoogleFonts.urbanist(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF07838C),
                          ),
                        ),
                        if (showShop) ...[
                          SizedBox(height: screenSize.responsivePadding(16)),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE5E7EB),
                          ),
                          SizedBox(height: screenSize.responsivePadding(16)),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: targetShopOrPartnerId.isNotEmpty
                                  ? () => _navigateToShop(targetShopOrPartnerId)
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: EdgeInsets.all(
                                  screenSize.responsivePadding(12),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F5F4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                          width: 1.5,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: effectiveShopLogo != null &&
                                              effectiveShopLogo.isNotEmpty
                                          ? AdvancedNetworkImage(
                                              imageUrl: effectiveShopLogo,
                                              fit: BoxFit.cover,
                                              disableFade: true,
                                            )
                                          : const Icon(
                                              Icons.storefront,
                                              color: Color(0xFF07838C),
                                              size: 20,
                                            ),
                                    ),
                                    SizedBox(
                                      width: screenSize.responsivePadding(12),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            effectiveShopName,
                                            style: GoogleFonts.urbanist(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF111827),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (effectiveShopAddress.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 12,
                                                  color: Color(0xFF4B5563),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    effectiveShopAddress,
                                                    style: GoogleFonts.urbanist(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                      color: const Color(0xFF4B5563),
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
                                    if (targetShopOrPartnerId.isNotEmpty) ...[
                                      SizedBox(
                                        width: screenSize.responsivePadding(8),
                                      ),
                                      if (_isNavigatingToShop)
                                        const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFF07838C),
                                            ),
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 20,
                                          color: Color(0xFF4B5563),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Separator
                  if (description.isNotEmpty || tags.isNotEmpty) ...[
                    const SizedBox(
                      width: double.infinity,
                      height: 8,
                      child: ColoredBox(color: Color(0xFFF3F4F6)),
                    ),
                    // Service Details & Tags Card
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(screenSize.responsivePadding(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Details',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            SizedBox(height: screenSize.responsivePadding(12)),
                            Text(
                              description,
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF4B5563),
                                height: 1.54,
                              ),
                            ),
                          ],
                          if (tags.isNotEmpty) ...[
                            SizedBox(height: screenSize.responsivePadding(14)),
                            Wrap(
                              spacing: screenSize.responsivePadding(8),
                              runSpacing: screenSize.responsivePadding(8),
                              children: tags
                                  .map(
                                    (tag) => Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            screenSize.responsivePadding(12),
                                        vertical:
                                            screenSize.responsivePadding(6),
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F5F4),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: GoogleFonts.urbanist(
                                          color: const Color(0xFF07838C),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // "You May Also Like" - Cross-sell section featuring shop services
                  if (shopServicesAsync != null)
                    shopServicesAsync.when(
                      data: (shopServices) {
                        final relatedServices = shopServices
                            .where((s) => s.id != null && s.id != service.id)
                            .toList();

                        if (relatedServices.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            screenSize.responsivePadding(20),
                            screenSize.responsivePadding(20),
                            screenSize.responsivePadding(20),
                            screenSize.responsivePadding(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You May Also Like',
                                style: GoogleFonts.urbanist(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: screenSize.responsivePadding(14)),
                              SizedBox(
                                height: screenSize.responsivePadding(210),
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  clipBehavior: Clip.none,
                                  itemCount: relatedServices.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(width: screenSize.responsivePadding(12)),
                                  itemBuilder: (context, index) {
                                    final recService = relatedServices[index];
                                    return _buildRecommendationCard(
                                      context,
                                      recService,
                                      screenSize,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),

                  SizedBox(height: screenSize.responsivePadding(24)),
                ],
              ),
            ),
          ),

          // Sticky Bottom Bar with Book Now button
          if (!isPartner)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                screenSize.responsivePadding(16),
                screenSize.responsivePadding(10),
                screenSize.responsivePadding(16),
                screenSize.responsivePadding(16),
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookServicePage(service: service),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6155F5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Book Now',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    ServiceModel serviceModel,
    ScreenSizeData screenSize,
  ) {
    final title = serviceModel.name;
    final price = serviceModel.hasOffer && serviceModel.offerPrice != null
        ? serviceModel.offerPrice!
        : serviceModel.originalPrice;
    final image = serviceModel.images.isNotEmpty ? serviceModel.images.first : null;

    final formattedPrice = price.truncateToDouble() == price
        ? '₹${price.toStringAsFixed(0)}'
        : '₹${price.toStringAsFixed(2)}';

    return Container(
      width: screenSize.responsivePadding(180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceDetailsPage(
                  service: serviceModel,
                  hideShopInfo: widget.hideShopInfo,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(screenSize.responsivePadding(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: screenSize.responsivePadding(124),
                    child: image != null && image.isNotEmpty
                        ? AdvancedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            disableFade: true,
                          )
                        : Container(
                            color: const Color(0xFFF3F5F4),
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Color(0xFF9CA3AF),
                                size: 28,
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(8)),
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenSize.responsivePadding(4)),
                Text(
                  formattedPrice,
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF07838C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

