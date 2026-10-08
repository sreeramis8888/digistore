import 'package:flutter/material.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/models/business_info.dart';
import '../advanced_network_image.dart';
import '../animated_page_indicator.dart';
import '../full_screen_gallery.dart';
import '../home/video_banner_player.dart';

/// Swipeable shop cover/gallery that supports images and videos.
class ShopHeroMedia extends StatefulWidget {
  final List<BusinessMediaItem> media;
  final double height;

  const ShopHeroMedia({
    super.key,
    required this.media,
    required this.height,
  });

  @override
  State<ShopHeroMedia> createState() => _ShopHeroMediaState();
}

class _ShopHeroMediaState extends State<ShopHeroMedia> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openGallery(int index) {
    if (widget.media.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenGallery.media(
            media: widget.media,
            initialIndex: index,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;

    if (media.isEmpty) {
      return Container(
        height: widget.height,
        color: const Color(0xFFF3F4F6),
        child: const Center(
          child: Icon(
            Icons.storefront_outlined,
            size: 56,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: media.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final item = media[index];
              final child = item.isVideo
                  ? VideoBannerPlayer(
                      key: ValueKey('shop_hero_video_${item.url}_$index'),
                      videoUrl: item.url,
                      thumbnailUrl: item.thumbnailUrl,
                      isActivePage: index == _currentPage,
                      autoplay: true,
                      loop: true,
                      muted: true,
                      showControls: true,
                    )
                  : AdvancedNetworkImage(
                      imageUrl: item.url,
                      fit: BoxFit.cover,
                    );

              return GestureDetector(
                onTap: () => _openGallery(index),
                child: child,
              );
            },
          ),
          if (media.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: AnimatedPageIndicator(
                  controller: _pageController,
                  itemCount: media.length,
                  activeColor: kWhite,
                  inactiveColor: kWhite.withValues(alpha: 0.45),
                  activeDotWidth: 18,
                  inactiveDotWidth: 6,
                  dotHeight: 6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
