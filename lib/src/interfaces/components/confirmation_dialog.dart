import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import 'primary_button.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  Color? confirmColor,
  IconData? icon,
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: kBlack.withOpacity(0.5),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0.95, end: 1.0),
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: Opacity(
            opacity: ((value - 0.95) / 0.05).clamp(0.0, 1.0),
            child: child,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isDestructive ? kRed : kPrimaryColor).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon ??
                      (isDestructive
                          ? Icons.delete_outline_rounded
                          : Icons.info_outline_rounded),
                  color: isDestructive ? kRed : kPrimaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: kBodyTitleM.copyWith(
                  fontWeight: FontWeight.w700,
                  color: kTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: kSmallTitleM.copyWith(
                  color: kSecondaryTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: cancelText ?? 'Cancel',
                      backgroundColor: kField,
                      textColor: kSecondaryTextColor,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textSize: 14,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: confirmText ?? 'Confirm',
                      backgroundColor:
                          confirmColor ??
                          (isDestructive ? kRed : kPrimaryColor),
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textSize: 14,
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
