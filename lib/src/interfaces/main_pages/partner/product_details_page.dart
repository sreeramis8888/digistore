import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/providers/partner_products_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/providers/user_type_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/confirmation_dialog.dart';
import 'create_product.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;
  final bool hideShopInfo;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.hideShopInfo = false,
  });

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  bool isNavigatingToShop = false;

  Future<void> _navigateToShop(String shopOrPartnerId) async {
    if (isNavigatingToShop || shopOrPartnerId.isEmpty) return;
    setState(() {
      isNavigatingToShop = true;
    });

    try {
      final shop = await ref.read(getShopByPartnerIdProvider(shopOrPartnerId).future);
      if (!mounted) return;
      if (shop != null) {
        Navigator.of(context).pushNamed('shopDetail', arguments: shop);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No such shop found for this product.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading shop: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isNavigatingToShop = false;
        });
      }
    }
  }

  String _resolveShopId(Map<String, dynamic> product) {
    final directShopId = product['shopId']?.toString();
    if (directShopId != null && directShopId.isNotEmpty) return directShopId;

    final shopObj = product['shop'];
    if (shopObj is Map) {
      final id = shopObj['_id'] ?? shopObj['id'];
      if (id != null && id.toString().isNotEmpty) return id.toString();
    } else if (shopObj is String && shopObj.isNotEmpty) {
      return shopObj;
    }

    final partnerObj = product['partner'] ?? product['partnerId'];
    if (partnerObj is Map) {
      final id = partnerObj['_id'] ?? partnerObj['id'];
      if (id != null && id.toString().isNotEmpty) return id.toString();
    } else if (partnerObj is String && partnerObj.isNotEmpty) {
      return partnerObj;
    }
    return '';
  }

  String _resolveShopAddress(Map<String, dynamic> product, dynamic partnerObj) {
    final branches = product['branchLocations'];
    if (branches is List && branches.isNotEmpty) {
      final first = branches.first;
      if (first is Map) {
        final address = first['address']?.toString() ?? '';
        final city = first['city']?.toString() ?? '';
        final joined =
            [address, city].where((e) => e.trim().isNotEmpty).join(', ');
        if (joined.isNotEmpty) return joined;
      }
    }

    if (partnerObj is Map) {
      final details = partnerObj['businessDetails'];
      if (details is Map) {
        final address = details['address']?.toString() ?? '';
        final city = details['city']?.toString() ?? '';
        final pincode = details['pincode']?.toString() ?? '';
        final joined = [address, city, pincode]
            .where((e) => e.trim().isNotEmpty)
            .join(', ');
        if (joined.isNotEmpty) return joined;
      }

      final info = partnerObj['businessInfo'];
      if (info is Map) {
        final address = info['address']?.toString() ?? '';
        if (address.trim().isNotEmpty) return address.trim();
      }
    }

    final direct = product['shopAddress']?.toString() ??
        product['address']?.toString() ??
        '';
    return direct.trim();
  }

  List<String> _resolveTags(Map<String, dynamic> product) {
    final tags = product['tags'];
    if (tags is List) {
      return tags
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  bool _hasDisplayPrice(Map<String, dynamic> product) {
    final price = product['price'];
    if (price == null) return false;
    if (price is num) return price > 0;
    final pStr = price.toString().trim();
    return pStr.isNotEmpty && pStr != '0' && pStr != '0.0';
  }

  String _formatPrice(Map<String, dynamic> product) {
    final price = product['price'];
    if (price is num) {
      final val = price.toDouble();
      final formatted =
          val.truncateToDouble() == val ? val.toStringAsFixed(0) : val.toStringAsFixed(2);
      return '₹$formatted';
    }
    String pStr = price?.toString() ?? '';
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(pStr);
    if (match != null) {
      final val = double.tryParse(match.group(1)!);
      if (val != null) {
        final formatted =
            val.truncateToDouble() == val ? val.toStringAsFixed(0) : val.toStringAsFixed(2);
        pStr = pStr.replaceFirst(match.group(1)!, formatted);
      }
    }
    if (pStr.isEmpty) return '';
    return pStr.startsWith('₹') ? pStr : '₹$pStr';
  }

  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(userTypeProvider);
    final isPartner = userType == UserType.partner;
    final screenSize = ref.watch(screenSizeProvider);

    final product = widget.product;
    final partnerObj = product['partner'] ?? product['partnerId'];
    final String partnerId = (partnerObj is Map)
        ? (partnerObj['_id'] ?? partnerObj['id'] ?? '').toString()
        : (partnerObj?.toString() ?? '');

    final String shopId = _resolveShopId(product);
    final String targetShopOrPartnerId = shopId.isNotEmpty ? shopId : partnerId;

    // Fetch full shop data if shop details are minimal
    final ShopModel? fetchedShop = targetShopOrPartnerId.isNotEmpty
        ? ref.watch(getShopByPartnerIdProvider(targetShopOrPartnerId)).value
        : null;

    final String rawShopName = product['shopName'] ??
        (partnerObj is Map && partnerObj['businessDetails'] != null
            ? partnerObj['businessDetails']['businessName']
            : null) ??
        '';
    final String effectiveShopName = rawShopName.isNotEmpty
        ? rawShopName
        : (fetchedShop?.businessDetails?.businessName ?? '');

    final String? rawShopLogo = product['shopLogo'] ??
        (partnerObj is Map && partnerObj['businessInfo'] != null
            ? partnerObj['businessInfo']['businessLogo']
            : null);
    final String? effectiveShopLogo = (rawShopLogo != null && rawShopLogo.isNotEmpty)
        ? rawShopLogo
        : (fetchedShop?.businessInfo?.businessLogo ?? fetchedShop?.businessInfo?.coverImage);

    final String rawShopAddress = _resolveShopAddress(product, partnerObj);
    final String effectiveShopAddress = rawShopAddress.isNotEmpty
        ? rawShopAddress
        : (fetchedShop?.businessDetails?.address ?? '');

    final tags = _resolveTags(product);
    final showShop = !isPartner &&
        !widget.hideShopInfo &&
        !(widget.product['hideShopInfo'] ?? false) &&
        (targetShopOrPartnerId.isNotEmpty || effectiveShopName.isNotEmpty);

    final currentProductId =
        (product['_id'] ?? product['id'])?.toString();
    final hasPrice = _hasDisplayPrice(product);
    final title = product['title'] ?? product['name'] ?? '';
    final description = product['description']?.toString() ?? '';

    final imageUrl = (product['images'] != null &&
            (product['images'] as List).isNotEmpty)
        ? product['images'][0]?.toString()
        : (product['image']?.toString() ?? '');

    // Products of this shop for "You May Also Like"
    final shopProductsAsync = targetShopOrPartnerId.isNotEmpty
        ? ref.watch(shopProductsProvider(targetShopOrPartnerId))
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
          'Product Details',
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
                          builder: (context) =>
                              CreateProductPage(product: product),
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
                        title: 'Delete Product',
                        message:
                            'Are you sure you want to delete this product?',
                        confirmText: 'Delete',
                        isDestructive: true,
                        onConfirm: () async {
                          try {
                            await ref
                                .read(partnerProductsProvider.notifier)
                                .deleteProduct(
                                  product['_id'] ?? product['id'],
                                );
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Hero Image
            Container(
              width: double.infinity,
              height: screenSize.responsivePadding(300),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1),
                ),
              ),
              child: (imageUrl != null && imageUrl.isNotEmpty)
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
                    title,
                    style: GoogleFonts.urbanist(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  if (hasPrice) ...[
                    SizedBox(height: screenSize.responsivePadding(6)),
                    Text(
                      _formatPrice(product),
                      style: GoogleFonts.urbanist(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF07838C),
                      ),
                    ),
                  ],
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
                                      effectiveShopName.isNotEmpty
                                          ? effectiveShopName
                                          : 'Partner Shop',
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
                                if (isNavigatingToShop)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
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
              // Product Details & Tags Card
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(screenSize.responsivePadding(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Details',
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

            // "You May Also Like" - Cross-sell section featuring shop products
            if (shopProductsAsync != null)
              shopProductsAsync.when(
                data: (shopProducts) {
                  final relatedProducts = shopProducts
                      .where((p) => p.id != null && p.id != currentProductId)
                      .toList();

                  if (relatedProducts.isEmpty) return const SizedBox.shrink();

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
                            itemCount: relatedProducts.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: screenSize.responsivePadding(12)),
                            itemBuilder: (context, index) {
                              final recProduct = relatedProducts[index];
                              return _buildRecommendationCard(
                                context,
                                recProduct,
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
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    ProductModel productModel,
    ScreenSizeData screenSize,
  ) {
    final title = productModel.title ?? '';
    final price = productModel.price;
    final image = productModel.images?.isNotEmpty == true
        ? productModel.images!.first
        : null;

    final formattedPrice = price != null
        ? (price.truncateToDouble() == price
            ? '₹${price.toStringAsFixed(0)}'
            : '₹${price.toStringAsFixed(2)}')
        : '';

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
                builder: (context) => ProductDetailsPage(
                  product: productModel.toJson(),
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
                if (formattedPrice.isNotEmpty)
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

