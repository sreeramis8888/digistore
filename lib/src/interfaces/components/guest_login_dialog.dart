import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import 'primary_button.dart';

class GuestLoginDialog extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String loginText;
  final String cancelText;

  const GuestLoginDialog({
    super.key,
    this.title = 'Login Required',
    this.subtitle = 'Please login or register to access this feature and unlock more benefits.',
    this.loginText = 'Login / Register',
    this.cancelText = 'Maybe Later',
  });

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? subtitle,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GuestLoginDialog(
          title: title ?? 'Login Required',
          subtitle: subtitle ?? 'Please login or register to access this feature and unlock more benefits.',
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8 * animation.value, sigmaY: 8 * animation.value),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(24)),
      child: Container(
        padding: EdgeInsets.all(screenSize.responsivePadding(24)),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: kBlack.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: screenSize.responsivePadding(72),
              height: screenSize.responsivePadding(72),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    color: kPrimaryColor,
                    size: screenSize.responsivePadding(32),
                  ),
                  Positioned(
                    right: screenSize.responsivePadding(16),
                    bottom: screenSize.responsivePadding(16),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: kWhite,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: kPrimaryColor,
                        size: screenSize.responsivePadding(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenSize.responsivePadding(24)),
            Text(
              title,
              style: kSubHeadingL.copyWith(
                color: kTextColor, 
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.responsivePadding(12)),
            Text(
              subtitle,
              style: kBodyTitleM.copyWith(
                color: kSecondaryTextColor, 
                height: 1.5,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.responsivePadding(32)),
            PrimaryButton(
              text: loginText,
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
              },
            ),
            SizedBox(height: screenSize.responsivePadding(12)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: kSecondaryTextColor,
              ),
              child: Text(
                cancelText,
                style: kBodyTitleM.copyWith(
                  color: kSecondaryTextColor, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
