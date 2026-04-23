import 'package:digistore/src/data/utils/interactive_feedback_button.dart';
import 'package:digistore/src/interfaces/animations/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/providers/user_type_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/utils/global_variables.dart';
import '../../components/primary_button.dart';
import '../history.dart';
import '../../../data/utils/notification_permission_helper.dart';
import '../../../data/services/notification_service/notification_service.dart';
import '../../../data/providers/notifications_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isNotificationsEnabled = false;
  bool _isTokenRegistered = false;
  bool _isHiding = false;
  String? _currentFcmToken;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final isAllowed = await NotificationPermissionHelper.isNotificationAllowed();
    final notifService = ref.read(notificationServiceProvider);
    final token = await notifService.getToken();
    final user = ref.read(userProvider);

    bool isRegistered = false;
    if (token != null && user?.devices != null) {
      isRegistered = user!.devices!.any((d) => d.fcmToken == token);
    }

    if (mounted) {
      setState(() {
        _isNotificationsEnabled = isAllowed && isRegistered;
        _isTokenRegistered = isRegistered;
        _currentFcmToken = token;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final permissions = await NotificationPermissionHelper.requestAllPermissions(context);
      if (permissions) {
        final notifService = ref.read(notificationServiceProvider);
        final token = await notifService.getToken();
        if (token != null) {
          final success = await ref.read(notificationsProvider.notifier).registerDeviceToken(token);
          if (success && mounted) {
            setState(() {
              _isNotificationsEnabled = true;
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
        const SnackBar(content: Text('Please disable notifications from system settings.')),
      );
    }
  }

  Widget _buildMenuItem(
    String title,
    Widget icon,
    ScreenSizeData screenSize, {
    VoidCallback? onTap,
  }) {
    return InteractiveFeedbackButton(
      onPressed: onTap ?? () {},
      scaleFactor: 0.98,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(16),
          vertical: screenSize.responsivePadding(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: screenSize.responsivePadding(24),
              height: screenSize.responsivePadding(24),
              child: Center(child: icon),
            ),
            SizedBox(width: screenSize.responsivePadding(16)),
            Expanded(child: Text(title, style: kSmallTitleL)),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: screenSize.responsivePadding(14),
              color: kStrokeColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final user = ref.watch(userProvider);
    final name = (user?.name != null && user!.name!.isNotEmpty)
        ? user.name!
        : 'Guest User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';
    final phone = (user?.phone != null && user!.phone!.isNotEmpty)
        ? user.phone!
        : '9998877766';
    final locationName = (user?.location?.localBody != null && user!.location!.localBody!.isNotEmpty)
        ? user.location!.localBody!.split(' ').first
        : (user?.location?.district != null && user!.location!.district!.isNotEmpty)
            ? user.location!.district!.split(' ').first
            : 'Not Set';

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
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
              SizedBox(height: screenSize.responsivePadding(12)),
              // Header Row
              Row(
                children: [
                  Container(
                    width: screenSize.responsivePadding(50),
                    height: screenSize.responsivePadding(50),
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: kLargeTitleM.copyWith(color: kWhite),
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(name, style: kBodyTitleM),
                            Text(
                              ' • $phone',
                              style: kSmallTitleL.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.responsivePadding(4)),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: kSecondaryTextColor,
                              size: 16,
                            ),
                            SizedBox(width: screenSize.responsivePadding(4)),
                            Text(
                              locationName,
                              style: kSmallTitleL.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InteractiveFeedbackButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        'myAccount',
                        arguments: {'isEditMode': true},
                      );
                    },
                    scaleFactor: 1.2,
                    child: SvgPicture.asset('assets/svg/edit.svg'),
                  ),
                ],
              ).fadeIn(),

              SizedBox(height: screenSize.responsivePadding(32)),

              // First Card
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kStrokeColor),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      'My Account',
                      const Icon(
                        Icons.person_outline_rounded,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'myAccount',
                          arguments: {'isEditMode': false},
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kStrokeColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'My Claimed Vouchers',
                      const Icon(
                        Icons.sell_outlined,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                      onTap: () {
                        Navigator.pushNamed(context, 'claimedRewards');
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kStrokeColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'My History',
                      const Icon(
                        Icons.history_rounded,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).fadeSlideInFromBottom(delayMilliseconds: 100),

              SizedBox(height: screenSize.responsivePadding(20)),

              // Notifications settings card
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
                child: (!_isTokenRegistered && !_isHiding)
                    ? Container(
                        key: const ValueKey('notif_card'),
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
                                  color: const Color(0xFF1e3a81).withOpacity(0.1),
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
                                      style: kBodyTitleB.copyWith(color: kBlack),
                                    ),
                                    SizedBox(height: screenSize.responsivePadding(4)),
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
                                activeTrackColor: const Color(0xFF1e3a81).withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ).fadeSlideInFromBottom(delayMilliseconds: 150)
                    : const SizedBox.shrink(),
              ),
              if (!_isTokenRegistered && !_isHiding)
                SizedBox(height: screenSize.responsivePadding(20)),

              // Second Card
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      'Help & Support',
                      const Icon(
                        Icons.headphones_outlined,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kBorder,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'Terms & Privacy Policy',
                      const Icon(
                        Icons.description_outlined,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kBorder,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMenuItem(
                      'About app',
                      const Icon(
                        Icons.info_outline_rounded,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      screenSize,
                    ),
                  ],
                ),
              ).fadeSlideInFromBottom(delayMilliseconds: 200),

              SizedBox(height: screenSize.responsivePadding(24)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
                child: PrimaryButton(
                  text: 'Log out',
                  backgroundColor: kWhite,
                  textColor: kRed,
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
                    }
                  },
                ).fadeSlideInFromBottom(delayMilliseconds: 300),
              ),

              SizedBox(height: screenSize.responsivePadding(40)),
            ],
          ),
        ),
      ),
    );
  }
}
