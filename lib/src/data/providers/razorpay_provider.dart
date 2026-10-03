import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/razorpay_service.dart';

RazorpayService? _razorpayServiceInstance;

/// Keep-alive Razorpay service so native checkout callbacks survive route changes.
final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  final existing = _razorpayServiceInstance;
  if (existing != null) {
    log('Reusing Razorpay service', name: 'razorpayProvider');
    return existing;
  }

  log('Creating Razorpay service', name: 'razorpayProvider');
  final service = RazorpayService();
  _razorpayServiceInstance = service;

  ref.onDispose(() {
    // Keep singleton alive for payment callbacks — do not dispose with provider.
    log(
      'Razorpay provider disposed (service kept alive)',
      name: 'razorpayProvider',
    );
  });

  return service;
});
