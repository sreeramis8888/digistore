import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../advanced_network_image.dart';

import 'video_banner_player.dart';
import '../animated_page_indicator.dart';

import '../../../data/models/banner_model.dart';
import '../../../data/utils/launch_url.dart';
import '../../../data/services/deep_link_service.dart';
import '../../../data/providers/offers_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/services/snackbar_service.dart';
import '../../main_pages/offer_pages/active_deals_page.dart';

class BannerSection extends ConsumerStatefulWidget {
  final List<BannerModel>? banners;
  const BannerSection({super.key, this.banners});

  @override
  ConsumerState<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends ConsumerState<BannerSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleBannerTap(BannerModel banner) async {
    final linkType = banner.linkType?.toLowerCase();
    final linkId = banner.linkId;
    final externalUrl = banner.externalUrl;
    final deepLink = banner.deepLink;

    if (linkType == 'offer' && linkId != null && linkId.isNotEmpty) {
      await _navigateToOffer(linkId);
      return;
    }

    if (linkType == 'shop' && linkId != null && linkId.isNotEmpty) {
      await _navigateToShop(linkId);
      return;
    }

    if (linkType == 'external_url' && externalUrl != null && externalUrl.isNotEmpty) {
      await launchURL(externalUrl);
      return;
    }

    if (linkType == 'deep_link' && deepLink != null && deepLink.isNotEmpty) {
      final uri = Uri.tryParse(deepLink);
      if (uri != null) {
        ref.read(deepLinkServiceProvider).handleDeepLink(uri);
      }
      return;
    }

    if (linkType == 'category' && linkId != null && linkId.isNotEmpty) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveDealsPage(
              dealType: 'category',
              dealTitle: banner.title ?? 'Category Deals',
            ),
          ),
        );
      }
      return;
    }

    // Fallbacks if linkType is not set or general link fields exist
    if (deepLink != null && deepLink.isNotEmpty) {
      final uri = Uri.tryParse(deepLink);
      if (uri != null) {
        ref.read(deepLinkServiceProvider).handleDeepLink(uri);
        return;
      }
    }

    if (externalUrl != null && externalUrl.isNotEmpty) {
      await launchURL(externalUrl);
      return;
    }
  }

  Future<void> _navigateToOffer(String offerId) async {
    try {
      final offer = await ref.read(getOfferByIdProvider(offerId).future);
      if (offer != null && mounted) {
        Navigator.of(context).pushNamed('offerDetail', arguments: offer.toJson());
      } else if (mounted) {
        SnackbarService().showSnackBar(
          context,
          'Offer not found',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarService().showSnackBar(
          context,
          'Unable to load offer',
          type: SnackbarType.error,
        );
      }
    }
  }

  Future<void> _navigateToShop(String shopId) async {
    try {
      final shop = await ref.read(getShopByPartnerIdProvider(shopId).future);
      if (shop != null && mounted) {
        Navigator.of(context).pushNamed('shopDetail', arguments: shop);
      } else if (mounted) {
        SnackbarService().showSnackBar(
          context,
          'Shop not found',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarService().showSnackBar(
          context,
          'Unable to load shop',
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners == null || widget.banners!.isEmpty) return const SizedBox.shrink();
    final screenSize = ref.watch(screenSizeProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.banners!.length,
              itemBuilder: (context, index) {
                final banner = widget.banners![index];
                final isVideo = banner.isVideo;

                Widget childWidget;
                if (isVideo) {
                  childWidget = VideoBannerPlayer(
                    key: ValueKey('vbp_${banner.id ?? banner.videoUrl ?? index.toString()}'),
                    videoUrl: banner.videoUrl!,
                    thumbnailUrl: banner.effectiveThumbnailUrl,
                    isActivePage: index == _currentPage,
                    autoplay: banner.videoAutoplay ?? true,
                    loop: banner.videoLoop ?? true,
                    muted: banner.videoMuted ?? true,
                    showControls: banner.videoControls ?? true,
                  );
                } else {
                  childWidget = AdvancedNetworkImage(
                    imageUrl: banner.image ?? '',
                    borderRadius: BorderRadius.circular(16),
                    fit: BoxFit.cover,
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(4),
                  ),
                  child: GestureDetector(
                    onTap: () => _handleBannerTap(banner),
                    child: childWidget,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(8)),
          AnimatedPageIndicator(
            controller: _pageController,
            itemCount: widget.banners!.length,
            activeColor: kPrimaryColor,
            inactiveColor: kBorder,
            activeDotWidth: 30.0,
            inactiveDotWidth: 5.0,
            dotHeight: 6.0,
          ),
        ],
      ),
    );
  }
}
