import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';

class ProductsServicesSegmentedTabs extends ConsumerWidget {
  const ProductsServicesSegmentedTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final selectedTab = ref.watch(selectedProductsTabProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
      ),
      child: Container(
        height: 42,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBEC),
          borderRadius: BorderRadius.circular(21),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 2;
            return Stack(
              children: [
                // Smooth Sliding Indicator Pill
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  left: selectedTab == 0 ? 0 : tabWidth,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.22),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Interactive Tab Labels
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (selectedTab != 0) {
                            ref.read(selectedProductsTabProvider.notifier).state = 0;
                          }
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: selectedTab == 0
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: selectedTab == 0
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                            child: const Text('Products'),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (selectedTab != 1) {
                            ref.read(selectedProductsTabProvider.notifier).state = 1;
                          }
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: selectedTab == 1
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: selectedTab == 1
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                            child: const Text('Services'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

