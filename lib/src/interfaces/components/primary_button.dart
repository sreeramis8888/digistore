import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final Widget? child;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    this.text = '',
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? kPrimaryColor,
          disabledBackgroundColor: kGreyLight,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(kWhite),
                ),
              )
            : child ??
                  Text(
                    text,
                    style: kSmallTitleR.copyWith(
                      color: !isEnabled ? kGrey : (textColor ?? kWhite),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      ),
    );
  }
}
