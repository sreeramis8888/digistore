import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/router/nav_router.dart';

class HomeSearchBar extends ConsumerWidget {
  final String hintText;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const HomeSearchBar({
    super.key,
    this.hintText = "Search for 'services'",
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
      child: GestureDetector(
        onTap:
            onTap ??
            () {
              ref.read(selectedIndexProvider.notifier).updateIndex(2);
            },
        child: Container(
          height: screenSize.responsivePadding(54),
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(20),
          ),
          decoration: BoxDecoration(
            color: kField,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF7D848D), size: 24),
              SizedBox(width: screenSize.responsivePadding(12)),
              Expanded(
                child: Text(
                  hintText,
                  style: kSmallerTitleL.copyWith(color: kBlack.withOpacity(.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
