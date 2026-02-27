import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

import '../../../data/router/nav_router.dart';

class OffersFilterChips extends ConsumerStatefulWidget {
  const OffersFilterChips({super.key});

  @override
  ConsumerState<OffersFilterChips> createState() => _OffersFilterChipsState();
}

class _OffersFilterChipsState extends ConsumerState<OffersFilterChips> {
  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _keys;

  final List<Map<String, dynamic>> _filters = [
    {'name': 'All', 'icon': null},
    {'name': 'Daily Needs', 'icon': Icons.shopping_basket},
    {'name': 'Personal Care', 'icon': Icons.spa},
    {'name': 'Medical', 'icon': Icons.medical_services},
    {'name': 'Events', 'icon': Icons.event},
    {'name': 'Construction', 'icon': Icons.construction},
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'Home Services', 'icon': Icons.home_repair_service},
  ];

  @override
  void initState() {
    super.initState();
    _keys = List.generate(_filters.length, (index) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedIndex(ref.read(selectedOffersCategoryProvider));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedIndex(int index) {
    if (index >= 0 && index < _keys.length) {
      final keyContext = _keys[index].currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5, // Center the selected chip
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final selectedIndex = ref.watch(selectedOffersCategoryProvider);

    ref.listen<int>(selectedOffersCategoryProvider, (previous, next) {
      if (previous != next) {
        _scrollToSelectedIndex(next);
      }
    });

    return SizedBox(
      height: screenSize.responsivePadding(40),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(16),
        ),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final filter = _filters[index];
          return GestureDetector(
            key: _keys[index],
            onTap: () {
              ref.read(selectedOffersCategoryProvider.notifier).state = index;
            },
            child: Container(
              margin: EdgeInsets.only(right: screenSize.responsivePadding(8)),
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
              ),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : const Color(0xFFFCFCFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? kPrimaryColor : Colors.transparent,
                ),
                boxShadow: isSelected
                    ? null
                    : [
                        BoxShadow(
                          color: kWhite.withOpacity(0.55),
                          blurRadius: 5,
                          spreadRadius: 0,
                          offset: const Offset(0, 0),
                        ),
                      ],
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
