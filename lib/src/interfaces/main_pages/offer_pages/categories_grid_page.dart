import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/home/category_card.dart';
import '../../components/loading_indicator.dart';
import 'category_offers_page.dart';


class CategoriesGridPage extends ConsumerStatefulWidget {
  const CategoriesGridPage({super.key});

  @override
  ConsumerState<CategoriesGridPage> createState() => _CategoriesGridPageState();
}

class _CategoriesGridPageState extends ConsumerState<CategoriesGridPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, String> _categoryIcons = {
    'Restaurants & Cafes': 'assets/svg/food.svg',
    'Beauty & Wellness': 'assets/svg/personal_care.svg',
    'Automotive Services': 'assets/svg/construction.svg',
    'Fitness & Sports': 'assets/svg/events.svg',
    'Books & Stationery': 'assets/svg/daily_needs.svg',
    'All Offers': 'assets/svg/daily_needs.svg',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelectCategory(CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryOffersPage(category: category),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Explore Categories',
          style: kBodyTitleM.copyWith(
            fontWeight: FontWeight.w700,
            color: kTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
                vertical: screenSize.responsivePadding(12),
              ),
              child: Container(
                height: screenSize.responsivePadding(48),
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16),
                ),
                decoration: BoxDecoration(
                  color: kField,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: kBorder.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: kSecondaryTextColor,
                      size: 20,
                    ),
                    SizedBox(width: screenSize.responsivePadding(10)),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.trim()),
                        style: kSmallTitleR.copyWith(color: kTextColor),
                        decoration: InputDecoration(
                          hintText: 'Search categories...',
                          hintStyle: kSmallTitleR.copyWith(
                            color: kSecondaryTextColor.withValues(alpha: 0.7),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: kSecondaryTextColor,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  final items = <MapEntry<int, CategoryModel>>[];

                  // Option for "All Offers" at index 0
                  if (_searchQuery.isEmpty ||
                      'all offers'
                          .contains(_searchQuery.toLowerCase())) {
                    items.add(
                      const MapEntry(0, CategoryModel(name: 'All Offers')),
                    );
                  }

                  // Category items matching search query
                  for (int i = 0; i < categories.length; i++) {
                    final cat = categories[i];
                    final catName = cat.name ?? '';
                    if (_searchQuery.isEmpty ||
                        catName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase())) {
                      items.add(MapEntry(i + 1, cat));
                    }
                  }

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 48,
                            color: kSecondaryTextColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No categories found',
                            style: kBodyTitleM.copyWith(
                              fontWeight: FontWeight.w600,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try searching for another keyword',
                            style: kSmallTitleR.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(16),
                      vertical: screenSize.responsivePadding(12),
                    ),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: screenSize.responsivePadding(120),
                      childAspectRatio: 0.72,
                      crossAxisSpacing: screenSize.responsivePadding(12),
                      mainAxisSpacing: screenSize.responsivePadding(16),
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final category = item.value;

                      final iconUrl = (category.iconUrl != null &&
                              category.iconUrl != 'null' &&
                              category.iconUrl!.trim().isNotEmpty)
                          ? category.iconUrl!
                          : (_categoryIcons[category.name] ??
                              'assets/svg/daily_needs.svg');

                      return InteractiveFeedbackButton(
                        onPressed: () => _onSelectCategory(category),
                        scaleFactor: 0.95,
                        child: Center(
                          child: CategoryCard(
                            category: {
                              'name': category.name ?? '',
                              'icon': iconUrl,
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: LoadingAnimation()),
                error: (e, s) => Center(
                  child: Text(
                    'Failed to load categories',
                    style: kSmallTitleR.copyWith(color: kRed),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
