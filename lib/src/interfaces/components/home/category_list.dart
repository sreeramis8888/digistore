import 'package:setgo/src/data/utils/interactive_feedback_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/router/nav_router.dart';
import '../../../data/models/category_model.dart';
import 'explore_category_card.dart';
import 'section_title.dart';

class CategoryList extends ConsumerWidget {
  final List<CategoryModel>? categories;
  const CategoryList({super.key, this.categories});

  static const _fallbackIcons = {
    'Restaurants & Cafes': 'assets/svg/food.svg',
    'Beauty & Wellness': 'assets/svg/personal_care.svg',
    'Automotive Services': 'assets/svg/construction.svg',
    'Fitness & Sports': 'assets/svg/events.svg',
    'Books & Stationery': 'assets/svg/daily_needs.svg',
    'Daily Needs': 'assets/svg/daily_needs.svg',
    'Personal Care': 'assets/svg/personal_care.svg',
    'Medical': 'assets/svg/medical.svg',
    'Events': 'assets/svg/events.svg',
    'Fashion': 'assets/svg/fashion.svg',
    'Home Services': 'assets/svg/home_services.svg',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories == null || categories!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Shorter names first so compact labels read cleaner in the horizontal strip.
    final sortedCategories = List<CategoryModel>.from(categories!)
      ..sort((a, b) {
        final aLen = (a.name ?? '').trim().length;
        final bLen = (b.name ?? '').trim().length;
        if (aLen != bLen) return aLen.compareTo(bLen);
        return (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase());
      });

    final screenSize = ref.watch(screenSizeProvider);
    // Warm offers-tab categories so home taps can resolve the correct filter.
    ref.watch(categoriesProvider);
    final hPad = screenSize.responsivePadding(16);
    final gap = screenSize.responsivePadding(10);
    final cardWidth = screenSize.responsivePadding(108);
    final cardHeight = screenSize.responsivePadding(80);
    final iconSize = screenSize.responsivePadding(24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Explore Categories', revampStyle: true),
        SizedBox(height: screenSize.responsivePadding(8)),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            itemCount: sortedCategories.length,
            separatorBuilder: (_, _) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              final category = sortedCategories[index];
              return InteractiveFeedbackButton(
                onPressed: () {
                  // Resolve against offers-tab category order (not display sort).
                  final offerCats =
                      ref.read(categoriesProvider).asData?.value ?? [];
                  final matchIndex = offerCats.indexWhere(
                    (c) =>
                        (category.id != null &&
                            category.id!.isNotEmpty &&
                            c.id == category.id) ||
                        (category.name != null &&
                            c.name?.toLowerCase() ==
                                category.name!.toLowerCase()),
                  );
                  // If offers categories aren't loaded yet, still open Offers
                  // on "All" rather than a wrong index from the sorted home list.
                  ref.read(selectedOffersCategoryProvider.notifier).state =
                      matchIndex >= 0 ? matchIndex + 1 : 0;
                  ref.read(selectedIndexProvider.notifier).updateIndex(1);
                },
                scaleFactor: 0.96,
                child: ExploreCategoryCard(
                  category: category,
                  index: index,
                  width: cardWidth,
                  height: cardHeight,
                  iconSize: iconSize,
                  // Only used if API does not send iconUrl.
                  fallbackAsset:
                      _fallbackIcons[category.name] ??
                      'assets/svg/daily_needs.svg',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
