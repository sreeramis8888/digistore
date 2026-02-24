import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../advanced_network_image.dart';

class ShopGallery extends ConsumerWidget {
  const ShopGallery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    final imageUrls = [
      'https://images.unsplash.com/photo-1555396273-367dd4bc4b27?auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1570197781417-0a52377c0c71?auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1563805042-7684c8a9e9cb?auto=format&fit=crop&q=80',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gallery', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final isLast = index == 3;
            return SizedBox(
              width: screenSize.responsivePadding(75),
              height: screenSize.responsivePadding(75),
              child: Stack(
                fit: StackFit.loose,
                children: [
                  AdvancedNetworkImage(
                    imageUrl: imageUrls[index],
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                    width: screenSize.responsivePadding(75),
                    height: screenSize.responsivePadding(75),
                  ),
                  if (isLast)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '+3 more',
                        style: kSmallTitleSB.copyWith(color: kWhite),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
