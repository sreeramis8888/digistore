import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../data/providers/offer_metadata_providers.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../loading_indicator.dart';
import '../primary_text_field.dart';

class ServiceCategorySelectionBottomSheet extends ConsumerStatefulWidget {
  final String? selectedCategoryId;
  final String? selectedCategory;
  final Function(CategoryModel category) onCategorySelected;
  final String title;

  /// Main business category (e.g. "Food"). When null, uses logged-in partner's
  /// businessType so only related service categories are listed.
  final String? businessCategoryName;

  const ServiceCategorySelectionBottomSheet({
    super.key,
    this.selectedCategoryId,
    this.selectedCategory,
    required this.onCategorySelected,
    this.title = 'Select Service Category',
    this.businessCategoryName,
  });

  @override
  ConsumerState<ServiceCategorySelectionBottomSheet> createState() =>
      _ServiceCategorySelectionBottomSheetState();
}

class _ServiceCategorySelectionBottomSheetState
    extends ConsumerState<ServiceCategorySelectionBottomSheet> {
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
    final partnerBusinessType = ref
        .watch(partnerProvider)
        ?.businessDetails
        ?.businessType;
    final parentCategory =
        (widget.businessCategoryName ?? partnerBusinessType)?.trim();
    final subcategoriesAsync = ref.watch(
      categorySubcategoriesProvider(parentCategory),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      if (parentCategory != null &&
                          parentCategory.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'For $parentCategory',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          if (parentCategory == null || parentCategory.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Set your business Category in Account first to see related service categories.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            )
          else ...[
            Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              child: PrimaryTextField(
                controller: _searchController,
                hint: 'Search categories...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                onChanged: (v) =>
                    setState(() => _searchQuery = v.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: subcategoriesAsync.when(
                data: (names) {
                  final categories = names
                      .map(
                        (n) => CategoryModel(id: n, name: n, slug: n),
                      )
                      .where(
                        (c) =>
                            (c.name?.toLowerCase().contains(_searchQuery) ??
                                false) ||
                            (c.slug?.toLowerCase().contains(_searchQuery) ??
                                false),
                      )
                      .toList();

                  if (categories.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No categories found'
                              : 'No service categories found for $parentCategory.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(20),
                      vertical: screenSize.responsivePadding(8),
                    ),
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final catName = cat.name ?? '';
                      final isSelected =
                          (widget.selectedCategoryId != null &&
                              widget.selectedCategoryId == cat.id) ||
                          (widget.selectedCategory != null &&
                              widget.selectedCategory!.toLowerCase() ==
                                  catName.toLowerCase());

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        onTap: () {
                          widget.onCategorySelected(cat);
                          Navigator.pop(context);
                        },
                        title: Text(
                          catName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? kPrimaryColor
                                : const Color(0xFF1F2937),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: kPrimaryColor,
                              )
                            : const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF9CA3AF),
                                size: 20,
                              ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: LoadingAnimation()),
                error: (e, s) =>
                    const Center(child: Text('No categories available')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
