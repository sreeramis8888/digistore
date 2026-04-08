import 'package:digistore/src/data/services/haptic_helper.dart';
import 'package:flutter/material.dart';

class InteractiveFeedbackButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Function(LongPressEndDetails)? onLongPressEnd;

  final double scaleFactor;
  final Duration duration;

  final HapticImpact tapImpact;
  final HapticImpact longPressImpact;

  const InteractiveFeedbackButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.onLongPressEnd,
    this.scaleFactor = 1.1,
    this.duration = const Duration(milliseconds: 150),
    this.tapImpact = HapticImpact.light,
    this.longPressImpact = HapticImpact.heavy,
  });

  @override
  State<InteractiveFeedbackButton> createState() =>
      _InteractiveFeedbackButtonState();
}

class _InteractiveFeedbackButtonState extends State<InteractiveFeedbackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onPressed == null) return;

    await HapticHelper.impact(widget.tapImpact);
    await _controller.forward();

    widget.onPressed!();

    await _controller.reverse();
  }

  Future<void> _handleLongPress() async {
    if (widget.onLongPress == null) return;

    await HapticHelper.impact(widget.longPressImpact);
    await _controller.forward();

    widget.onLongPress!();
  }

  Future<void> _handleLongPressEnd(LongPressEndDetails details) async {
    await _controller.reverse();

    widget.onLongPressEnd?.call(details);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      onLongPressEnd: _handleLongPressEnd,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
