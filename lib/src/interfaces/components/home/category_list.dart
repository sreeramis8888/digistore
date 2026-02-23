import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import 'section_title.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Categories', onViewAll: () {}),
        SizedBox(
          height: screenSize.responsivePadding(110),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(20)),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Padding(
                padding: EdgeInsets.only(right: screenSize.responsivePadding(16)),
                child: Column(
                  children: [
                    Container(
                      width: screenSize.responsivePadding(70),
                      height: screenSize.responsivePadding(70),
                      decoration: BoxDecoration(
                        color: kWhite,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Container(
                          width: screenSize.responsivePadding(50),
                          height: screenSize.responsivePadding(50),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cat['color'] as Color,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              cat['icon'] as String,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(8)),
                    SizedBox(
                      width: screenSize.responsivePadding(70),
                      child: Text(
                        cat['name'] as String,
                        style: kSmallTitleM,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
