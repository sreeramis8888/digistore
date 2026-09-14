import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/partner_bookings_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';

class PartnerBookingDetailPage extends ConsumerStatefulWidget {
  final BookingModel booking;

  const PartnerBookingDetailPage({super.key, required this.booking});

  @override
  ConsumerState<PartnerBookingDetailPage> createState() => _PartnerBookingDetailPageState();
}

class _PartnerBookingDetailPageState extends ConsumerState<PartnerBookingDetailPage> {
  late String _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.booking.status;
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    final res = await ref
        .read(partnerBookingsProvider.notifier)
        .updateBookingStatus(widget.booking.id, status);
    setState(() => _isUpdating = false);

    if (mounted) {
      if (res.success) {
        setState(() => _currentStatus = status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $status')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Update failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF2563EB);
      case 'IN_PROGRESS':
        return const Color(0xFFFF9500);
      case 'COMPLETED':
        return const Color(0xFF34C759);
      case 'CANCELLED':
      case 'NO_SHOW':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final b = widget.booking;
    final token = b.tokenNumber;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          'Booking Details',
          style: kSubHeadingM.copyWith(
            color: const Color(0xFF373737),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenSize.responsivePadding(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOKEN NUMBER',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w700, color: kPrimaryColor, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      token,
                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_currentStatus).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _currentStatus.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _getStatusColor(_currentStatus),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(16)),

              // Customer Details Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.customerDetails?.name ?? 'Guest Customer',
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                            ),
                            if (b.customerDetails?.phone != null && b.customerDetails!.phone.isNotEmpty)
                              Text(
                                b.customerDetails!.phone,
                                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                          ],
                        ),
                        if (b.customerDetails?.phone != null && b.customerDetails!.phone.isNotEmpty)
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFF07982C).withValues(alpha: 0.12), shape: BoxShape.circle),
                              child: const Icon(Icons.call_rounded, color: Color(0xFF07982C), size: 20),
                            ),
                            onPressed: () => launchUrl(Uri.parse('tel:${b.customerDetails!.phone}')),
                          ),
                      ],
                    ),
                    if (b.customerDetails?.notes != null && b.customerDetails!.notes!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Note: ${b.customerDetails!.notes}',
                        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(16)),

              // Services & Timing Card
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
                    const Text(
                      'Service Details',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 6),
                        Text(
                          '${b.bookingDate} at ${b.startTime}',
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (b.service != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '• ${b.service!.name} (${b.service!.totalTimeMinutes}m)',
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF374151)),
                            ),
                            Text(
                              '₹ ${b.service!.effectivePrice.toInt()}',
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                            ),
                          ],
                        ),
                      )
                    else
                      ...b.services.map((sName) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '• $sName',
                              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF374151)),
                            ),
                          )),
                    ...b.selectedAddOns.map((addon) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '+ ${addon.name}',
                                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF6B7280)),
                              ),
                              Text(
                                '₹ ${addon.price.toInt()}',
                                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Bill Amount', style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                        Text(
                          '₹ ${b.totalAmount.toInt()}',
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(24)),

              // Action Buttons
              if (_currentStatus == 'confirmed')
                PrimaryButton(
                  onPressed: () => _updateStatus('in_progress'),
                  isEnabled: !_isUpdating,
                  width: double.infinity,
                  height: screenSize.responsivePadding(46),
                  text: _isUpdating ? 'Updating...' : 'Start Service',
                  textSize: 15,
                  backgroundColor: const Color(0xFF2563EB),
                  textColor: kWhite,
                ),
              if (_currentStatus == 'in_progress')
                PrimaryButton(
                  onPressed: () => _updateStatus('completed'),
                  isEnabled: !_isUpdating,
                  width: double.infinity,
                  height: screenSize.responsivePadding(46),
                  text: _isUpdating ? 'Updating...' : 'Mark Completed',
                  textSize: 15,
                  backgroundColor: const Color(0xFF34C759),
                  textColor: kWhite,
                ),
              if (_currentStatus == 'confirmed' || _currentStatus == 'in_progress') ...[
                SizedBox(height: screenSize.responsivePadding(10)),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isUpdating ? null : () => _updateStatus('no_show'),
                    child: const Text(
                      'Mark No-Show / Cancel',
                      style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFFEF4444), fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
