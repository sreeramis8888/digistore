import 'package:flutter/material.dart';

/// Offer price + original price with an animated strikethrough
/// (same pattern as service / product detail pages).
class OfferPriceRow extends StatefulWidget {
  final String offerPrice;
  final String originalPrice;
  final double gap;
  final double offerFontSize;
  final double originalFontSize;

  const OfferPriceRow({
    super.key,
    required this.offerPrice,
    required this.originalPrice,
    this.gap = 8,
    this.offerFontSize = 26,
    this.originalFontSize = 16,
  });

  @override
  State<OfferPriceRow> createState() => _OfferPriceRowState();
}

class _OfferPriceRowState extends State<OfferPriceRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offerFade;
  late final Animation<Offset> _offerSlide;
  late final Animation<double> _strike;
  late final Animation<double> _originalFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _offerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _offerSlide = Tween<Offset>(
      begin: const Offset(-0.08, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _strike = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.78, curve: Curves.easeInOutCubic),
    );
    _originalFade = Tween<double>(begin: 1, end: 0.55).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant OfferPriceRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offerPrice != widget.offerPrice ||
        oldWidget.originalPrice != widget.originalPrice) {
      _controller
        ..reset()
        ..forward();
    }
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
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SlideTransition(
              position: _offerSlide,
              child: FadeTransition(
                opacity: _offerFade,
                child: Text(
                  widget.offerPrice,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: widget.offerFontSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF07838C),
                    height: 1,
                  ),
                ),
              ),
            ),
            SizedBox(width: widget.gap),
            Opacity(
              opacity: _originalFade.value,
              child: CustomPaint(
                foregroundPainter: _StrikeThroughPainter(
                  progress: _strike.value,
                  color: const Color(0xFF9CA3AF),
                ),
                child: Text(
                  widget.originalPrice,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: widget.originalFontSize,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StrikeThroughPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _StrikeThroughPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final y = size.height * 0.55;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width * progress, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(_StrikeThroughPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
