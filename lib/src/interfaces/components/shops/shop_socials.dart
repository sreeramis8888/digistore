import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';

class ShopSocials extends ConsumerWidget {
  final ShopModel? shop;

  const ShopSocials({super.key, this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connect With Us', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Row(
          children: [
            _SocialButton(
              icon: Icons.camera_alt,
              iconColor: Colors.purple,
              label: 'Instagram',
              onPressed: () {},
              screenSize: screenSize,
            ),
            SizedBox(width: screenSize.responsivePadding(12)),
            _SocialButton(
              icon: Icons.facebook,
              iconColor: Colors.blue,
              label: 'Facebook',
              onPressed: () {},
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
