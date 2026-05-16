import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final websiteUrl = shop?.businessInfo?.websiteUrl;

    final hasWebsite = websiteUrl?.isNotEmpty == true;
    final hasInstagram = socialLinks?.instagram?.isNotEmpty == true;
    final hasFacebook = socialLinks?.facebook?.isNotEmpty == true;
    final hasYoutube = socialLinks?.youtube?.isNotEmpty == true;

    if (!hasWebsite && !hasInstagram && !hasFacebook && !hasYoutube) {
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
            if (hasWebsite)
              _SocialButton(
                svgAsset: 'assets/svg/website.svg',
                label: 'Website',
                onPressed: () => launchURL(websiteUrl!),
                screenSize: screenSize,
              ),
            if (hasInstagram)
              _SocialButton(
                svgAsset: 'assets/svg/instagram.svg',
                label: 'Instagram',
                onPressed: () => launchURL(socialLinks!.instagram!),
                screenSize: screenSize,
              ),
            if (hasFacebook)
              _SocialButton(
                svgAsset: 'assets/svg/facebook.svg',
                label: 'Facebook',
                onPressed: () => launchURL(socialLinks!.facebook!),
                screenSize: screenSize,
              ),
            if (hasYoutube)
              _SocialButton(
                svgAsset: 'assets/svg/youtube.svg',
                label: 'YouTube',
                onPressed: () => launchURL(socialLinks!.youtube!),
                screenSize: screenSize,
              ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String svgAsset;
  final String label;
  final VoidCallback onPressed;
  final ScreenSizeData screenSize;

  const _SocialButton({
    required this.svgAsset,
    required this.label,
    required this.onPressed,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        svgAsset,
        width: 18,
        height: 18,
      ),
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
