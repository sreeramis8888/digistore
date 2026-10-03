/// Razorpay order payload returned with booking create / create-order.
///
/// Amount is in INR (rupees), matching backend `booking-payment.service.js`.
class BookingRazorpayOrder {
  final String orderId;
  final double amount;
  final String currency;
  final String keyId;
  final String? receipt;
  final String? bookingId;
  final String? bookingNumber;

  const BookingRazorpayOrder({
    required this.orderId,
    required this.amount,
    this.currency = 'INR',
    required this.keyId,
    this.receipt,
    this.bookingId,
    this.bookingNumber,
  });

  factory BookingRazorpayOrder.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return BookingRazorpayOrder(
      orderId: (json['orderId'] ?? json['order_id'] ?? json['id'] ?? '')
          .toString(),
      amount: parseAmount(json['amount']),
      currency: (json['currency'] ?? 'INR').toString(),
      keyId: (json['keyId'] ?? json['key_id'] ?? json['razorpay_key_id'] ?? '')
          .toString(),
      receipt: json['receipt']?.toString(),
      bookingId: (json['bookingId'] ?? json['booking_id'])?.toString(),
      bookingNumber:
          (json['bookingNumber'] ?? json['booking_number'])?.toString(),
    );
  }

  bool get isValid => orderId.isNotEmpty && amount > 0;
}
