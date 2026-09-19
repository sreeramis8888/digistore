import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/category_model.dart';

class _ExploreCategoryTheme {
  final Color backgroundColor;
  final Color border;
  final Color titleColor;

  const _ExploreCategoryTheme({
    required this.backgroundColor,
    required this.border,
    required this.titleColor,
  });
}

const Map<String, _ExploreCategoryTheme> _namedThemes = {
  'Restaurants & Cafes': _ExploreCategoryTheme(
    backgroundColor: Color(0xFFFFF4E5),
    border: Color(0xFFFFE7CC),
    titleColor: Color(0xFF7E3B0C),
  ),
  'Restaurants': _ExploreCategoryTheme(
    backgroundColor: Color(0xFFFFF4E5),
    border: Color(0xFFFFE7CC),
    titleColor: Color(0xFF7E3B0C),
  ),
  'Beauty & Wellness': _ExploreCategoryTheme(
    backgroundColor: Color(0xFFFDEBF5),
    border: Color(0xFFFBD7EC),
    titleColor: Color(0xFF7E1C59),
  ),
  'Automotive Services': _ExploreCategoryTheme(
    backgroundColor: Color(0xFFEBF3FC),
    border: Color(0xFFD6E6F9),
    titleColor: Color(0xFF1C427E),
  ),
  'Fitness & Sports': _ExploreCategoryTheme(
    backgroundColor: Color(0xFFEAF6ED),
    border: Color(0xFFD3EED8),
    titleColor: Color(0xFF1B5E20),
  ),
  'Daily Needs': _ExploreCategoryTheme(
    backgroundColor: Color(0xFFEAF6ED),
    border: Color(0xFFD3EED8),
    titleColor: Color(0xFF1B5E20),
  ),
  'Personal Care': _ExploreCategoryTheme(
    backgroundColor: Color(0xFFFFF4E5),
    border: Color(0xFFFFE7CC),
    titleColor: Color(0xFF7E3B0C),
  ),
  'Medical': _ExploreCategoryTheme(
    backgroundColor: Color(0xFFEBF3FC),
    border: Color(0xFFD6E6F9),
    titleColor: Color(0xFF1C427E),
  ),
  'Fashion': _ExploreCategoryTheme(
    backgroundColor: Color(0xFFFDEBF5),
    border: Color(0xFFFBD7EC),
    titleColor: Color(0xFF7E1C59),
  ),
  'Home Services': _ExploreCategoryTheme(
    backgroundColor: Color(0xFFEBF3FC),
    border: Color(0xFFD6E6F9),
    titleColor: Color(0xFF1C427E),
  ),
};

const _defaultThemes = [
  _ExploreCategoryTheme(
    backgroundColor: Color(0xFFFFF4E5),
    border: Color(0xFFFFE7CC),
    titleColor: Color(0xFF7E3B0C),
  ),
  _ExploreCategoryTheme(
    backgroundColor: Color(0xFFFDEBF5),
    border: Color(0xFFFBD7EC),
    titleColor: Color(0xFF7E1C59),
  ),
  _ExploreCategoryTheme(
    backgroundColor: Color(0xFFEBF3FC),
    border: Color(0xFFD6E6F9),
    titleColor: Color(0xFF1C427E),
  ),
  _ExploreCategoryTheme(
    backgroundColor: Color(0xFFEAF6ED),
    border: Color(0xFFD3EED8),
    titleColor: Color(0xFF1B5E20),
  ),
];

/// Pastel explore category card (Figma home — Explore Categories).
class ExploreCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final String? fallbackAsset;
  final double width;
  final double height;
  final double iconSize;

  const ExploreCategoryCard({
    super.key,
    required this.category,
    required this.index,
    this.fallbackAsset,
    this.width = 108,
    this.height = 80,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final name = category.name ?? '';
    final theme =
        _namedThemes[name] ?? _defaultThemes[index % _defaultThemes.length];

    // Always prioritize local SVG icons from fallbackAsset if available
    final icon = (fallbackAsset != null && fallbackAsset!.isNotEmpty)
        ? fallbackAsset!
        : ((category.iconUrl != null &&
                  category.iconUrl != 'null' &&
                  category.iconUrl!.trim().isNotEmpty)
              ? category.iconUrl!.trim()
              : 'assets/svg/daily_needs.svg');

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                name,
                style: GoogleFonts.montserrat(
                  color: theme.titleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 6,
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: _buildVisual(icon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisual(String pathOrUrl) {
    if (pathOrUrl.endsWith('.svg')) {
      return SvgPicture.asset(
        pathOrUrl,
        fit: BoxFit.contain,
        alignment: Alignment.bottomLeft,
      );
    }

    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      final isSvg = pathOrUrl.toLowerCase().contains('.svg');
      if (isSvg) {
        return SvgPicture.network(
          pathOrUrl,
          fit: BoxFit.contain,
          alignment: Alignment.bottomLeft,
          placeholderBuilder: (_) => const SizedBox.shrink(),
        );
      }
      return CachedNetworkImage(
        imageUrl: pathOrUrl,
        fit: BoxFit.contain,
        alignment: Alignment.bottomLeft,
        errorWidget: (_, _, _) =>
            const Icon(Icons.category_outlined, size: 24, color: Colors.grey),
      );
    }

    return Image.asset(
      pathOrUrl,
      fit: BoxFit.contain,
      alignment: Alignment.bottomLeft,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.category_outlined, size: 24, color: Colors.grey),
    );
  }
}
