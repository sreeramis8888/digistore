import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/screen_size_provider.dart';
import 'section_title.dart';
import 'category_card.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final categories = [
      {'name': 'Daily Needs', 'icon': 'assets/svg/daily_needs.svg', 'color': const Color(0xFFF9F0F4)},
      {'name': 'Personal Care', 'icon': 'assets/svg/personal_care.svg', 'color': const Color(0xFFF0F4FF)},
      {'name': 'Medical', 'icon': 'assets/svg/medical.svg', 'color': const Color(0xFFEFFFFE)},
      {'name': 'Events', 'icon': 'assets/svg/events.svg', 'color': const Color(0xFFFFF7E6)},
      {'name': 'Construction', 'icon': 'assets/svg/active_home.svg', 'color': const Color(0xFFE8F5E9)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Categories', onViewAll: () {}),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
          child: Row(
            children: categories.map((cat) => Padding(
              padding: EdgeInsets.only(right: screenSize.responsivePadding(16)),
              child: CategoryCard(category: cat),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
