import 'package:digistore/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/models/category_model.dart';
import '../primary_text_field.dart';

class CategorySelectionBottomSheet extends ConsumerStatefulWidget {
  final String? selectedCategoryId;
  final Function(CategoryModel category) onCategorySelected;
  final String title;

  const CategorySelectionBottomSheet({
    super.key,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.title = 'Select Category',
  });

  @override
  ConsumerState<CategorySelectionBottomSheet> createState() =>
      _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState
    extends ConsumerState<CategorySelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: kSmallTitleB.copyWith(fontSize: 18)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: kTextColor),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(screenSize.responsivePadding(16)),
            child: PrimaryTextField(
              controller: _searchController,
              hint: 'Search categories...',
              prefixIcon: const Icon(Icons.search, color: kSecondaryTextColor),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                final filtered = categories
                    .where(
                      (c) =>
                          c.name?.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ??
                          false,
                    )
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No categories found',
                      style: kSmallTitleM.copyWith(color: kSecondaryTextColor),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(24),
                    vertical: screenSize.responsivePadding(8),
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cat = filtered[index];
                    final isSelected = widget.selectedCategoryId == cat.id;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        widget.onCategorySelected(cat);
                        Navigator.pop(context);
                      },
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? kPrimaryColor.withOpacity(0.1)
                              : const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.category_rounded,
                          size: 20,
                          color: isSelected
                              ? kPrimaryColor
                              : kSecondaryTextColor,
                        ),
                      ),
                      title: Text(
                        cat.name ?? '',
                        style: kSmallTitleM.copyWith(
                          color: isSelected ? kPrimaryColor : kTextColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: kPrimaryColor,
                            )
                          : const Icon(
                              Icons.chevron_right,
                              color: kSecondaryTextColor,
                              size: 20,
                            ),
                    );
                  },
                );
              },
              loading: () => const Center(child: LoadingAnimation()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
