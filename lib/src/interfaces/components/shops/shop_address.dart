import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../advanced_network_image.dart';

class ShopAddress extends ConsumerWidget {
  const ShopAddress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Address', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Text(
          '1st Floor, Chill Nagar Tower, Panampallynagar Ernakulam',
          style: kSmallTitleR.copyWith(color: kSecondaryTextColor, height: 1.5),
        ),
        SizedBox(height: screenSize.responsivePadding(12)),
        // Map placeholder container based on user input "for the map just show the address for now"
        // The image shows a map, but we'll use a clean representation that meets the criteria
        SizedBox(
          width: double.infinity,
          height: screenSize.responsivePadding(120),
          child: Stack(
            children: [
              const Positioned.fill(
                child: AdvancedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80',
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(12),
                    vertical: screenSize.responsivePadding(8),
                  ),
                  decoration: BoxDecoration(
                    color: kWhite.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      SizedBox(width: screenSize.responsivePadding(8)),
                      Text('Chill Bite', style: kSmallTitleM),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
