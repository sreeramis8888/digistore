import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/utils/global_variables.dart';
import '../../../data/providers/user_type_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../components/partner/partner_menu_item.dart';
import '../../components/partner/partner_action_card.dart';
import '../../components/partner/partner_profile_header.dart';
import '../../animations/index.dart';
import '../../../data/utils/notification_permission_helper.dart';
import '../../../data/services/notification_service/notification_service.dart';
import '../../../data/providers/notifications_provider.dart';

class PartnerProfilePage extends ConsumerStatefulWidget {
  const PartnerProfilePage({super.key});

  @override
  ConsumerState<PartnerProfilePage> createState() => _PartnerProfilePageState();
}

class _PartnerProfilePageState extends ConsumerState<PartnerProfilePage>
    with WidgetsBindingObserver {
  bool _isNotificationsEnabled = true;
  bool _isTokenRegistered = true;
  bool _isHiding = false;
  String? _currentFcmToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationStatus();
    }
  }

  Future<void> _checkNotificationStatus() async {
    final isAllowed =
        await NotificationPermissionHelper.isNotificationAllowed();
    final notifService = ref.read(notificationServiceProvider);
    final token = await notifService.getToken();
    final partner = ref.read(partnerProvider);

    bool isRegistered = false;
    if (token != null && partner?.devices != null) {
      isRegistered = partner!.devices!.any((d) => d.fcmToken == token);
    }

    if (mounted) {
      setState(() {
        _isNotificationsEnabled = isAllowed && isRegistered;
        _isTokenRegistered = isRegistered;
        _currentFcmToken = token;
      });
    }
  }

  void _syncWithProvider() {
    final partner = ref.read(partnerProvider);
    if (_currentFcmToken != null && partner?.devices != null) {
      final isRegistered = partner!.devices!.any(
        (d) => d.fcmToken == _currentFcmToken,
      );
      if (isRegistered != _isTokenRegistered && !_isHiding) {
        setState(() {
          _isTokenRegistered = isRegistered;
          if (isRegistered) _isNotificationsEnabled = true;
        });
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final permissions =
          await NotificationPermissionHelper.requestAllPermissions(context);
      if (permissions) {
        final notifService = ref.read(notificationServiceProvider);
        final token = await notifService.getToken();
        if (token != null) {
          final success = await ref
              .read(notificationsProvider.notifier)
              .registerDeviceToken(token);
          if (success && mounted) {
            setState(() {
              _isNotificationsEnabled = true;
              _currentFcmToken = token;
            });

            await Future.delayed(const Duration(seconds: 1));

            if (mounted) {
              setState(() {
                _isHiding = true;
              });

              await Future.delayed(const Duration(milliseconds: 600));

              if (mounted) {
                setState(() {
                  _isTokenRegistered = true;
                  _isHiding = false;
                });
              }
            }
          }
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please disable notifications from system settings.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(partnerProvider, (previous, next) {
      _syncWithProvider();
    });
    final screenSize = ref.watch(screenSizeProvider);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: kWhite,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Text('Profile', style: kSubHeadingSB.copyWith(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.responsivePadding(16)),
              PartnerProfileHeader(screenSize: screenSize),
              SizedBox(height: screenSize.responsivePadding(16)),
              Row(
                children: [
                  PartnerActionCard(
                    screenSize: screenSize,
                    title: 'Offers',
                    iconData: Icons.discount_outlined,
                    onTap: () => Navigator.pushNamed(context, 'offers'),
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  PartnerActionCard(
                    screenSize: screenSize,
                    title: 'Products',
                    iconData: Icons.inventory_2_outlined,
                    onTap: () =>
                        Navigator.pushNamed(context, 'partnerProducts'),
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  PartnerActionCard(
                    screenSize: screenSize,
                    title: 'History',
                    iconData: Icons.history_rounded,
                    onTap: () => Navigator.pushNamed(context, 'partnerHistory'),
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(16)),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchOutCurve: Curves.easeInOutBack,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1,
                        child: child,
                      ),
                    ),
                  );
                },
                child:
                    (!(_isTokenRegistered && _isNotificationsEnabled) &&
                        !_isHiding)
                    ? Container(
                        key: const ValueKey('notif_card_partner'),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF0F4FF), Color(0xFFFAFBFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD3DFFF)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1e3a81).withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.responsivePadding(16),
                            vertical: screenSize.responsivePadding(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1e3a81,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: Color(0xFF1e3a81),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: screenSize.responsivePadding(16)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Push Notifications',
                                      style: kBodyTitleB.copyWith(
                                        color: kBlack,
                                      ),
                                    ),
                                    SizedBox(
                                      height: screenSize.responsivePadding(4),
                                    ),
                                    Text(
                                      'Stay updated on offers & rewards',
                                      style: kSmallTitleL.copyWith(
                                        color: const Color(0xFF6B7280),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isNotificationsEnabled,
                                onChanged: _toggleNotifications,
                                activeColor: const Color(0xFF1e3a81),
                                activeTrackColor: const Color(
                                  0xFF1e3a81,
                                ).withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ).fadeSlideInFromBottom(delayMilliseconds: 150)
                    : const SizedBox.shrink(),
              ),
              if (!(_isTokenRegistered && _isNotificationsEnabled) &&
                  !_isHiding)
                SizedBox(height: screenSize.responsivePadding(16)),

              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    PartnerMenuItem(
                      title: 'Account',
                      icon: const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize: screenSize,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'partnerAccount',
                          arguments: {'isEditMode': false},
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    PartnerMenuItem(
                      title: 'Help & Support',
                      icon: const Icon(
                        Icons.headphones_outlined,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize: screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    PartnerMenuItem(
                      title: 'Terms & Privacy Policy',
                      icon: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize: screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    PartnerMenuItem(
                      title: 'About app',
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize: screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                      indent: 16,
                      endIndent: 16,
                    ),
                    PartnerMenuItem(
                      title: 'FAQ',
                      icon: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      screenSize: screenSize,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(16)),
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: PartnerMenuItem(
                  title: 'Logout',
                  icon: const Icon(Icons.logout_rounded, color: kRed, size: 22),
                  screenSize: screenSize,
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        'login',
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(40)),
            ],
          ),
        ),
      ),
    );
  }
}
