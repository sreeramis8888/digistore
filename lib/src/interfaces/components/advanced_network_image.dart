import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';

class AdvancedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AdvancedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cleanedUrl = imageUrl.trim();
    if (cleanedUrl.isEmpty ||
        cleanedUrl == 'null' ||
        cleanedUrl == 'undefined') {
      return _buildErrorPlaceholder();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = width ?? constraints.maxWidth;
        final h = height ?? constraints.maxHeight;

        final fallbackW = w == double.infinity ? 100.0 : w;
        final fallbackH = h == double.infinity ? 100.0 : h;

        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: cleanedUrl.startsWith('assets/')
              ? Image.asset(
                  cleanedUrl,
                  width: width,
                  height: height,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    width: width,
                    height: height,
                    child: _buildErrorPlaceholder(),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: cleanedUrl,
                  width: width,
                  height: height,
                  fit: fit,
                  placeholder: (context, url) => SizedBox(
                    width: width,
                    height: height,
                    child: _AdvancedShimmer(
                      width: fallbackW,
                      height: fallbackH,
                    ),
                  ),
                  errorWidget: (context, url, error) => SizedBox(
                    width: width,
                    height: height,
                    child: _buildErrorPlaceholder(),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF3F4F6),
                    const Color(0xFFE5E7EB).withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.image_not_supported_rounded,
              color: kSecondaryTextColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedShimmer extends StatefulWidget {
  final double width;
  final double height;

  const _AdvancedShimmer({required this.width, required this.height});

  @override
  State<_AdvancedShimmer> createState() => _AdvancedShimmerState();
}

class _AdvancedShimmerState extends State<_AdvancedShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFFF3F4F6),
                Color(0xFFF9FAFB),
                Color(0xFFE5E7EB),
                Color(0xFFF9FAFB),
                Color(0xFFF3F4F6),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              begin: const Alignment(-1.0, -0.5),
              end: const Alignment(2.0, 0.5),
              transform: _TranslateGradientTransform(_controller.value),
            ),
          ),
        );
      },
    );
  }
}

class _TranslateGradientTransform extends GradientTransform {
  final double percent;

  const _TranslateGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final w = bounds.width;
    return Matrix4.translationValues(w * (percent * 2 - 1), 0.0, 0.0);
  }
}
