import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/category_model.dart';
import '../safe_network_icon.dart';

/// Explore category tile — rounded icon box with label underneath.
/// Icons come from the API (`category.iconUrl`); local SVG is fallback only.
class ExploreCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final String? fallbackAsset;
  final double width;
  final double height;
  final double iconSize;

  const ExploreCategoryCard({
    super.key,
    required this.category,
    this.fallbackAsset,
    this.width = 76,
    this.height = 110,
    this.iconSize = 64,
  });

  static const _tileBg = Color(0xFFF3F4F8);
  static const _labelColor = Color(0xFF6B7280);
  static const _iconColor = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final name = (category.name ?? '').trim();

    final apiIcon = category.iconUrl?.trim();
    final hasApiIcon =
        apiIcon != null && apiIcon.isNotEmpty && apiIcon != 'null';

    final icon = hasApiIcon
        ? apiIcon
        : ((fallbackAsset != null && fallbackAsset!.isNotEmpty)
              ? fallbackAsset!
              : 'assets/svg/daily_needs.svg');

    final pad = iconSize * 0.22;

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: _tileBg,
              borderRadius: BorderRadius.circular(iconSize * 0.28),
            ),
            child: _buildVisual(icon),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: _labelColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static bool _isSvgPath(String pathOrUrl) {
    final lower = pathOrUrl.toLowerCase();
    final path = Uri.tryParse(lower)?.path ?? lower.split('?').first;
    return path.endsWith('.svg');
  }

  Widget _fallbackVisual() {
    final fallback = fallbackAsset;
    if (fallback != null && fallback.isNotEmpty) {
      return SvgPicture.asset(
        fallback,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(
          Icons.category_outlined,
          size: 24,
          color: _iconColor,
        ),
      );
    }
    return const Icon(
      Icons.category_outlined,
      size: 24,
      color: _iconColor,
    );
  }

  Widget _buildVisual(String pathOrUrl) {
    final isNetwork =
        pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://');

    if (isNetwork) {
      // Sniff bytes — API often serves JPEG/PNG with a .svg filename.
      return SafeNetworkIcon(
        url: pathOrUrl,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox.shrink(),
        errorBuilder: (_) => _fallbackVisual(),
      );
    }

    if (_isSvgPath(pathOrUrl) || pathOrUrl.startsWith('assets/')) {
      return SvgPicture.asset(
        pathOrUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(
          Icons.category_outlined,
          size: 24,
          color: _iconColor,
        ),
      );
    }

    return Image.asset(
      pathOrUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Icon(
        Icons.category_outlined,
        size: 24,
        color: _iconColor,
      ),
    );
  }
}
