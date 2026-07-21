import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../components/advanced_network_image.dart';
import '../../components/confirmation_dialog.dart';
import '../../../data/providers/partner_products_provider.dart';
import '../../../data/providers/user_type_provider.dart';
import '../../../data/providers/shops_provider.dart';
import 'create_product.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

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
            const SnackBar(content: Text('No such shop found for this product.')),
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

  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(userTypeProvider);
    final isPartner = userType == UserType.partner;
    
    final product = widget.product;
    final partnerObj = product['partner'] ?? product['partnerId'];
    final String partnerId = (partnerObj is Map)
        ? (partnerObj['_id'] ?? partnerObj['id'] ?? '')
        : (partnerObj?.toString() ?? '');
        
    final String shopName = product['shopName'] ??
        (partnerObj is Map && partnerObj['businessDetails'] != null ? partnerObj['businessDetails']['businessName'] : null) ??
        '';
        
    final String? shopLogo = product['shopLogo'] ??
        (partnerObj is Map && partnerObj['businessInfo'] != null ? partnerObj['businessInfo']['businessLogo'] : null);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Product Details', style: kSmallTitleM),
        centerTitle: false,titleSpacing: 0,
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
                          builder: (context) => CreateProductPage(product: product),
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
                        message: 'Are you sure you want to delete this product?',
                        confirmText: 'Delete',
                        isDestructive: true,
                        onConfirm: () async {
                          try {
                            await ref.read(partnerProductsProvider.notifier).deleteProduct(product['_id'] ?? product['id']);
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
                        Navigator.pop(context); // Go back to products list
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
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AdvancedNetworkImage(
                imageUrl: (product['images'] != null && (product['images'] as List).isNotEmpty) ? product['images'][0] : (product['image'] ?? ''),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isPartner) ...[
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
                                    shopName.isNotEmpty ? shopName : 'Partner Shop',
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
                  Text(
                    product['title'] ?? product['name'] ?? '',
                    style: kBodyTitleM.copyWith(fontSize: 24),
                  ),
                  if (product['price'] != null && (product['price'] is num ? product['price'] > 0 : (product['price'].toString().trim().isNotEmpty && product['price'].toString().trim() != '0' && product['price'].toString().trim() != '0.0'))) ...[
                    const SizedBox(height: 8),
                    Text(
                      product['price'] is num ? '₹ ${product['price']}' : (product['price']?.toString() ?? ''),
                      style: kBodyTitleL.copyWith(fontSize: 24),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (product['description'] != null &&
                      product['description'].isNotEmpty) ...[
                    Text('Description', style: kSmallTitleM),
                    const SizedBox(height: 8),
                    Text(
                      product['description'] ?? '',
                      style: kSmallerTitleL.copyWith(color: Color(0xFF4E4E4E)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
