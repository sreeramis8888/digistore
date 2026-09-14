import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../components/advanced_network_image.dart';
import '../../components/confirmation_dialog.dart';
import '../../components/products/related_products_section.dart';
import '../../../data/providers/partner_products_provider.dart';
import '../../../data/providers/user_type_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No such shop found for this product.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading shop: $e')),
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

  String? _resolveCategoryId(Map<String, dynamic> product) {
    final category = product['category'];
    if (category is String && category.isNotEmpty) return category;
    if (category is Map) {
      final id = category['_id'] ?? category['id'];
      if (id != null && id.toString().isNotEmpty) return id.toString();
    }
    return null;
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

    final String shopName = product['shopName'] ??
        (partnerObj is Map && partnerObj['businessDetails'] != null
            ? partnerObj['businessDetails']['businessName']
            : null) ??
        '';

    final String? shopLogo = product['shopLogo'] ??
        (partnerObj is Map && partnerObj['businessInfo'] != null
            ? partnerObj['businessInfo']['businessLogo']
            : null);

    final shopAddress = _resolveShopAddress(product, partnerObj);
    final tags = _resolveTags(product);
    final showShop = !isPartner &&
        !widget.hideShopInfo &&
        !(widget.product['hideShopInfo'] ?? false);
    final currentProductId =
        (product['_id'] ?? product['id'])?.toString();
    final categoryId = _resolveCategoryId(product);
    final hasPrice = _hasDisplayPrice(product);
    final title = product['title'] ?? product['name'] ?? '';
    final description = product['description']?.toString() ?? '';

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
          'Product Details',
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
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).orientation == Orientation.landscape
                  ? MediaQuery.of(context).size.height * 0.5
                  : MediaQuery.of(context).size.width * (9 / 16),
              child: AdvancedNetworkImage(
                imageUrl: (product['images'] != null &&
                        (product['images'] as List).isNotEmpty)
                    ? product['images'][0]
                    : (product['image'] ?? ''),
                fit: BoxFit.cover,
                disableFade: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: kBodyTitleB.copyWith(
                      color: const Color(0xFF111827),
                      fontSize: 22,
                      height: 1.25,
                    ),
                  ),
                  if (hasPrice) ...[
                    SizedBox(height: screenSize.responsivePadding(8)),
                    Text(
                      _formatPrice(product),
                      style: kBodyTitleB.copyWith(
                        color: kProductAccentTeal,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  SizedBox(height: screenSize.responsivePadding(16)),
                  const Divider(height: 1, thickness: 1, color: kProductBorder),
                  if (showShop) ...[
                    SizedBox(height: screenSize.responsivePadding(16)),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: partnerId.isNotEmpty
                            ? () => _navigateToShop(context, partnerId)
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: EdgeInsets.all(
                            screenSize.responsivePadding(12),
                          ),
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
                                child: shopLogo != null && shopLogo.isNotEmpty
                                    ? AdvancedNetworkImage(
                                        imageUrl: shopLogo,
                                        fit: BoxFit.cover,
                                        disableFade: true,
                                      )
                                    : const Icon(
                                        Icons.storefront,
                                        color: kPrimaryColor,
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
                                      shopName.isNotEmpty
                                          ? shopName
                                          : 'Partner Shop',
                                      style: kSmallTitleB.copyWith(
                                        color: const Color(0xFF111827),
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (shopAddress.isNotEmpty) ...[
                                      SizedBox(
                                        height:
                                            screenSize.responsivePadding(4),
                                      ),
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
                                              shopAddress,
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
                                SizedBox(
                                  width: screenSize.responsivePadding(8),
                                ),
                                if (isNavigatingToShop)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        kProductAccentTeal,
                                      ),
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
                  if (description.isNotEmpty) ...[
                    SizedBox(height: screenSize.responsivePadding(20)),
                    Text(
                      'Product Details',
                      style: kSmallTitleB.copyWith(
                        color: const Color(0xFF111827),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(8)),
                    Text(
                      description,
                      style: kSmallerTitleL.copyWith(
                        color: const Color(0xFF4B5563),
                        height: 1.45,
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
                                horizontal: screenSize.responsivePadding(12),
                                vertical: screenSize.responsivePadding(6),
                              ),
                              decoration: BoxDecoration(
                                color: kProductTagBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kProductBorder),
                              ),
                              child: Text(
                                tag,
                                style: kSmallerTitleM.copyWith(
                                  color: kProductAccentTeal,
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
            SizedBox(height: screenSize.responsivePadding(8)),
            RelatedProductsSection(
              currentProductId: currentProductId,
              categoryId: categoryId,
            ),
            SizedBox(height: screenSize.responsivePadding(32)),
          ],
        ),
      ),
    );
  }
}
