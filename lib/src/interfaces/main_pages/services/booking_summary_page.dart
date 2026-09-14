import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../components/primary_button.dart';
import 'booking_confirmed_page.dart';

class BookingSummaryPage extends ConsumerStatefulWidget {
  final ServicePartnerModel partner;
  final String partnerId;
  final List<ServiceModel> services;
  final String bookingDate;
  final TimeSlotModel selectedSlot;
  final String notes;
  final double totalPrice;
  final double originalPrice;

  const BookingSummaryPage({
    super.key,
    required this.partner,
    required this.partnerId,
    required this.services,
    required this.bookingDate,
    required this.selectedSlot,
    required this.notes,
    required this.totalPrice,
    required this.originalPrice,
  });

  @override
  ConsumerState<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends ConsumerState<BookingSummaryPage> {
  bool _isSubmitting = false;

  Future<void> _handleConfirmBooking() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final serviceIds = widget.services.map((s) => s.id ?? '').where((id) => id.isNotEmpty).toList();

    final res = await BookingService.createBooking(
      api: ref.read(publicApiProvider),
      partnerId: widget.partnerId,
      serviceIds: serviceIds,
      bookingDate: widget.bookingDate,
      startTime: widget.selectedSlot.startTime,
      notes: widget.notes.isNotEmpty ? widget.notes : null,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (res.success && res.data != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmedPage(booking: res.data!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? 'Booking failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final savings = widget.originalPrice - widget.totalPrice;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF373737),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking Summary',
          style: kSubHeadingM.copyWith(
            color: const Color(0xFF373737),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appointment Details Card
                    Container(
                      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: kPrimaryColor,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: screenSize.responsivePadding(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.bookingDate} at ${widget.selectedSlot.startTime}',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    SizedBox(height: screenSize.responsivePadding(2)),
                                    Text(
                                      widget.partner.name ?? 'Store',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: Color(0xFFE5E7EB)),
                          Text(
                            'Selected Services',
                            style: kSmallerTitleL.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: screenSize.responsivePadding(8)),
                          ...widget.services.map((s) => Padding(
                                padding: EdgeInsets.symmetric(vertical: screenSize.responsivePadding(4)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '• ${s.name} (${s.totalTimeMinutes}m)',
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 13,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹ ${s.effectivePrice.toInt()}',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          if (widget.notes.isNotEmpty) ...[
                            const Divider(height: 20, color: Color(0xFFE5E7EB)),
                            Text(
                              'Notes: "${widget.notes}"',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(16)),

                    // Bill Breakdown
                    Container(
                      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Details',
                            style: kSmallerTitleL.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: screenSize.responsivePadding(12)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Item Total', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                              Text('₹ ${widget.originalPrice.toInt()}', style: const TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          if (savings > 0) ...[
                            SizedBox(height: screenSize.responsivePadding(8)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Offer Discount', style: TextStyle(color: Color(0xFF07982C), fontSize: 13)),
                                Text('- ₹ ${savings.toInt()}', style: const TextStyle(color: Color(0xFF07982C), fontSize: 13, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                          const Divider(height: 20, color: Color(0xFFE5E7EB)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount Due',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Text(
                                '₹ ${widget.totalPrice.toInt()}',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Confirm Button
            Container(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              decoration: BoxDecoration(
                color: kWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: PrimaryButton(
                onPressed: _handleConfirmBooking,
                isEnabled: !_isSubmitting,
                width: double.infinity,
                height: screenSize.responsivePadding(48),
                text: _isSubmitting ? 'Confirming...' : 'Confirm & Book',
                textSize: 15,
                backgroundColor: kPrimaryColor,
                textColor: kWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
