import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

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
    'Deal of the Month'
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.responsivePadding(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: screenSize.responsivePadding(40),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(20)),
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
                    padding: EdgeInsets.only(right: screenSize.responsivePadding(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tabs[index],
                          style: isSelected
                              ? kBodyTitleB.copyWith(color: const Color(0xFF8A6B32))
                              : kBodyTitleR.copyWith(color: kSecondaryTextColor),
                        ),
                        if (isSelected)
                          Container(
                            height: 2,
                            width: screenSize.responsivePadding(30),
                            margin: EdgeInsets.only(top: screenSize.responsivePadding(4)),
                            color: const Color(0xFF8A6B32),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(10)),
          SizedBox(
            height: screenSize.responsivePadding(260),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(20)),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: screenSize.responsivePadding(16)),
                  child: Container(
                    width: screenSize.responsivePadding(200),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorder.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: screenSize.responsivePadding(120),
                              decoration: BoxDecoration(
                                color: kGreyLight,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              // Image goes here later
                              child: Center(
                                child: Icon(Icons.image, color: kGrey, size: 40),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 16,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.responsivePadding(8),
                                  vertical: screenSize.responsivePadding(4),
                                ),
                                decoration: const BoxDecoration(
                                  color: kBlue,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  index == 0 ? 'BUY 1\nGET 1' : '30%\nOFF',
                                  style: kSmallerTitleB.copyWith(color: kWhite, fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                index == 0 ? 'Fresh Bakes Deal' : 'Special Salon Offer',
                                style: kBodyTitleB,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: screenSize.responsivePadding(4)),
                              Text(
                                index == 0 ? 'Buy one bun Get one free' : 'Try any haircut Get 30% off',
                                style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: screenSize.responsivePadding(16)),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: screenSize.responsivePadding(10),
                                    backgroundColor: kPrimaryLightColor,
                                    child: Icon(Icons.store, size: 12, color: kGreyDark),
                                  ),
                                  SizedBox(width: screenSize.responsivePadding(8)),
                                  Expanded(
                                    child: Text(
                                      index == 0 ? 'HomeGoods' : 'Glow Saloon',
                                      style: kSmallTitleSB,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(20),
              vertical: screenSize.responsivePadding(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(12),
                    vertical: screenSize.responsivePadding(6),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(20),
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
    );
  }
}
