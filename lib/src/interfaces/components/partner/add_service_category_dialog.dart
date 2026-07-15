import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/offer_metadata_providers.dart';
import '../primary_text_field.dart';
import '../primary_button.dart';

class AddServiceCategoryDialog extends ConsumerStatefulWidget {
  final List<String> existingCategories;

  const AddServiceCategoryDialog({
    super.key,
    required this.existingCategories,
  });

  @override
  ConsumerState<AddServiceCategoryDialog> createState() => _AddServiceCategoryDialogState();
}

class _AddServiceCategoryDialogState extends ConsumerState<AddServiceCategoryDialog> {
  final TextEditingController _customCtrl = TextEditingController();
  final Set<String> _selected = {};

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subcategoriesAsync = ref.watch(subcategoriesProvider);

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
                  Text('Add Service Category', style: kBodyTitleM.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: PrimaryTextField(
                label: 'Custom Category',
                hint: 'Type category and press Add',
                controller: _customCtrl,
                prefixIcon: const Icon(Icons.add_circle_outline, color: kSecondaryColor, size: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Or select from available subcategories:',
                  style: kSmallTitleM.copyWith(color: kSecondaryTextColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: subcategoriesAsync.when(
                data: (list) {
                  final available = list.where((cat) => !widget.existingCategories.contains(cat)).toList();
                  if (available.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No new subcategories available.',
                          style: kSmallTitleM.copyWith(color: kGrey),
                        ),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (err, stack) => Center(
                  child: Text('Failed to load categories', style: kSmallTitleM.copyWith(color: Colors.red)),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                      text: 'Add Selected',
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () {
                        final custom = _customCtrl.text.trim();
                        final result = <String>[..._selected];
                        if (custom.isNotEmpty && !result.contains(custom)) {
                          result.add(custom);
                        }
                        Navigator.pop(context, result);
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

Future<List<String>?> showAddServiceCategoryDialog(BuildContext context, {required List<String> existingCategories}) {
  return showDialog<List<String>>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => AddServiceCategoryDialog(existingCategories: existingCategories),
  );
}
