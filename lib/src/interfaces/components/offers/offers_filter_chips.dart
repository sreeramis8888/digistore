import 'package:digistore/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

import '../../../data/router/nav_router.dart';

import '../../../data/providers/category_provider.dart';
import '../../../data/models/category_model.dart';

class OffersFilterChips extends ConsumerStatefulWidget {
  const OffersFilterChips({super.key});

  @override
  ConsumerState<OffersFilterChips> createState() => _OffersFilterChipsState();
}

class _OffersFilterChipsState extends ConsumerState<OffersFilterChips> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _keys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedIndex(int index) {
    final keyContext = _keys[index]?.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final selectedIndex = ref.watch(selectedOffersCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        final filters = [const CategoryModel(name: 'All'), ...categories];

        if (selectedIndex > 0 && selectedIndex < filters.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToSelectedIndex(selectedIndex);
          });
        }

        return SizedBox(
          height: screenSize.responsivePadding(40),
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
            ),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;
              final filter = filters[index];
              _keys[index] ??= GlobalKey();

              return GestureDetector(
                key: _keys[index],
                onTap: () {
                  ref.read(selectedOffersCategoryProvider.notifier).state =
                      index;
                  _scrollToSelectedIndex(index);
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: screenSize.responsivePadding(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(16),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryColor : const Color(0xFFFCFCFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? kPrimaryColor : kBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filter.name ?? '',
                    style: kSmallerTitleL.copyWith(
                      color: isSelected ? kWhite : kSecondaryTextColor,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}
