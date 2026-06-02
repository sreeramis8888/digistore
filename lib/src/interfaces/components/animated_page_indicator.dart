import 'package:flutter/material.dart';

class AnimatedPageIndicator extends StatelessWidget {
  final PageController controller;
  final int itemCount;
  final Color activeColor;
  final Color inactiveColor;
  final double dotHeight;
  final double activeDotWidth;
  final double inactiveDotWidth;
  final double spacing;

  const AnimatedPageIndicator({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.activeColor,
    required this.inactiveColor,
    this.dotHeight = 6.0,
    this.activeDotWidth = 24.0,
    this.inactiveDotWidth = 6.0,
    this.spacing = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double currentPage = 0.0;
        if (controller.hasClients) {
          currentPage = controller.page ?? 0.0;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(itemCount, (index) {
            final distance = (currentPage - index).abs();
            final factor = (1.0 - distance).clamp(0.0, 1.0);

            // Interpolate width for the stretching capsule effect
            final width = inactiveDotWidth + (activeDotWidth - inactiveDotWidth) * factor;

            // Interpolate color for a smooth transition effect
            final color = Color.lerp(inactiveColor, activeColor, factor) ?? inactiveColor;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: spacing / 2),
              width: width,
              height: dotHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(dotHeight / 2),
              ),
            );
          }),
        );
      },
    );
  }
}
