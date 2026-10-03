import 'dart:developer';

import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef PaymentSuccessHandler = void Function(PaymentSuccessResponse response);
typedef PaymentErrorHandler = void Function(PaymentFailureResponse response);
typedef ExternalWalletHandler = void Function(ExternalWalletResponse response);

/// Thin wrapper around [Razorpay] that keeps callbacks alive across
/// route rebuilds (checkout opens a native activity).
///
/// Never put RAZORPAY_KEY_SECRET in the app — verification is server-side only.
class RazorpayService {
  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    log('Razorpay handlers registered', name: 'RazorpayService');
  }

  late final Razorpay _razorpay;
  PaymentSuccessHandler? _onSuccess;
  PaymentErrorHandler? _onError;
  ExternalWalletHandler? _onExternalWallet;
  bool _disposed = false;

  /// Fallback key from `--dart-define-from-file=.env` (KEY_ID only).
  static const String envKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );

  void setCallbacks({
    required PaymentSuccessHandler onSuccess,
    required PaymentErrorHandler onError,
    ExternalWalletHandler? onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;
  }

  /// Opens one-time checkout for a Razorpay order.
  ///
  /// [amount] must be in INR (rupees). Checkout expects paise.
  void openCheckout({
    required String keyId,
    required String orderId,
    required num amount,
    required String name,
    required String description,
    String currency = 'INR',
    String? contact,
    String? email,
    String? customerName,
    String themeColor = '#6155F5',
  }) {
    final key = _resolveKey(keyId);
    final trimmedOrderId = orderId.trim();
    if (trimmedOrderId.isEmpty) {
      throw Exception('Payment order is missing. Please try again.');
    }
    if (amount <= 0) {
      throw Exception('Invalid payment amount.');
    }

    final options = <String, dynamic>{
      'key': key,
      'amount': (amount * 100).round(),
      'currency': currency,
      'name': name,
      'description': description,
      'order_id': trimmedOrderId,
      'theme': {'color': themeColor},
      'prefill': _prefill(
        contact: contact,
        email: email,
        name: customerName,
      ),
    };

    _open(options);
  }

  String _resolveKey(String keyId) {
    final fromApi = keyId.trim();
    if (fromApi.isNotEmpty) return fromApi;
    final fromEnv = envKeyId.trim();
    if (fromEnv.isNotEmpty) return fromEnv;
    throw Exception(
      'Razorpay is not configured. Missing keyId from server '
      'and RAZORPAY_KEY_ID in dart-defines.',
    );
  }

  Map<String, String> _prefill({
    String? contact,
    String? email,
    String? name,
  }) {
    final map = <String, String>{};
    final phone = _normalizeContact(contact);
    final mail = email?.trim();
    final displayName = name?.trim();
    if (phone != null) map['contact'] = phone;
    if (mail != null && mail.isNotEmpty) map['email'] = mail;
    if (displayName != null && displayName.isNotEmpty) map['name'] = displayName;
    return map;
  }

  /// Razorpay expects digits; keep country code when present (e.g. 91…).
  String? _normalizeContact(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;
    return digits;
  }

  void _open(Map<String, dynamic> options) {
    if (_disposed) {
      throw Exception('Payment service was closed. Please try again.');
    }
    try {
      log(
        'Opening Razorpay checkout: '
        'key=${_maskKey(options['key']?.toString())}, '
        'order=${options['order_id']}, '
        'amount=${options['amount']}',
        name: 'RazorpayService',
      );
      _razorpay.open(options);
    } catch (e, st) {
      log('Failed to open Razorpay: $e', name: 'RazorpayService', stackTrace: st);
      rethrow;
    }
  }

  String _maskKey(String? key) {
    if (key == null || key.length < 8) return '***';
    return '${key.substring(0, 8)}…';
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    log(
      'Payment success: paymentId=${response.paymentId}, '
      'orderId=${response.orderId}',
      name: 'RazorpayService',
    );
    if (_disposed) return;
    final cb = _onSuccess;
    if (cb == null) {
      log('WARNING: onSuccess callback is null', name: 'RazorpayService');
      return;
    }
    cb(response);
  }

  void _handleError(PaymentFailureResponse response) {
    log(
      'Payment error: code=${response.code}, message=${response.message}',
      name: 'RazorpayService',
    );
    if (_disposed) return;
    final cb = _onError;
    if (cb == null) {
      log('WARNING: onError callback is null', name: 'RazorpayService');
      return;
    }
    cb(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External wallet: ${response.walletName}', name: 'RazorpayService');
    if (_disposed) return;
    _onExternalWallet?.call(response);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _onSuccess = null;
    _onError = null;
    _onExternalWallet = null;
    _razorpay.clear();
    log('Razorpay disposed', name: 'RazorpayService');
  }
}
