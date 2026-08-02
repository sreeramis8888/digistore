import 'package:flutter/material.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/business_info.dart';
import '../primary_text_field.dart';
import '../primary_button.dart';

Future<BusinessFAQ?> showAddFaqDialog(BuildContext context, {BusinessFAQ? initialFaq}) {
  final questionCtrl = TextEditingController(text: initialFaq?.question ?? '');
  final answerCtrl = TextEditingController(text: initialFaq?.answer ?? '');
  final isEditing = initialFaq != null;

  return showDialog<BusinessFAQ>(
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
        child: SingleChildScrollView(
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
                      child: const Icon(Icons.help_outline_rounded, color: kPrimaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit FAQ' : 'Add FAQ',
                      style: kBodyTitleM.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: PrimaryTextField(
                  label: 'Question',
                  hint: 'e.g. What are your working hours?',
                  controller: questionCtrl,
                  maxLines: 2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: PrimaryTextField(
                  label: 'Answer',
                  hint: 'e.g. We are open from 9 AM to 8 PM daily.',
                  controller: answerCtrl,
                  maxLines: 4,
                ),
              ),
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
                        text: isEditing ? 'Save' : 'Add',
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onPressed: () {
                          final q = questionCtrl.text.trim();
                          final a = answerCtrl.text.trim();
                          if (q.isNotEmpty && a.isNotEmpty) {
                            Navigator.pop(
                              context,
                              BusinessFAQ(question: q, answer: a),
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
    ),
  );
}
