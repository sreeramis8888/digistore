import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/partner_services_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/providers/user_type_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/confirmation_dialog.dart';
import '../../components/primary_button.dart';
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

  Future<void> _navigateToShop(String partnerId) async {
    if (_isNavigatingToShop || partnerId.isEmpty) return;
    setState(() => _isNavigatingToShop = true);

    final messenger = ScaffoldMessenger.of(context);
    try {
      final shop = await ref.read(getShopByPartnerIdProvider(partnerId).future);
      if (!mounted) return;
      if (shop != null) {
        Navigator.of(context).pushNamed('shopDetail', arguments: shop);
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('No shop details found for this service provider.')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error loading shop: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isNavigatingToShop = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(userTypeProvider);
    final isPartner = userType == UserType.partner;
    final screenSize = ref.watch(screenSizeProvider);
    final service = widget.service;

    final partner = service.partner;
    final partnerId = partner?.id ?? service.partnerId ?? '';
    final partnerName = partner?.name ?? 'SetGo Partner';
    final partnerAddress = [
      if (partner?.addressLine1 != null && partner!.addressLine1!.isNotEmpty) partner.addressLine1!,
      if (partner?.city != null && partner!.city!.isNotEmpty) partner.city!,
    ].join(', ');
    final partnerLogo = partner?.logo;

    final hasOffer = service.hasOffer && service.offerPrice != null;
    final displayPrice = hasOffer ? service.offerPrice!.toInt() : service.originalPrice.toInt();
    final originalPrice = service.originalPrice.toInt();
    final discountPercent = hasOffer && originalPrice > 0
        ? (((originalPrice - displayPrice) / originalPrice) * 100).round()
        : 0;

    final showShop = !isPartner && !widget.hideShopInfo && partnerName.isNotEmpty;
    final description = service.description ?? '';

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        surfaceTintColor: kWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Service Details',
          style: kSmallTitleM.copyWith(color: const Color(0xFF111827)),
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
                  // Service Image with Category & Rating Badges
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).orientation == Orientation.landscape
                            ? MediaQuery.of(context).size.height * 0.5
                            : MediaQuery.of(context).size.width * (9 / 16),
                        child: service.images.isNotEmpty
                            ? AdvancedNetworkImage(
                                imageUrl: service.images.first,
                                fit: BoxFit.cover,
                                disableFade: true,
                              )
                            : Container(
                                color: const Color(0xFFF3F4F6),
                                child: const Center(
                                  child: Icon(Icons.spa_rounded, size: 60, color: Color(0xFF9CA3AF)),
                                ),
                              ),
                      ),
                      // Category Badge
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34C759),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            service.category ?? 'Service',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Rating Pill
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                              const SizedBox(width: 4),
                              Text(
                                service.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Name
                        Text(
                          service.name ?? 'Service',
                          style: kBodyTitleB.copyWith(
                            color: const Color(0xFF111827),
                            fontSize: 22,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: screenSize.responsivePadding(8)),

                        // Duration & Price Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF6B7280)),
                                const SizedBox(width: 6),
                                Text(
                                  '${service.durationMinutes} mins',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                if (hasOffer) ...[
                                  Text(
                                    '₹$originalPrice',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF9CA3AF),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  '₹$displayPrice',
                                  style: kBodyTitleB.copyWith(
                                    color: kPrimaryColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (hasOffer && discountPercent > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$discountPercent% OFF',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: screenSize.responsivePadding(16)),
                        const Divider(height: 1, thickness: 1, color: kProductBorder),

                        // Partner Shop Info Card
                        if (showShop) ...[
                          SizedBox(height: screenSize.responsivePadding(16)),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: partnerId.isNotEmpty
                                  ? () => _navigateToShop(partnerId)
                                  : null,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                                decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: kProductBorder),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: kPrimaryLightColor,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: partnerLogo != null && partnerLogo.isNotEmpty
                                          ? AdvancedNetworkImage(
                                              imageUrl: partnerLogo,
                                              fit: BoxFit.cover,
                                              disableFade: true,
                                            )
                                          : const Icon(
                                              Icons.storefront,
                                              color: kPrimaryColor,
                                              size: 20,
                                            ),
                                    ),
                                    SizedBox(width: screenSize.responsivePadding(12)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            partnerName,
                                            style: kSmallTitleB.copyWith(
                                              color: const Color(0xFF111827),
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (partnerAddress.isNotEmpty) ...[
                                            SizedBox(height: screenSize.responsivePadding(4)),
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
                                                    partnerAddress,
                                                    style: kSmallerTitleM.copyWith(
                                                      color: const Color(0xFF6B7280),
                                                      fontSize: 12,
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
                                      SizedBox(width: screenSize.responsivePadding(8)),
                                      if (_isNavigatingToShop)
                                        const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 22,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Service Description
                        if (description.isNotEmpty) ...[
                          SizedBox(height: screenSize.responsivePadding(20)),
                          Text(
                            'About this Service',
                            style: kSmallTitleB.copyWith(
                              color: const Color(0xFF111827),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: screenSize.responsivePadding(8)),
                          Text(
                            description,
                            style: kSmallerTitleM.copyWith(
                              color: const Color(0xFF4B5563),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],

                        SizedBox(height: screenSize.responsivePadding(24)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Bar for Customer Booking Flow
          if (!isPartner)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(20),
                vertical: screenSize.responsivePadding(16),
              ),
              decoration: BoxDecoration(
                color: kWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          '₹$displayPrice',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Book Now',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookServicePage(service: service),
                            ),
                          );
                        },
                      ),
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
