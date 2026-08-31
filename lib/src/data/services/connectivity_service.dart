import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'navigation_service.dart';
import 'toast_service.dart';

class ConnectivityService with WidgetsBindingObserver {
  static final ConnectivityService _instance = ConnectivityService._internal();
  static ConnectivityService get instance => _instance;

  ConnectivityService._internal();

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  Timer? _pollingTimer;
  DateTime? _lastToastTime;
  bool _isChecking = false;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addObserver(this);

    // Initial check
    checkConnectivity();

    // Periodic check every 6 seconds
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      checkConnectivity();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkConnectivity();
    }
  }

  Future<bool> checkConnectivity() async {
    if (_isChecking) return !_isOffline;
    _isChecking = true;

    bool isConnected = false;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } catch (_) {
      try {
        final socket = await Socket.connect('8.8.8.8', 53,
            timeout: const Duration(seconds: 2));
        socket.destroy();
        isConnected = true;
      } catch (_) {
        isConnected = false;
      }
    } finally {
      _isChecking = false;
    }

    _handleStatusChange(isConnected);
    return isConnected;
  }

  void notifyOffline() {
    _handleStatusChange(false, forceToast: true);
  }

  void _handleStatusChange(bool isConnected, {bool forceToast = false}) {
    final now = DateTime.now();
    final bool canShowToast = _lastToastTime == null ||
        now.difference(_lastToastTime!).inSeconds >= 5;

    if (!isConnected) {
      final wasOnline = !_isOffline;
      _isOffline = true;

      if ((wasOnline || forceToast) && canShowToast) {
        _lastToastTime = now;
        _showToast(
          'You are offline. Please check your internet connection.',
          ToastType.error,
        );
      }
    } else {
      final wasOffline = _isOffline;
      _isOffline = false;

      if (wasOffline && canShowToast) {
        _lastToastTime = now;
        _showToast(
          'You are back online.',
          ToastType.success,
        );
      }
    }
  }

  void _showToast(String message, ToastType type) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      ToastService().showToast(
        context,
        message,
        type: type,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
  }
}
