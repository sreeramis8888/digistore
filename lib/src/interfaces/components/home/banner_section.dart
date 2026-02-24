import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class BannerSection extends ConsumerStatefulWidget {
  const BannerSection({super.key});

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

  @override
  Widget build(BuildContext context) {
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
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(4),
                  ),
                  decoration: BoxDecoration(
                    color: kGreyLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Icon(Icons.image, size: 48, color: kGrey),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                width: index == _currentPage ? 30 : 5,
                height: 6,
                decoration: BoxDecoration(
                  color: index == _currentPage ? kPrimaryColor : kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
