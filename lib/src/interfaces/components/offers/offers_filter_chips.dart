import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class OffersFilterChips extends ConsumerStatefulWidget {
  const OffersFilterChips({super.key});

  @override
  ConsumerState<OffersFilterChips> createState() => _OffersFilterChipsState();
}

class _OffersFilterChipsState extends ConsumerState<OffersFilterChips> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _filters = [
    {'name': 'All', 'icon': null},
    {'name': 'Daily Needs', 'icon': Icons.shopping_basket},
    {'name': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'Home Serv...', 'icon': Icons.home_repair_service},
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    return SizedBox(
      height: screenSize.responsivePadding(40),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          final filter = _filters[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: screenSize.responsivePadding(8)),
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
              ),
              decoration: BoxDecoration(
                color: isSelected ? kBlue : kWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? kBlue : kBorder.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  if (filter['icon'] != null) ...[
                    Icon(
                      filter['icon'] as IconData,
                      size: 16,
                      color: isSelected ? kWhite : Colors.redAccent,
                    ),
                    SizedBox(width: screenSize.responsivePadding(6)),
                  ],
                  Text(
                    filter['name'] as String,
                    style: kSmallTitleSB.copyWith(
                      color: isSelected ? kWhite : kSecondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
