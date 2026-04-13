import 'package:digistore/src/data/utils/interactive_feedback_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/router/nav_router.dart';
import '../../../data/models/category_model.dart';
import 'section_title.dart';
import 'category_card.dart';

class CategoryList extends ConsumerWidget {
  final List<CategoryModel>? categories;
  const CategoryList({super.key, this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories == null || categories!.isEmpty) return const SizedBox.shrink();
    final screenSize = ref.watch(screenSizeProvider);

    final categoryIcons = {
      'Restaurants & Cafes': 'assets/svg/food.svg',
      'Beauty & Wellness': 'assets/svg/personal_care.svg',
      'Automotive Services': 'assets/svg/construction.svg',
      'Fitness & Sports': 'assets/svg/events.svg',
      'Books & Stationery': 'assets/svg/daily_needs.svg',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Categories',
          onViewAll: () {
            ref.read(selectedOffersCategoryProvider.notifier).state = 0;
            ref.read(selectedIndexProvider.notifier).updateIndex(1);
          },
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
          child: Row(
            children: categories!.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              return Padding(
                padding: EdgeInsets.only(right: screenSize.responsivePadding(16)),
                child: InteractiveFeedbackButton(
                  onPressed: () {
                    ref.read(selectedOffersCategoryProvider.notifier).state = index + 1;
                    ref.read(selectedIndexProvider.notifier).updateIndex(1);
                  },
                  scaleFactor: 0.95,
                  child: CategoryCard(
                    category: {
                      'name': category.name ?? '',
                      'icon': categoryIcons[category.name] ?? 'assets/svg/daily_needs.svg',
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
