import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';

class ShopBranches extends ConsumerWidget {
  const ShopBranches({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final branches = ['Kochi', 'Kottayam', 'Karunagapally'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Branches', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Wrap(
          spacing: screenSize.responsivePadding(8),
          runSpacing: screenSize.responsivePadding(8),
          children: branches.map((branch) {
            final isSelected = branch == 'Kochi';
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
                vertical: screenSize.responsivePadding(8),
              ),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0XFFDFEAFF) : kWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? kPrimaryColor : kBorder),
              ),
              child: Text(
                branch,
                style: kSmallTitleM.copyWith(
                  color: isSelected ? kPrimaryColor : kSecondaryTextColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
