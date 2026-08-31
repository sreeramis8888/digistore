import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/offer_metadata_providers.dart';
import '../primary_text_field.dart';
import '../primary_button.dart';

class AddServiceCategoryDialog extends ConsumerStatefulWidget {
  final List<String> existingCategories;
  final String? categoryNameOrId;

  const AddServiceCategoryDialog({
    super.key,
    required this.existingCategories,
    this.categoryNameOrId,
  });

  @override
  ConsumerState<AddServiceCategoryDialog> createState() => _AddServiceCategoryDialogState();
}

class _AddServiceCategoryDialogState extends ConsumerState<AddServiceCategoryDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _selected = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subcategoriesAsync = ref.watch(
      categorySubcategoriesProvider(widget.categoryNameOrId),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.08),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimaryColor.withOpacity(0.06),
                    kSecondaryColor.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.category_outlined, color: kPrimaryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Subcategories', style: kBodyTitleM.copyWith(fontWeight: FontWeight.w700)),
                        if (widget.categoryNameOrId != null && widget.categoryNameOrId!.isNotEmpty)
                          Text(
                            widget.categoryNameOrId!,
                            style: kSmallTitleL.copyWith(color: kSecondaryTextColor, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: PrimaryTextField(
                label: null,
                hint: 'Search subcategories...',
                controller: _searchCtrl,
                prefixIcon: const Icon(Icons.search, color: kGrey, size: 20),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: subcategoriesAsync.when(
                data: (list) {
                  final available = list.where((cat) {
                    final isNotExisting = !widget.existingCategories.contains(cat);
                    final matchesSearch = _searchQuery.isEmpty || cat.toLowerCase().contains(_searchQuery);
                    return isNotExisting && matchesSearch;
                  }).toList();

                  if (available.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No subcategories match "$_searchQuery".'
                              : 'No subcategories available.',
                          style: kSmallTitleM.copyWith(color: kGrey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: available.map((cat) {
                        final isSelected = _selected.contains(cat);
                        return FilterChip(
                          label: Text(
                            cat,
                            style: kSmallTitleM.copyWith(
                              color: isSelected ? kWhite : kBlack,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selected.add(cat);
                              } else {
                                _selected.remove(cat);
                              }
                            });
                          },
                          selectedColor: kPrimaryColor,
                          backgroundColor: const Color(0xFFF5F5F5),
                          checkmarkColor: kWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? kPrimaryColor : const Color(0xFFE5E5E5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryColor),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Failed to load subcategories', style: kSmallTitleM.copyWith(color: Colors.red)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Cancel',
                      backgroundColor: kWhite,
                      textColor: kSecondaryTextColor,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: _selected.isEmpty ? 'Done' : 'Add (${_selected.length})',
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () {
                        Navigator.pop(context, _selected.toList());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<String>?> showAddServiceCategoryDialog(
  BuildContext context, {
  required List<String> existingCategories,
  String? categoryNameOrId,
}) {
  return showDialog<List<String>>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => AddServiceCategoryDialog(
      existingCategories: existingCategories,
      categoryNameOrId: categoryNameOrId,
    ),
  );
}
