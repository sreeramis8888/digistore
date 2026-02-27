import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';

class ShopBranches extends ConsumerStatefulWidget {
  const ShopBranches({super.key});

  @override
  ConsumerState<ShopBranches> createState() => _ShopBranchesState();
}

class _ShopBranchesState extends ConsumerState<ShopBranches> {
  String _selectedBranch = 'Kochi';

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final branches = ['Kochi', 'Kottayam', 'Karunagapally'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Branches', style: kSmallTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Wrap(
          spacing: screenSize.responsivePadding(8),
          runSpacing: screenSize.responsivePadding(8),
          children: branches.map((branch) {
            final isSelected = branch == _selectedBranch;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedBranch = branch;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16),
                  vertical: screenSize.responsivePadding(8),
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0XFFDFEAFF) : Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? kPrimaryColor : Color(0xFFF4F4F4),
                  ),
                ),
                child: Text(
                  branch,
                  style: isSelected
                      ? kSmallTitleM.copyWith(color: kPrimaryColor)
                      : kSmallTitleL.copyWith(color: kSecondaryTextColor),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
