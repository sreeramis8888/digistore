import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/style_constants.dart';
import '../../data/constants/color_constants.dart';
import '../../data/providers/screen_size_provider.dart';

class EmptyState extends ConsumerWidget {
  final String imagePath;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: screenSize.responsivePadding(200),
            height: screenSize.responsivePadding(200),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
          Text(
            title,
            style: kBodyTitleM,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: screenSize.responsivePadding(8)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(40)),
              child: Text(
                subtitle!,
                style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
