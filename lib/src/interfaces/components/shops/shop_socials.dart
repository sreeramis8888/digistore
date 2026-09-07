import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final whatsappNumber = shop?.businessInfo?.whatsappNumber;
    final email = shop?.businessInfo?.email;

    final hasWebsite = websiteUrl?.isNotEmpty == true;
    final hasInstagram = socialLinks?.instagram?.isNotEmpty == true;
    final hasFacebook = socialLinks?.facebook?.isNotEmpty == true;
    final hasYoutube = socialLinks?.youtube?.isNotEmpty == true;
    final hasWhatsapp = whatsappNumber?.isNotEmpty == true;
    final hasEmail = email?.isNotEmpty == true;

    if (!hasWebsite && !hasInstagram && !hasFacebook && !hasYoutube && !hasWhatsapp && !hasEmail) {
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
                color: const Color(0xFF1A73E8),
              ),
            if (hasWhatsapp)
              _SocialButton(
                svgAsset: 'assets/svg/whatsapp.svg',
                label: 'WhatsApp',
                onPressed: () {
                  final cleanPhone = whatsappNumber!.replaceAll(RegExp(r'[^\d]'), '');
                  final actualPhone = cleanPhone.length == 10 ? '91$cleanPhone' : cleanPhone;
                  final message = "Hello, I would like to enquire about ${shop?.businessDetails?.businessName ?? 'your shop'}.";
                  final url = "https://wa.me/$actualPhone?text=${Uri.encodeComponent(message)}";
                  launchURL(url);
                },
                screenSize: screenSize,
                color: const Color(0xFF128C7E),
              ),
            if (hasInstagram)
              _SocialButton(
                svgAsset: 'assets/svg/instagram.svg',
                label: 'Instagram',
                onPressed: () => launchURL(socialLinks!.instagram!),
                screenSize: screenSize,
                color: const Color(0xFFE1306C),
              ),
            if (hasFacebook)
              _SocialButton(
                svgAsset: 'assets/svg/facebook.svg',
                label: 'Facebook',
                onPressed: () => launchURL(socialLinks!.facebook!),
                screenSize: screenSize,
                color: const Color(0xFF1877F2),
              ),
            if (hasYoutube)
              _SocialButton(
                svgAsset: 'assets/svg/youtube.svg',
                label: 'YouTube',
                onPressed: () => launchURL(socialLinks!.youtube!),
                screenSize: screenSize,
                color: const Color(0xFFCD201F),
              ),
            if (hasEmail)
              _SocialButton(
                iconData: Icons.email_outlined,
                label: 'Email',
                onPressed: () => launchEmail(email!),
                screenSize: screenSize,
                color: const Color(0xFF4B5563),
              ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String? svgAsset;
  final IconData? iconData;
  final String label;
  final VoidCallback onPressed;
  final ScreenSizeData screenSize;
  final Color color;

  const _SocialButton({
    this.svgAsset,
    this.iconData,
    required this.label,
    required this.onPressed,
    required this.screenSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: svgAsset != null
          ? SvgPicture.asset(
              svgAsset!,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            )
          : Icon(
              iconData ?? Icons.link,
              size: 18,
              color: color,
            ),
      label: Text(label, style: kSmallTitleM.copyWith(color: color)),
      style: OutlinedButton.styleFrom(
        backgroundColor: color.withOpacity(0.06),
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(12),
          vertical: screenSize.responsivePadding(8),
        ),
        side: BorderSide(color: color.withOpacity(0.12)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
