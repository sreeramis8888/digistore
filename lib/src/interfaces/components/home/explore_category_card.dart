import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/category_model.dart';

class _ExploreCategoryTheme {
  final Color gradientStart;
  final Color gradientEnd;
  final Color border;
  final Color titleColor;

  const _ExploreCategoryTheme({
    required this.gradientStart,
    required this.gradientEnd,
    required this.border,
    required this.titleColor,
  });
}

const _exploreThemes = [
  _ExploreCategoryTheme(
    gradientStart: Color(0xFFF3F3F3),
    gradientEnd: Color(0xFFD6F5E3),
    border: Color(0xFFD7F5E4),
    titleColor: Color(0xFF1A5C3A),
  ),
  _ExploreCategoryTheme(
    gradientStart: Color(0xFFF3F3F3),
    gradientEnd: Color(0xFFFFF8F0),
    border: Color(0xFFFFF9F0),
    titleColor: Color(0xFF631F03),
  ),
  _ExploreCategoryTheme(
    gradientStart: Color(0xFFF3F3F3),
    gradientEnd: Color(0xFFDDEEFF),
    border: Color(0xFFDDEEFF),
    titleColor: Color(0xFF1A3A5C),
  ),
  _ExploreCategoryTheme(
    gradientStart: Color(0xFFEAE0FF),
    gradientEnd: Color(0xFFF3F3F3),
    border: Color(0xFFF3F3F3),
    titleColor: Color(0xFF3D1A7B),
  ),
];

/// Pastel explore category card (Figma home — Explore Categories).
class ExploreCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final String? fallbackAsset;
  final double width;
  final double height;

  const ExploreCategoryCard({
    super.key,
    required this.category,
    required this.index,
    this.fallbackAsset,
    this.width = 140,
    this.height = 126,
  });

  @override
  Widget build(BuildContext context) {
    final theme = _exploreThemes[index % _exploreThemes.length];
    final name = category.name ?? '';
    final icon = (category.iconUrl != null &&
            category.iconUrl != 'null' &&
            category.iconUrl!.trim().isNotEmpty)
        ? category.iconUrl!.trim()
        : (fallbackAsset ?? 'assets/svg/daily_needs.svg');

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.gradientStart, theme.gradientEnd],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                name,
                style: kSmallTitleEB.copyWith(
                  color: theme.titleColor,
                  fontSize: 14,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Positioned(
            right: -10,
            bottom: -12,
            child: SizedBox(
              width: 100,
              height: 100,
              child: _buildVisual(icon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisual(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      final isSvg = pathOrUrl.toLowerCase().contains('.svg');
      if (isSvg) {
        return SvgPicture.network(
          pathOrUrl,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => const SizedBox.shrink(),
        );
      }
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: pathOrUrl,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorWidget: (_, _, _) => Icon(
            Icons.category_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    if (pathOrUrl.endsWith('.svg')) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset(pathOrUrl, fit: BoxFit.contain),
      );
    }

    return Image.asset(
      pathOrUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(
        Icons.category_outlined,
        size: 48,
        color: Colors.grey.shade400,
      ),
    );
  }
}
