import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';

class AdvancedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final IconData? errorIcon;

  const AdvancedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.errorIcon,
  });

  @override
  Widget build(BuildContext context) {
    final cleanedUrl = imageUrl.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (width == null || !width!.isFinite)
            ? (constraints.maxWidth == double.infinity
                  ? 100.0
                  : constraints.maxWidth)
            : width!;
        final h = (height == null || !height!.isFinite)
            ? (constraints.maxHeight == double.infinity
                  ? 100.0
                  : constraints.maxHeight)
            : height!;

        if (cleanedUrl.isEmpty ||
            cleanedUrl == 'null' ||
            cleanedUrl == 'undefined') {
          return errorWidget ?? _buildErrorPlaceholder(w, h);
        }

        final fallbackW = w;
        final fallbackH = h;

        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: cleanedUrl.startsWith('assets/')
              ? Image.asset(
                  cleanedUrl,
                  width: width,
                  height: height,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) =>
                      errorWidget ?? _buildErrorPlaceholder(w, h),
                )
              : CachedNetworkImage(
                  imageUrl: cleanedUrl,
                  width: width,
                  height: height,
                  fit: fit,
                  placeholder: (context, url) => _AdvancedShimmer(
                    width: fallbackW,
                    height: fallbackH,
                    borderRadius: borderRadius,
                  ),
                  errorWidget: (context, url, error) =>
                      errorWidget ?? _buildErrorPlaceholder(w, h),
                ),
        );
      },
    );
  }

  Widget _buildErrorPlaceholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: borderRadius ?? BorderRadius.zero,
        border: Border.all(color: const Color(0xFFE8F0FF).withOpacity(0.5)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                errorIcon ?? Icons.storefront,
                size: w * 0.5,
                color: kPrimaryColor,
              ),
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
  final BorderRadius? borderRadius;

  const _AdvancedShimmer({
    required this.width,
    required this.height,
    this.borderRadius,
  });

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
            borderRadius: widget.borderRadius,
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
