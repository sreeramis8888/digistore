import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../components/rewards/reward_grid_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/screen_size_provider.dart';

class RewardsPage extends ConsumerWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final rewards = [
      {'title': 'Flat ₹200 OFF', 'subtitle': 'Year-end sale offer', 'logoText': 'GOOD', 'logoColor': Colors.black, 'points': '3000'},
      {'title': 'Flat ₹200 OFF', 'subtitle': 'Year-end sale offer', 'logoText': 'Leaf', 'logoColor': Colors.deepOrangeAccent, 'points': '3000'},
      {'title': 'Flat ₹150 OFF', 'subtitle': 'Weekend getaway discount', 'logoText': 'BOYCOTT', 'logoColor': Colors.white, 'points': '2000'},
      {'title': 'Flat ₹50 OFF', 'subtitle': 'loreum ipsum loreum ipsum', 'logoText': 'Vibe', 'logoColor': Colors.green, 'points': '200'},
      {'title': 'Flat ₹75 OFF', 'subtitle': 'Festival special coupon', 'logoText': 'Chill Bite', 'logoColor': Colors.indigo, 'points': '1200'},
      {'title': '₹300 OFF', 'subtitle': 'Exclusive restaurant deal', 'logoText': 'GOOD', 'logoColor': Colors.amber.shade100, 'points': '2500'},
      {'title': 'Flat ₹100 OFF', 'subtitle': 'Limited time shopping voucher', 'logoText': 'Wings', 'logoColor': Colors.purple, 'points': '1500'},
      {'title': '₹300 OFF', 'subtitle': 'Exclusive restaurant deal', 'logoText': 'Master', 'logoColor': Colors.white, 'points': '2500'},
    ];

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text('Rewards', style: kHeadTitleB),
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: EdgeInsets.all(screenSize.responsivePadding(16)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: screenSize.responsivePadding(16),
            crossAxisSpacing: screenSize.responsivePadding(16),
            childAspectRatio: 0.82, 
          ),
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            final r = rewards[index];
            return RewardGridCard(
              title: r['title'] as String,
              subtitle: r['subtitle'] as String,
              logoText: r['logoText'] as String,
              logoColor: r['logoColor'] as Color,
              points: r['points'] as String,
            );
          },
        ),
      ),
    );
  }
}
