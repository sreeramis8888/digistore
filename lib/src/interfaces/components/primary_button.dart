import 'package:digistore/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final double? textSize;
  final Widget? child;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final Widget? trailingIcon;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    this.text = '',
    this.textSize = 12,
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.trailingIcon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding:
              padding ??
              ((icon != null || trailingIcon != null)
                  ? const EdgeInsets.symmetric(horizontal: 8)
                  : null),
          backgroundColor: backgroundColor ?? kPrimaryColor,
          disabledBackgroundColor: kGreyLight,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: LoadingAnimation()
              )
            : child ??
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[icon!, const SizedBox(width: 8)],
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            text,
                            style: kSmallTitleR.copyWith(
                              color: !isEnabled ? kGrey : (textColor ?? kWhite),
                              fontWeight: FontWeight.w600,
                              fontSize: (icon != null || trailingIcon != null)
                                  ? textSize
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        trailingIcon!,
                      ],
                    ],
                  ),
      ),
    );
  }
}
