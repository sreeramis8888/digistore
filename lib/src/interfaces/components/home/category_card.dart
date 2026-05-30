import 'package:setgo/src/data/constants/style_constants.dart';
import 'package:setgo/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryCard extends ConsumerWidget {
  final Map<String, dynamic> category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Container(
      width: screenSize.responsivePadding(80),
      height: screenSize.responsivePadding(118),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFF96D4FB)],
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.responsivePadding(12),
          horizontal: screenSize.responsivePadding(4),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB0DFF9), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: screenSize.responsivePadding(55),
              height: screenSize.responsivePadding(55),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5F5F5).withOpacity(.55),
              ),
              child: Center(
                child: _buildIcon(category['icon'] as String),
              ),
            ),
            SizedBox(height: screenSize.responsivePadding(8)),
            Text(
              category['name'] as String,
              style: kSmallTitleL.copyWith(fontSize: 11, height: 1.2),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String iconPathOrUrl) {
    final cleanPath = iconPathOrUrl.trim();
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      if (cleanPath.toLowerCase().endsWith('.svg') ||
          cleanPath.toLowerCase().contains('.svg')) {
        return SvgPicture.network(
          cleanPath,
          width: 26,
          height: 26,
          placeholderBuilder: (context) => const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF96D4FB)),
            ),
          ),
        );
      } else {
        return CachedNetworkImage(
          imageUrl: cleanPath,
          width: 26,
          height: 26,
          fit: BoxFit.contain,
          placeholder: (context, url) => const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF96D4FB)),
            ),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.category_outlined,
            size: 26,
            color: Colors.grey,
          ),
        );
      }
    } else {
      if (cleanPath.endsWith('.svg')) {
        return SvgPicture.asset(
          cleanPath,
          width: 26,
          height: 26,
        );
      } else {
        return Image.asset(
          cleanPath,
          width: 26,
          height: 26,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.category_outlined,
            size: 26,
            color: Colors.grey,
          ),
        );
      }
    }
  }
}
