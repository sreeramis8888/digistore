import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/models/business_info.dart';
import 'primary_text_field.dart';
import 'primary_button.dart';

Future<BusinessBranch?> showAddBranchDialog(BuildContext context) {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  return showDialog<BusinessBranch>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => Dialog(
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
                    child: const Icon(Icons.store_mall_directory_outlined, color: kPrimaryColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text('Add Branch', style: kBodyTitleM.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                children: [
                  PrimaryTextField(
                    label: 'Branch Name',
                    hint: 'Enter branch name',
                    controller: nameCtrl,
                    prefixIcon: const Icon(Icons.storefront_outlined, color: kSecondaryColor, size: 18),
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  PrimaryTextField(
                    label: 'Address',
                    hint: 'Enter address',
                    controller: addressCtrl,
                    prefixIcon: const Icon(Icons.location_on_outlined, color: kSecondaryColor, size: 18),
                  ),
                  const SizedBox(height: 12),
                  PrimaryTextField(
                    label: 'Phone Number',
                    hint: 'Enter phone number',
                    controller: phoneCtrl,
                    type: TextFieldType.number,
                    prefixIcon: const Icon(Icons.phone_outlined, color: kSecondaryColor, size: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                      text: 'Add Branch',
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () {
                        if (nameCtrl.text.trim().isNotEmpty) {
                          Navigator.pop(
                            context,
                            BusinessBranch(
                              name: nameCtrl.text.trim(),
                              address: addressCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              isActive: true,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
