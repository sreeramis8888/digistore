import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';

import '../../../../src/data/utils/launch_url.dart';

class ShopSocials extends ConsumerWidget {
  final ShopModel? shop;

  const ShopSocials({super.key, this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final socialLinks = shop?.businessInfo?.socialLinks;

    if (socialLinks == null) return const SizedBox.shrink();

    final hasInstagram = socialLinks.instagram?.isNotEmpty == true;
    final hasFacebook = socialLinks.facebook?.isNotEmpty == true;
    final hasYoutube = socialLinks.youtube?.isNotEmpty == true;

    if (!hasInstagram && !hasFacebook && !hasYoutube) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connect With Us', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Wrap(
          spacing: screenSize.responsivePadding(12),
          runSpacing: screenSize.responsivePadding(12),
          children: [
            if (hasInstagram)
              _SocialButton(
                icon: Icons.camera_alt,
                iconColor: const Color(0xFFE1306C),
                label: 'Instagram',
                onPressed: () => launchURL(socialLinks.instagram!),
                screenSize: screenSize,
              ),
            if (hasFacebook)
              _SocialButton(
                icon: Icons.facebook,
                iconColor: const Color(0xFF4267B2),
                label: 'Facebook',
                onPressed: () => launchURL(socialLinks.facebook!),
                screenSize: screenSize,
              ),
            if (hasYoutube)
              _SocialButton(
                icon: Icons.play_circle_filled,
                iconColor: const Color(0xFFFF0000),
                label: 'YouTube',
                onPressed: () => launchURL(socialLinks.youtube!),
                screenSize: screenSize,
              ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onPressed;
  final ScreenSizeData screenSize;

  const _SocialButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onPressed,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor, size: 18),
      label: Text(label, style: kSmallTitleM),
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFF9F9F9),
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(12),
          vertical: screenSize.responsivePadding(8),
        ),
        side: const BorderSide(color: Color(0xFFF9F9F9)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
