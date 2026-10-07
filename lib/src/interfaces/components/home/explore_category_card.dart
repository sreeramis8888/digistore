import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    final apiIcon = category.iconUrl?.trim();
    final hasApiIcon =
        apiIcon != null && apiIcon.isNotEmpty && apiIcon != 'null';

    // Prefer backend iconUrl; local SVG only if API has none.
    final icon = hasApiIcon
        ? apiIcon
        : ((fallbackAsset != null && fallbackAsset!.isNotEmpty)
              ? fallbackAsset!
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
          Positioned(
            left: 8,
            top: 8,
            right: 8,
            // Leave room for the icon at the bottom.
            bottom: iconSize + 10,
            child: _CategoryTitle(text: name, color: theme.titleColor),
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
    final isNetwork =
        pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://');

    if (isNetwork) {
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
        errorWidget: (_, _, _) {
          final fallback = fallbackAsset;
          if (fallback != null && fallback.isNotEmpty) {
            return SvgPicture.asset(
              fallback,
              fit: BoxFit.contain,
              alignment: Alignment.bottomLeft,
            );
          }
          return const Icon(
            Icons.category_outlined,
            size: 24,
            color: Colors.grey,
          );
        },
      );
    }

    if (pathOrUrl.endsWith('.svg') || pathOrUrl.startsWith('assets/')) {
      return SvgPicture.asset(
        pathOrUrl,
        fit: BoxFit.contain,
        alignment: Alignment.bottomLeft,
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

/// Wraps category titles only at spaces. A single long word (e.g. Accommodation)
/// is scaled down to stay on one line — never split mid-word.
class _CategoryTitle extends StatelessWidget {
  final String text;
  final Color color;

  const _CategoryTitle({required this.text, required this.color});

  TextStyle get _style => TextStyle(
    fontFamily: 'Poppins',
    color: color,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  double _measure(String value, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  /// Build up to 2 lines, breaking only where there is a space.
  List<String> _linesForWidth(String raw, double maxWidth, TextStyle style) {
    final words = raw.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return const [];
    if (words.length == 1) return [words.first];

    final lines = <String>[];
    var current = words.first;

    for (var i = 1; i < words.length; i++) {
      final candidate = '$current ${words[i]}';
      if (_measure(candidate, style) <= maxWidth) {
        current = candidate;
        continue;
      }
      lines.add(current);
      current = words[i];
      if (lines.isNotEmpty) {
        // Remaining words go on the last line (ellipsis if needed).
        current = [current, ...words.skip(i + 1)].join(' ');
        break;
      }
    }
    lines.add(current);
    return lines.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final words = trimmed.split(RegExp(r'\s+'));

        // One word only — never wrap; shrink to fit so the full word shows.
        if (words.length == 1) {
          return Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(trimmed, maxLines: 1, softWrap: false, style: style),
            ),
          );
        }

        final lines = _linesForWidth(trimmed, maxWidth, style);

        // If the first line is a single word wider than the card, scale it.
        final firstNeedsScale =
            lines.isNotEmpty && _measure(lines.first, style) > maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < lines.length; i++)
              if (i == 0 && firstNeedsScale)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    lines[i],
                    maxLines: 1,
                    softWrap: false,
                    style: style,
                  ),
                )
              else
                Text(
                  lines[i],
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
          ],
        );
      },
    );
  }
}
