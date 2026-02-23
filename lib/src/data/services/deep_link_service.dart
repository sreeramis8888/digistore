import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digistore/src/data/router/nav_router.dart';
import 'package:digistore/src/data/services/navigation_service.dart';
import 'package:digistore/src/data/services/secure_storage_service.dart';
import 'package:digistore/src/data/services/snackbar_service.dart';
import 'package:digistore/src/data/utils/date_formatter.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService(ref);
});

class DeepLinkService {
  final Ref _ref;
  final _appLinks = AppLinks();
  Uri? _pendingDeepLink;

  DeepLinkService(this._ref);

  Uri? get pendingDeepLink => _pendingDeepLink;

  void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  static bool _isInitialized = false;

  /// Initialize deep link handling
  /// Call this in your main app after navigation is ready
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🔗 Deep link service already initialized');
      return;
    }

    try {
      debugPrint('🔗 Deep link service initializing...');

      // Handle deep link when app is launched from terminated state
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        _pendingDeepLink = appLink;
        debugPrint(
          '🔗 Initial deep link stored as pending: ${appLink.toString()}',
        );
        debugPrint('🔗 Initial link path segments: ${appLink.pathSegments}');
        debugPrint('🔗 Initial link scheme: ${appLink.scheme}');
        debugPrint('🔗 Initial link host: ${appLink.host}');
        // Don't handle immediately - let splash screen handle it
      } else {
        debugPrint('🔗 No initial deep link found');
      }

      // Handle deep links when app is in background/foreground
      _appLinks.uriLinkStream.listen((uri) {
        debugPrint(
          '🔗 ⚡ Deep link received while app is running: ${uri.toString()}',
        );
        debugPrint('🔗 Link path segments: ${uri.pathSegments}');
        debugPrint('🔗 Link scheme: ${uri.scheme}');
        debugPrint('🔗 Link host: ${uri.host}');
        // Handle immediately when app is already running (not from terminated state)
        handleDeepLink(uri);
      });

      _isInitialized = true;
      debugPrint('🔗 Deep link service initialized successfully');
    } catch (e) {
      debugPrint('❌ Deep link initialization error: $e');
    }
  }

  /// Handle notification payload map
  void handleNotificationData(Map<String, dynamic> data) {
    try {
      debugPrint('📩 Processing notification data: $data');
      final screen = data['screen'] as String?;
      final id = data['id'] as String?;

      if (screen != null) {
        final uriString = 'app://$screen${id != null ? '/$id' : ''}';
        final uri = Uri.parse(uriString);
        handleDeepLink(uri);
      }
    } catch (e) {
      debugPrint('❌ Error handling notification data: $e');
    }
  }

  /// Main deep link handler - routes to appropriate screen
  Future<void> handleDeepLink(Uri uri) async {
    try {
      debugPrint('🔗 Deep link received: ${uri.toString()}');
      debugPrint('🔗 Path segments: ${uri.pathSegments}');
      debugPrint('🔗 Query parameters: ${uri.queryParameters}');

      // Filter out empty segments and 'app' prefix
      var pathSegments = uri.pathSegments
          .where((segment) => segment.isNotEmpty)
          .toList();

      // Remove 'app' prefix if present
      if (pathSegments.isNotEmpty && pathSegments[0] == 'app') {
        pathSegments = pathSegments.sublist(1);
      }

      debugPrint('🔗 Filtered segments: $pathSegments');

      // Verify user is authenticated
      final secureStorage = _ref.read(secureStorageServiceProvider);
      final savedToken = await secureStorage.getBearerToken();
      final savedId = await secureStorage.getUserId();

      if (savedToken == null || savedToken.isEmpty || savedId == null) {
        debugPrint(
          'Authentication required for deep link. Redirecting to login.',
        );

        // Ensure navigator is ready
        if (NavigationService.navigatorKey.currentState == null) {
          debugPrint('Navigator not ready, retrying...');
          await Future.delayed(const Duration(milliseconds: 500));
        }

        NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          'Phone',
          (route) => false,
        );
        return;
      }

      // Ensure navigator is ready
      if (NavigationService.navigatorKey.currentState == null) {
        debugPrint('Navigator not ready, retrying...');
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // If no valid route segments, redirect to home
      if (pathSegments.isEmpty) {
        debugPrint('🔗 No valid route in deep link, redirecting to home');
        await _navigateToHome();
        return;
      }

      // Route based on path
      final route = pathSegments[0].toLowerCase();
      final id = pathSegments.length > 1 ? pathSegments[1] : null;

      switch (route) {
        case 'campaign':
          await _navigateToCampaign(id);
          break;
        case 'event':
          await _navigateToEvent(id);
          break;
        case 'feed':
          await _navigateToFeed(id);
          break;
        case 'resource':
          await _navigateToResource(id);
          break;
        case 'notifications':
          await _navigateToNotifications();
          break;
        case 'profile':
          await _navigateToProfile();
          break;
        case 'general':
          await _navigateToHome();
          break;
        default:
          debugPrint(
            '🔗 Unknown deep link route: $route. Staying on current page.',
          );
          break;
      }
    } catch (e) {
      debugPrint('❌ Deep link handling error: $e');
      _showError('Unable to process the link');
    }
  }

  /// Navigate to home/navbar
  Future<void> _navigateToHome() async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      _ref.read(selectedIndexProvider.notifier).updateIndex(0);
      debugPrint('✅ Navigated to Home');
    } catch (e) {
      debugPrint('Error navigating to home: $e');
    }
  }

  /// Navigate to campaigns
  Future<void> _navigateToCampaign(String? campaignId) async {

  }

  Future<void> _navigateToResource(String? resourceId) async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _ref.read(selectedIndexProvider.notifier).updateIndex(2);

      if (resourceId != null && resourceId.isNotEmpty) {
        NavigationService.navigatorKey.currentState?.pushNamed(
          'ResourceDetails',
          arguments: {'id': resourceId},
        );
        debugPrint('✅ Navigated to Resource Details: $resourceId');
      } else {
        debugPrint('✅ Navigated to Resource');
      }
    } catch (e) {
      debugPrint('Error navigating to resource: $e');
      _showError('Unable to navigate to Resource');
    }
  }

  /// Navigate to event
  Future<void> _navigateToEvent(String? eventId) async {
  }

  /// Navigate to individual feed
  Future<void> _navigateToFeed(String? feedId) async {
    try {
      if (feedId != null && feedId.isNotEmpty) {
        // Navigate directly to feed detail without going through navbar
        NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          'navbar',
          (route) => false,
        );
        await Future.delayed(const Duration(milliseconds: 100));
        NavigationService.navigatorKey.currentState?.pushNamed(
          'FeedDetail',
          arguments: {'id': feedId},
        );
        debugPrint('✅ Navigated to Feed Detail: $feedId');
      } else {
        // Navigate to feeds tab
        NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          'navbar',
          (route) => false,
        );
        await Future.delayed(const Duration(milliseconds: 100));
        _ref.read(selectedIndexProvider.notifier).updateIndex(1);
        debugPrint('✅ Navigated to Feed');
      }
    } catch (e) {
      debugPrint('Error navigating to feed: $e');
      _showError('Unable to navigate to Feed');
    }
  }


  Future<void> _navigateToNotifications() async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _ref
          .read(selectedIndexProvider.notifier)
          .updateIndex(0); // Use Home as base
      NavigationService.navigatorKey.currentState?.pushNamed('Notifications');
      debugPrint('✅ Navigated to Notifications');
    } catch (e) {
      debugPrint('Error navigating to notifications: $e');
      _showError('Unable to navigate to Notifications');
    }
  }

  /// Navigate to profile
  Future<void> _navigateToProfile() async {
    try {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        'navbar',
        (route) => false,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _ref
          .read(selectedIndexProvider.notifier)
          .updateIndex(3); // Profile is index 3
      debugPrint('✅ Navigated to Profile');
    } catch (e) {
      debugPrint('Error navigating to profile: $e');
      _showError('Unable to navigate to Profile');
    }
  }

  void _showError(String message) {
    if (NavigationService.navigatorKey.currentContext != null) {
      SnackbarService().showSnackBar(
        NavigationService.navigatorKey.currentContext!,
        message,
        type: SnackbarType.error,
      );
    }
  }

  /// Generate deep link URLs for sharing
  /// Use HTTPS links for WhatsApp/social media compatibility
  String generateDeepLink(String route, {String? id}) {
    // Use HTTPS for clickable links in WhatsApp, Gmail, etc.
    const baseUrl = 'https://app-mmc.24connect.in/app';

    switch (route) {
      case 'campaign':
        return id != null ? '$baseUrl/campaign/$id' : '$baseUrl/campaign';
      case 'event':
        return id != null ? '$baseUrl/event/$id' : '$baseUrl/event';
      case 'feed':
        return id != null ? '$baseUrl/feed/$id' : '$baseUrl/feed';
      case 'chat':
        return id != null ? '$baseUrl/chat/$id' : '$baseUrl/chat';
      case 'resource':
        return id != null ? '$baseUrl/resource/$id' : '$baseUrl/resource';
      case 'notifications':
        return '$baseUrl/notifications';
      case 'profile':
        return '$baseUrl/profile';
      default:
        return '$baseUrl/general';
    }
  }
}
