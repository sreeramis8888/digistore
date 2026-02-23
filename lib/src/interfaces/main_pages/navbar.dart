import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/constants/color_constants.dart';
import '../../data/router/nav_router.dart';
import 'home_page.dart';
import 'offers.dart';
import 'shops.dart';
import 'rewards.dart';
import 'history.dart';

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
  late final List<Widget> _widgetOptions;

  // Since you mentioned SVG icons in the first prompt,
  // I'm predicting the file names based on the labels in the image!
  // Make sure these are placed in assets/svg/
  static const List<String> _inactiveIcons = [
    'assets/svg/inactive_home.svg',
    'assets/svg/inactive_offer.svg',
    'assets/svg/inactive_shop.svg',
    'assets/svg/inactive_reward.svg',
    'assets/svg/inactive_history.svg',
  ];

  static const List<String> _activeIcons = [
    'assets/svg/active_home.svg',
    'assets/svg/active_offer.svg',
    'assets/svg/active_shop.svg',
    'assets/svg/active_reward.svg',
    'assets/svg/active_history.svg',
  ];

  @override
  void initState() {
    super.initState();
    _widgetOptions = const <Widget>[
      HomePage(),
      OffersPage(),
      ShopsPage(),
      RewardsPage(),
      HistoryPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    final List<String> labels = [
      'Home',
      'Offers',
      'Shops',
      'Rewards',
      'History',
    ];

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        log('inside navbar popscope');
        if (selectedIndex != 0) {
          ref.read(selectedIndexProvider.notifier).updateIndex(0);
        }
      },
      child: Scaffold(
        backgroundColor: kWhite,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: _widgetOptions.elementAt(selectedIndex),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: kWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 75,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(5, (index) {
                        final bool isSelected = selectedIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (selectedIndex != index) {
                                ref
                                    .read(selectedIndexProvider.notifier)
                                    .updateIndex(index);
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: isSelected ? 1.2 : 1.0,
                                  child: SvgPicture.asset(
                                    isSelected
                                        ? _activeIcons[index]
                                        : _inactiveIcons[index],
                                    colorFilter: ColorFilter.mode(
                                      isSelected
                                          ? kBlue
                                          : const Color(0xFF99A1AF),
                                      BlendMode.srcIn,
                                    ),
                                    width: 24,
                                    height: 24,
                                    placeholderBuilder:
                                        (BuildContext context) => Icon(
                                          index == 0
                                              ? Icons.home_filled
                                              : index == 1
                                              ? Icons.local_offer_outlined
                                              : index == 2
                                              ? Icons.storefront
                                              : index == 3
                                              ? Icons.workspace_premium_outlined
                                              : Icons.history,
                                          color: isSelected
                                              ? kBlue
                                              : const Color(0xFF99A1AF),
                                          size: 24,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  labels[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? kBlue
                                        : const Color(0xFF99A1AF),
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
