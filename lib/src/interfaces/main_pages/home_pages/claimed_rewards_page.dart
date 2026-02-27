import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class ClaimedRewardsPage extends ConsumerWidget {
  const ClaimedRewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    
    final rewards = [
      {
         'title': 'Flat ₹150 OFF',
         'subtitle': 'Weekend getaway discount',
         'image': 'assets/png/good.png',
      },
      {
         'title': 'Flat ₹50 OFF',
         'subtitle': 'loreum ipsum loreum ipsum',
         'image': 'assets/png/vibe.png',
      }
    ];

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Claimed Rewards', style: kSubHeadingM.copyWith(color: kTextColor)),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: EdgeInsets.all(screenSize.responsivePadding(16)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: screenSize.responsivePadding(16),
            mainAxisSpacing: screenSize.responsivePadding(16),
            childAspectRatio: 0.85,
          ),
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            final item = rewards[index];
            return Container(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kStrokeColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    item['title']!,
                    style: kSmallTitleM.copyWith(color: kTextColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenSize.responsivePadding(4)),
                  Text(
                    item['subtitle']!,
                    style: kSmallerTitleL.copyWith(
                      color: kSecondaryTextColor,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  SizedBox(
                    height: screenSize.responsivePadding(50),
                    child: Image.asset(
                      item['image']!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 30, color: kGrey),
                    ),
                  ),
                  SizedBox(height: screenSize.responsivePadding(8)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
