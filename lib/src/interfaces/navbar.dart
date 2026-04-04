import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/constants/color_constants.dart';
import '../data/router/nav_router.dart';
import 'main_pages/home_page.dart';
import 'main_pages/offers.dart';
import 'main_pages/shops.dart';
import 'main_pages/rewards.dart';
import 'main_pages/history.dart';
import '../data/utils/global_variables.dart';
import 'main_pages/partner/partner_home.dart';
import 'main_pages/partner/partner_products.dart';
import 'main_pages/partner/partner_history.dart';

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
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

  List<Widget> get _widgetOptions {
    if (GlobalVariables.isPartner) {
      return const <Widget>[
        PartnerHomePage(),
        OffersPage(),
        PartnerProductsPage(),
        PartnerHistoryPage(),
      ];
    }
    return const <Widget>[
      HomePage(),
      OffersPage(),
      ShopsPage(),
      RewardsPage(),
      HistoryPage(),
    ];
  }

  List<String> get _currentLabels {
    if (GlobalVariables.isPartner) {
      return ['Home', 'Offers', 'Products', 'History'];
    }
    return ['Home', 'Offers', 'Shops', 'Rewards', 'History'];
  }

  List<String> get _currentInactiveIcons {
    if (GlobalVariables.isPartner) {
      return [
        'assets/svg/inactive_home.svg',
        'assets/svg/inactive_offer.svg',
        'assets/svg/inactive_product.svg',
        'assets/svg/inactive_history.svg',
      ];
    }
    return _inactiveIcons;
  }

  List<String> get _currentActiveIcons {
    if (GlobalVariables.isPartner) {
      return [
        'assets/svg/active_home.svg',
        'assets/svg/active_offer.svg',
        'assets/svg/active_products.svg',
        'assets/svg/active_history.svg',
      ];
    }
    return _activeIcons;
  }

  IconData _getIconData(int index, bool isPartner) {
    if (isPartner) {
      if (index == 0) return Icons.home_filled;
      if (index == 1) return Icons.local_offer_outlined;
      if (index == 2) return Icons.inventory_2_outlined;
      return Icons.history;
    } else {
      if (index == 0) return Icons.home_filled;
      if (index == 1) return Icons.local_offer_outlined;
      if (index == 2) return Icons.storefront;
      if (index == 3) return Icons.workspace_premium_outlined;
      return Icons.history;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    final labels = _currentLabels;

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        log('inside navbar popscope');
        if (selectedIndex != 0) {
          if (selectedIndex == 1) {
            ref.read(selectedOffersCategoryProvider.notifier).state = 0;
          }
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
          child: _widgetOptions.elementAt(
            selectedIndex < _widgetOptions.length ? selectedIndex : 0,
          ),
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
                      children: List.generate(labels.length, (index) {
                        final bool isSelected = selectedIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (selectedIndex != index) {
                                if (selectedIndex == 1) {
                                  ref
                                          .read(
                                            selectedOffersCategoryProvider
                                                .notifier,
                                          )
                                          .state =
                                      0;
                                }
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
                                  child: Builder(
                                    builder: (context) {
                                      final iconPath = isSelected
                                          ? _currentActiveIcons[index]
                                          : _currentInactiveIcons[index];
                                      final iconData = _getIconData(
                                        index,
                                        GlobalVariables.isPartner,
                                      );
                                      if (iconPath.isEmpty) {
                                        return Icon(
                                          iconData,
                                          color: isSelected
                                              ? kBlue
                                              : const Color(0xFF99A1AF),
                                          size: 24,
                                        );
                                      }
                                      return SvgPicture.asset(
                                        iconPath,
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
                                              iconData,
                                              color: isSelected
                                                  ? kBlue
                                                  : const Color(0xFF99A1AF),
                                              size: 24,
                                            ),
                                      );
                                    },
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
