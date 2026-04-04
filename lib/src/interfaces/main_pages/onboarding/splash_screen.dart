import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/global_variables.dart';
import '../../../data/services/secure_storage_service.dart';
import '../../../data/providers/user_provider.dart';
import 'login_page.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<Offset> _slideAnimation;

  // Slogan animations
  late AnimationController _sloganController;
  late Animation<double> _sloganOpacity;
  late Animation<Offset> _sloganSlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _sloganController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_entranceController);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _blurAnimation = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _sloganOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _sloganController, curve: Curves.easeIn));

    _sloganSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _sloganController, curve: Curves.easeOutBack),
        );

    _playAnimations();
  }

  Future<void> _playAnimations() async {
    await _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _sloganController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    GlobalVariables.setMerchantMode(false); 
    
    final storage = ref.read(secureStorageServiceProvider);
    final hasToken = await storage.hasBearerToken();
    
    if (!mounted) return;

    if (hasToken) {
      while (true) {
        final statusCode = await ref.read(userProvider.notifier).getProfile();
        
        if (!mounted) return;
        
        if (statusCode == 200) {
          final user = ref.watch(userProvider);
          final isComplete = user?.onboardingComplete ?? false;
          await storage.saveOnboardingComplete(isComplete);
          
          if (isComplete) {
            Navigator.of(context).pushReplacementNamed('navbar');
          } else {
            Navigator.of(context).pushReplacementNamed('profileSetup');
          }
          break;
        } else if (statusCode == null) {
          // Network problem or parsing error -> Stay and Retry
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Network error. Retrying in 3 seconds...'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          await Future.delayed(const Duration(seconds: 3));
        } else {
          // Actual status code error (401, 403, 500, etc.) -> Login
          await storage.clearAll();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
          break;
        }
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _sloganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final logoSize = screenSize.responsivePadding(180);

    return Scaffold(
      backgroundColor: kWhite,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: kWhite,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _opacityAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: _blurAnimation.value,
                                sigmaY: _blurAnimation.value,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: logoSize,
                                    height: logoSize,
                                    child: Image.asset(
                                      'assets/png/setgo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  if (_entranceController.value > 0.5)
                                    Shimmer.fromColors(
                                      baseColor: Colors.transparent,
                                      highlightColor: Colors.white.withOpacity(
                                        0.8,
                                      ),
                                      period: const Duration(
                                        milliseconds: 1500,
                                      ),
                                      direction: ShimmerDirection.ltr,
                                      child: SizedBox(
                                        width: logoSize,
                                        height: logoSize,
                                        child: Image.asset(
                                          'assets/png/setgo.png',
                                          fit: BoxFit.contain,
                                          color: Colors.white.withAlpha(200),
                                          colorBlendMode: BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  AnimatedBuilder(
                    animation: _sloganController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _sloganSlide,
                        child: FadeTransition(
                          opacity: _sloganOpacity,
                          child: Text(
                            'Spend Local. Save Big.',
                            style: kSmallTitleL.copyWith(
                              color: kSecondaryTextColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
