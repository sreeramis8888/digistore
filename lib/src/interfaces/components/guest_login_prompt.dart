import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'primary_button.dart';

class GuestLoginPrompt extends ConsumerWidget {
  final String title;
  final String subtitle;

  const GuestLoginPrompt({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenSize.responsivePadding(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: screenSize.responsivePadding(64),
              color: kSecondaryTextColor.withOpacity(0.5),
            ),
            SizedBox(height: screenSize.responsivePadding(24)),
            Text(
              title,
              style: kSubHeadingM.copyWith(color: kTextColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.responsivePadding(8)),
            Text(
              subtitle,
              style: kBodyTitleL.copyWith(color: kSecondaryTextColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.responsivePadding(32)),
            PrimaryButton(
              text: 'Login / Register',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
