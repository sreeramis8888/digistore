import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';

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
        height: 41,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBEC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabItem(
                title: 'Products',
                isSelected: selectedTab == 0,
                onTap: () {
                  ref.read(selectedProductsTabProvider.notifier).state = 0;
                },
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildTabItem(
                title: 'Services',
                isSelected: selectedTab == 1,
                onTap: () {
                  ref.read(selectedProductsTabProvider.notifier).state = 1;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InteractiveFeedbackButton(
      onPressed: onTap,
      scaleFactor: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: (isSelected ? kSmallTitleSB : kSmallTitleM).copyWith(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
