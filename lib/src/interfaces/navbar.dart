import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/constants/color_constants.dart';
import '../data/router/nav_router.dart';
import '../data/services/deep_link_service.dart';
import '../data/providers/notifications_provider.dart';
import '../data/providers/shops_provider.dart';
import 'main_pages/home_page.dart';
import 'main_pages/offers.dart';
import 'main_pages/shops.dart';
import 'main_pages/rewards.dart';
import '../data/utils/global_variables.dart';
import 'main_pages/partner/partner_home.dart';
import 'main_pages/products.dart';
import 'main_pages/partner/partner_history.dart';
import '../data/services/secure_storage_service.dart';
import '../data/utils/notification_permission_helper.dart';
import '../data/services/notification_service/notification_service.dart';

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> with WidgetsBindingObserver {
  bool _wasInBackground = false;

  static const List<String> _inactiveIcons = [
    'assets/svg/inactive_home.svg',
    'assets/svg/inactive_offer.svg',
    'assets/svg/inactive_shop.svg',
    'assets/svg/inactive_reward.svg',
    'assets/svg/inactive_product.svg',
  ];

  static const List<String> _activeIcons = [
    'assets/svg/active_home.svg',
    'assets/svg/active_offer.svg',
    'assets/svg/active_shop.svg',
    'assets/svg/active_reward.svg',
    'assets/svg/active_products.svg',
  ];

  List<Widget> get _widgetOptions {
    if (GlobalVariables.isPartner) {
      return const <Widget>[
        PartnerHomePage(),
        OffersPage(),
        ProductsPage(),
        PartnerHistoryPage(),
      ];
    }
    return const <Widget>[
      HomePage(),
      OffersPage(),
      ShopsPage(),
      RewardsPage(),
      ProductsPage(),
    ];
  }

  List<String> get _currentLabels {
    if (GlobalVariables.isPartner) {
      return ['Home', 'Offers', 'Products & Services', 'History'];
    }
    return ['Home', 'Offers', 'Shops', 'Rewards', 'Products & Services'];
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
      return Icons.inventory_2_outlined;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deepLinkService = ref.read(deepLinkServiceProvider);
      if (deepLinkService.pendingDeepLink != null) {
        final pending = deepLinkService.pendingDeepLink!;
        deepLinkService.clearPendingDeepLink();
        deepLinkService.handleDeepLink(pending);
      }
      _checkAndPromptForNotifications();
    });
  }

  Future<void> _checkAndPromptForNotifications() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    final hasPrompted = await secureStorage.getHasPromptedForNotifications();

    if (!hasPrompted) {
      await secureStorage.saveHasPromptedForNotifications(true);

      if (mounted) {
        final permissions =
            await NotificationPermissionHelper.requestAllPermissions(context);
        if (permissions) {
          final notifService = ref.read(notificationServiceProvider);
          final token = await notifService.getToken();
          if (token != null) {
            await ref
                .read(notificationsProvider.notifier)
                .registerDeviceToken(token);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wasInBackground = true;
    } else if (state == AppLifecycleState.resumed) {
      if (_wasInBackground) {
        _wasInBackground = false;
        ref.read(notificationsProvider.notifier).fetchUnreadCount();
      }
    }
  }

  void _switchTab(int newIndex) {
    final selectedIndex = ref.read(selectedIndexProvider);
    final targetLabel = _currentLabels[newIndex];

    if (targetLabel == 'Shops') {
      ref.read(selectedShopsCategoryProvider.notifier).state = null;
      if (!GlobalVariables.isGuest) {
        ref.read(shopsProvider.notifier).updateCategory(null);
        ref.read(shopsProvider.notifier).updateSearch('');
      }
      ref.read(allShopsProvider.notifier).updateCategory(null);
      ref.read(allShopsProvider.notifier).updateSearch('');
    }

    if (selectedIndex == newIndex) return;

    ref.read(selectedIndexProvider.notifier).updateIndex(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    final labels = _currentLabels;
    const Color activeColor = Color(0xFF07838C);
    const Color inactiveColor = Color(0xFF99A1AF);

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        log('inside navbar popscope');
        if (selectedIndex != 0) {
          _switchTab(0);
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
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: List.generate(labels.length, (index) {
                        final bool isSelected = selectedIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _switchTab(index);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: isSelected ? 1.15 : 1.0,
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
                                              ? activeColor
                                              : inactiveColor,
                                          size: 24,
                                        );
                                      }
                                      return SvgPicture.asset(
                                        iconPath,
                                        colorFilter: ColorFilter.mode(
                                          isSelected
                                              ? activeColor
                                              : inactiveColor,
                                          BlendMode.srcIn,
                                        ),
                                        width: 24,
                                        height: 24,
                                        placeholderBuilder:
                                            (BuildContext context) => Icon(
                                              iconData,
                                              color: isSelected
                                                  ? activeColor
                                                  : inactiveColor,
                                              size: 24,
                                            ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      labels[index],
                                      style: GoogleFonts.urbanist(
                                        color: isSelected
                                            ? activeColor
                                            : inactiveColor,
                                        fontSize: 10,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
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
