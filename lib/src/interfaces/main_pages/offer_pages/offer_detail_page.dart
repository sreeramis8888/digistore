import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/primary_button.dart';
import '../../../data/utils/global_variables.dart';
import '../../../data/utils/date_formatter.dart';

import '../../../data/providers/offers_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/services/toast_service.dart';
import '../../components/confirmation_dialog.dart';
import '../partner/create_offer_page.dart';

class OfferDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;

  const OfferDetailPage({super.key, required this.args});

  @override
  ConsumerState<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends ConsumerState<OfferDetailPage> {
  bool isRedeeming = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final String title = widget.args['title'] ?? '';
    final String subtitle = widget.args['subtitle'] ?? widget.args['description'] ?? '';
    final String? imageUrl = widget.args['imageUrl'] ??
        ((widget.args['images'] is List && (widget.args['images'] as List).isNotEmpty)
            ? widget.args['images'][0]
            : null);
    final String shopName = widget.args['shopName'] ??
        widget.args['partnerId']?['businessDetails']?['businessName'] ??
        'HomeGoods';
    final String? shopLogo = widget.args['shopLogo'] ??
        widget.args['partnerId']?['businessInfo']?['businessLogo'];
    final IconData? icon = widget.args['icon'];
    final String? logoText = widget.args['logoText'];
    final Color? logoColor = widget.args['logoColor'];

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
          style: kSmallerTitleB.copyWith(color: kTextColor, fontSize: 16),
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
                      );

                      if (confirm == true && context.mounted) {
                        try {
                          await ref
                              .read(offersProvider.notifier)
                              .deleteOffer(widget.args['_id'] ?? widget.args['id'] ?? '');
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
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
            if (imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: AdvancedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.zero,
                ),
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
                  Row(
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
                        child: Text(
                          shopName,
                          style: kBodyTitleB.copyWith(fontSize: 24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(title, style: kSubHeadingL.copyWith(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: kBodyTitleSB.copyWith(
                      color: kSecondaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

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
                  else ...[
                    _buildBulletPoint(
                      'Get an exclusive reward to upgrade your experience!',
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'Eligibility: Offer valid for early claimers. Non-transferable.',
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'Refund Policy: Rewards once claimed cannot be reversed.',
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'Support: For queries, contact us via support channel.',
                    ),
                  ],
                  const SizedBox(height: 32),
                  PrimaryButton(
                    textSize: 14,
                    isLoading: isRedeeming,
                    text: GlobalVariables.isPartner
                        ? 'Initiate Redemption'
                        : 'Redeem Now',
                    onPressed: () {
                      final offerDetails = {
                        ...widget.args,
                        'title': title,
                        'subtitle': subtitle,
                        'imageUrl': imageUrl,
                        'id': widget.args['id'] ?? widget.args['_id'],
                      };
                      if (GlobalVariables.isPartner) {
                        Navigator.of(context).pushNamed(
                          'partnerRedemption',
                          arguments: offerDetails,
                        );
                      } else {
                        Navigator.of(context).pushNamed(
                          'redemptionInstructions',
                          arguments: offerDetails,
                        );
                      }
                    },
                  ),
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
}
