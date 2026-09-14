import 'package:setgo/src/data/utils/interactive_feedback_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/screen_size_provider.dart';
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

    final screenSize = ref.watch(screenSizeProvider);
    final hPad = screenSize.responsivePadding(16);
    final gap = screenSize.responsivePadding(12);
    final cardWidth = screenSize.responsivePadding(140);
    final cardHeight = screenSize.responsivePadding(126);
    final iconSize = screenSize.responsivePadding(68);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Explore Categories',
          revampStyle: true,
        ),
        SizedBox(height: screenSize.responsivePadding(8)),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            itemCount: categories!.length,
            separatorBuilder: (_, _) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              final category = categories![index];
              return InteractiveFeedbackButton(
                onPressed: () {
                  ref.read(selectedOffersCategoryProvider.notifier).state =
                      index + 1;
                  ref.read(selectedIndexProvider.notifier).updateIndex(1);
                },
                scaleFactor: 0.96,
                child: ExploreCategoryCard(
                  category: category,
                  index: index,
                  width: cardWidth,
                  height: cardHeight,
                  iconSize: iconSize,
                  fallbackAsset: _fallbackIcons[category.name] ??
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
