import 'dart:async';
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
  FutureOr<dynamic> Function()? onConfirm,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: kBlack.withOpacity(0.5),
    builder: (context) => _ConfirmationDialogWidget(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: confirmColor,
      icon: icon,
      isDestructive: isDestructive,
      onConfirm: onConfirm,
    ),
  );
}

class _ConfirmationDialogWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final Color? confirmColor;
  final IconData? icon;
  final bool isDestructive;
  final FutureOr<dynamic> Function()? onConfirm;

  const _ConfirmationDialogWidget({
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.confirmColor,
    this.icon,
    this.isDestructive = false,
    this.onConfirm,
  });

  @override
  State<_ConfirmationDialogWidget> createState() =>
      _ConfirmationDialogWidgetState();
}

class _ConfirmationDialogWidgetState extends State<_ConfirmationDialogWidget> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (_isLoading) return;
    if (widget.onConfirm != null) {
      setState(() => _isLoading = true);
      try {
        final result = await widget.onConfirm!();
        if (!mounted) return;
        if (result == false) {
          setState(() => _isLoading = false);
        } else {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        rethrow;
      }
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Dialog(
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
                    color: (widget.isDestructive ? kRed : kPrimaryColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.icon ??
                        (widget.isDestructive
                            ? Icons.delete_outline_rounded
                            : Icons.info_outline_rounded),
                    color: widget.isDestructive ? kRed : kPrimaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: kBodyTitleM.copyWith(
                    fontWeight: FontWeight.w700,
                    color: kTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
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
                        text: widget.cancelText ?? 'Cancel',
                        backgroundColor: kField,
                        textColor: kSecondaryTextColor,
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textSize: 14,
                        isEnabled: !_isLoading,
                        onPressed: () {
                          if (!_isLoading) {
                            Navigator.pop(context, false);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: widget.confirmText ?? 'Confirm',
                        backgroundColor: widget.confirmColor ??
                            (widget.isDestructive ? kRed : kPrimaryColor),
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textSize: 14,
                        isLoading: _isLoading,
                        onPressed: _handleConfirm,
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
}

