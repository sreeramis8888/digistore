import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import 'advanced_network_image.dart';

class FullScreenGallery extends ConsumerStatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  ConsumerState<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends ConsumerState<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      backgroundColor: kBlack,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Hero(
                  tag: 'gallery_image_${widget.images[index]}_$index',
                  child: Center(
                    child: AdvancedNetworkImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          
          Positioned(
            top: MediaQuery.paddingOf(context).top,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
                vertical: screenSize.responsivePadding(8),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kBlack.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: kWhite),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: kBodyTitleM.copyWith(color: kWhite),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + screenSize.responsivePadding(20),
            left: 0,
            right: 0,
            child: SizedBox(
              height: screenSize.responsivePadding(60),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  final isSelected = _currentIndex == index;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: screenSize.responsivePadding(8)),
                      width: isSelected 
                          ? screenSize.responsivePadding(60) 
                          : screenSize.responsivePadding(50),
                      height: isSelected 
                          ? screenSize.responsivePadding(60) 
                          : screenSize.responsivePadding(50),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? kWhite : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AdvancedNetworkImage(
                            imageUrl: widget.images[index],
                            fit: BoxFit.cover,
                          ),
                          if (!isSelected)
                            Container(
                              color: kBlack.withOpacity(0.4),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
