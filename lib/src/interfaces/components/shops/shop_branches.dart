import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/business_info.dart';
import '../../../../src/data/providers/branches.dart';

class ShopBranches extends ConsumerWidget {
  final String shopId;
  final BusinessBranch? selectedBranch;
  final ValueChanged<BusinessBranch?> onBranchSelected;

  const ShopBranches({
    super.key,
    required this.shopId,
    required this.selectedBranch,
    required this.onBranchSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (shopId.isEmpty) return const SizedBox.shrink();

    final screenSize = ref.watch(screenSizeProvider);
    final branchesAsync = ref.watch(shopBranchesProvider(shopId));

    return branchesAsync.when(
      data: (branches) {
        if (branches.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Branches', style: kSmallTitleM),
            SizedBox(height: screenSize.responsivePadding(12)),
            Wrap(
              spacing: screenSize.responsivePadding(8),
              runSpacing: screenSize.responsivePadding(8),
              children: [
                // Main branch pill
                _buildBranchPill(
                  screenSize: screenSize,
                  label: 'Main',
                  isSelected: selectedBranch == null,
                  onTap: () => onBranchSelected(null),
                ),
                // Other branches
                ...branches.map((branch) {
                  return _buildBranchPill(
                    screenSize: screenSize,
                    label: branch.name ?? 'Branch',
                    isSelected: selectedBranch == branch,
                    onTap: () => onBranchSelected(branch),
                  );
                }),
              ],
            ),
            SizedBox(height: screenSize.responsivePadding(16)),
          ],
        );
      },
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryColor),
        ),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildBranchPill({
    required ScreenSizeData screenSize,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(16),
          vertical: screenSize.responsivePadding(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0XFFDFEAFF) : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? kPrimaryColor : const Color(0xFFF4F4F4),
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          style: isSelected
              ? kSmallTitleM.copyWith(color: kPrimaryColor)
              : kSmallTitleL.copyWith(color: kSecondaryTextColor),
          child: Text(label),
        ),
      ),
    );
  }
}
