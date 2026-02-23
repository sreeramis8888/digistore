import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../cards/deal_card.dart';

class DealsSection extends ConsumerStatefulWidget {
  const DealsSection({super.key});

  @override
  ConsumerState<DealsSection> createState() => _DealsSectionState();
}

class _DealsSectionState extends ConsumerState<DealsSection> {
  int _selectedIndex = 0;
  final List<String> _tabs = [
    'Deal of the Hour',
    'Deal of the Day',
    'Deal of the Week',
    'Deal of the Month',
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFFF2F6FF)),
        ),
        padding: EdgeInsets.symmetric(
          vertical: screenSize.responsivePadding(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: screenSize.responsivePadding(40),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16),
                ),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: screenSize.responsivePadding(16),
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _tabs[index],
                              style: isSelected
                                  ? kBodyTitleM.copyWith(
                                      color: const Color(0xFFAC7F5E),
                                    )
                                  : kBodyTitleL.copyWith(color: kTextColor),
                            ),
                            if (isSelected)
                              Container(
                                height: 2,
                                margin: EdgeInsets.only(
                                  top: screenSize.responsivePadding(4),
                                ),
                                color: const Color(0xFF8A6B32),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenSize.responsivePadding(16)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DealCard(
                      title: 'Fresh Bakes Deal',
                      subtitle: 'Buy one bun Get one free',
                      shopName: 'HomeGoods',
                      badgeText: 'BUY 1\nGET 1',
                      avatarColor: kPrimaryLightColor,
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(16)),
                  Expanded(
                    child: DealCard(
                      title: 'Special Salon Offer',
                      subtitle: 'Try any haircut Get 30% off',
                      shopName: 'Glow Saloon',
                      badgeText: '30%\nOFF',
                      avatarColor: kPrimaryLightColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenSize.responsivePadding(16)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(12),
                      vertical: screenSize.responsivePadding(6),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFEDEDED)),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('See all', style: kSmallTitleSB),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 16),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Container(
                        height: 1,
                        color: kBorder.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
