import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/partner_bookings_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/services/snackbar_service.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../../data/utils/launch_url.dart';
import '../../components/advanced_network_image.dart';
import '../../components/confirmation_dialog.dart';

class PartnerBookingDetailPage extends ConsumerStatefulWidget {
  final BookingModel booking;

  const PartnerBookingDetailPage({super.key, required this.booking});

  @override
  ConsumerState<PartnerBookingDetailPage> createState() =>
      _PartnerBookingDetailPageState();
}

class _PartnerBookingDetailPageState
    extends ConsumerState<PartnerBookingDetailPage> {
  static const _bg = Color(0xFFF8FAFC);
  static const _cardBorder = Color(0xFFE5E9F1);
  static const _labelColor = Color(0xFF74767D);
  static const _valueColor = Color(0xFF4E4E4E);
  static const _declineColor = Color(0xFFFF383C);

  late String _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.booking.status.toUpperCase();
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    final snackbar = SnackbarService();
    final res = await ref
        .read(partnerBookingsProvider.notifier)
        .updateBookingStatus(widget.booking.id, status);
    if (!mounted) return;
    setState(() => _isUpdating = false);

    if (res.success) {
      setState(() => _currentStatus = status.toUpperCase());
      snackbar.showSnackBar(
        context,
        'Booking ${status.replaceAll('_', ' ')}',
      );
    } else {
      snackbar.showSnackBar(
        context,
        res.message ?? 'Update failed',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> _handleDecline() async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Decline Booking',
      message: 'Are you sure you want to decline this booking request?',
      confirmText: 'Decline',
      cancelText: 'Keep',
      isDestructive: true,
      confirmColor: _declineColor,
    );
    if (confirmed == true && mounted) {
      await _updateStatus('cancelled');
    }
  }

  (Color bg, Color text) _statusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
      case 'ACCEPTED':
        return (const Color(0xFFE6F7EE), const Color(0xFF10B981));
      case 'IN_PROGRESS':
        return (const Color(0xFFDBEAFE), const Color(0xFF2563EB));
      case 'COMPLETED':
        return (const Color(0xFFEEF2FF), const Color(0xFF6155F5));
      case 'CANCELLED':
      case 'REJECTED':
      case 'NO_SHOW':
        return (const Color(0xFFFEE2E2), const Color(0xFFEF4444));
      case 'PENDING':
      default:
        return (const Color(0xFFFFF3E9), const Color(0xFFFF8D28));
    }
  }

  String _formatStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'NO_SHOW':
        return 'No Show';
      default:
        if (status.isEmpty) return 'Pending';
        return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '—';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed != null) {
      return DateFormat('EEE, d MMM yyyy').format(parsed);
    }
    return dateStr;
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    if (timeStr.contains('AM') || timeStr.contains('PM')) return timeStr;
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, hour, minute);
        return DateFormat('h:mm a').format(dt);
      }
    } catch (_) {}
    return timeStr;
  }

  String _timeRange(BookingModel b) {
    final start = _formatTime(b.startTime);
    final end = _formatTime(b.endTime);
    if (start.isNotEmpty && end.isNotEmpty) return '$start - $end';
    if (start.isEmpty) return '—';
    try {
      final parts = b.startTime.replaceAll(RegExp(r'[^0-9:]'), '').split(':');
      if (parts.length >= 2) {
        var hour = int.parse(parts[0]);
        var minute = int.parse(parts[1]);
        if (b.startTime.toUpperCase().contains('PM') && hour < 12) hour += 12;
        if (b.startTime.toUpperCase().contains('AM') && hour == 12) hour = 0;
        final startDt = DateTime(2000, 1, 1, hour, minute);
        final endDt = startDt.add(Duration(minutes: b.durationMinutes));
        return '$start - ${DateFormat('h:mm a').format(endDt)}';
      }
    } catch (_) {}
    return start;
  }

  String _paymentLabel(String paymentStatus) {
    switch (paymentStatus.toUpperCase()) {
      case 'PAY_AT_STORE':
      case 'PAY_AT_VENUE':
        return 'Pay at Venue';
      case 'PAID':
        return 'Paid';
      case 'PENDING':
        return 'Payment Pending';
      default:
        return paymentStatus
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _callPhone(String phone) async {
    await launchPhone(phone);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final b = widget.booking;
    final token = b.tokenNumber;
    final customerName =
        b.customer?.name ?? b.customerDetails?.name ?? 'Guest Customer';
    final phone = b.customer?.phone ?? b.customerDetails?.phone ?? '';
    final avatar = b.customer?.avatar ?? b.customerDetails?.avatar;
    final serviceName = b.services.isNotEmpty
        ? b.services.join(', ')
        : (b.service?.name ?? 'Service');
    final notes = (b.notes?.isNotEmpty == true)
        ? b.notes!
        : (b.customerDetails?.notes?.isNotEmpty == true
            ? b.customerDetails!.notes!
            : 'None');
    final bookingReference =
        b.bookingNumber.isNotEmpty ? b.bookingNumber : (b.id.isNotEmpty ? b.id : '—');
    final statusStyle = _statusStyle(_currentStatus);
    final isPending = _currentStatus == 'PENDING';
    final isConfirmed =
        _currentStatus == 'CONFIRMED' || _currentStatus == 'ACCEPTED';
    final isInProgress = _currentStatus == 'IN_PROGRESS';
    final showActions = isPending || isConfirmed || isInProgress;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: _bg,
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
          style: GoogleFonts.urbanist(
            color: const Color(0xFF373737),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            height: 20 / 18,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                screenSize.responsivePadding(24),
                screenSize.responsivePadding(8),
                screenSize.responsivePadding(24),
                screenSize.responsivePadding(24),
              ),
              child: Column(
                children: [
                  // Service Details card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.051),
                          blurRadius: 16,
                          spreadRadius: -6,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Details',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _valueColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: 'Status',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusStyle.$1,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _formatStatusLabel(_currentStatus),
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusStyle.$2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: 'Token',
                          value: token.isNotEmpty ? token : '—',
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(label: 'Service', value: serviceName),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: 'Date',
                          value: _formatDate(b.bookingDate),
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(label: 'Time', value: _timeRange(b)),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: 'Duration',
                          value: '${b.durationMinutes} min',
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: 'Amount',
                          value:
                              '₹${b.totalAmount.toInt()} (${_paymentLabel(b.paymentStatus)})',
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(label: 'Special Requests', value: notes),
                        if (b.selectedAddOns.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...b.selectedAddOns.map(
                            (addon) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _DetailRow(
                                label: '+ ${addon.name}',
                                value: '₹${addon.price.toInt()}',
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(height: 1, thickness: 1, color: _cardBorder),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: 'Booking Reference',
                          value: bookingReference,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.responsivePadding(12)),

                  // Customer card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.051),
                          blurRadius: 16,
                          spreadRadius: -6,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: avatar != null && avatar.isNotEmpty
                                ? AdvancedNetworkImage(
                                    imageUrl: avatar,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorWidget: Container(
                                      color: kPrimaryColor,
                                      alignment: Alignment.center,
                                      child: Text(
                                        _initials(customerName),
                                        style: GoogleFonts.urbanist(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: kPrimaryColor,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _initials(customerName),
                                      style: GoogleFonts.urbanist(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerName,
                                style: GoogleFonts.urbanist(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _valueColor,
                                ),
                              ),
                              if (phone.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  phone,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: _labelColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (phone.isNotEmpty)
                          InteractiveFeedbackButton(
                            onPressed: () => _callPhone(phone),
                            scaleFactor: 0.95,
                            child: Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: kPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.phone_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (showActions)
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  screenSize.responsivePadding(24),
                  screenSize.responsivePadding(16),
                  screenSize.responsivePadding(24),
                  screenSize.responsivePadding(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: isPending ? 'Decline' : 'Cancel',
                        filled: false,
                        color: _declineColor,
                        borderRadius: 12,
                        enabled: !_isUpdating,
                        onPressed: _handleDecline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        label: isPending
                            ? 'Confirm Booking'
                            : isConfirmed
                                ? 'Start Service'
                                : 'Mark Completed',
                        filled: true,
                        color: kPrimaryColor,
                        borderRadius: 999,
                        enabled: !_isUpdating,
                        onPressed: () {
                          if (isPending) {
                            _updateStatus('confirmed');
                          } else if (isConfirmed) {
                            _updateStatus('in_progress');
                          } else {
                            _updateStatus('completed');
                          }
                        },
                      ),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;
  final bool compact;

  const _DetailRow({
    required this.label,
    this.value,
    this.child,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = compact ? 12.0 : 14.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF74767D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: child ??
                Text(
                  value ?? '—',
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.urbanist(
                    fontSize: fontSize,
                    fontWeight: compact ? FontWeight.w700 : FontWeight.w600,
                    color: compact
                        ? const Color(0xFF74767D)
                        : const Color(0xFF4E4E4E),
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final Color color;
  final double borderRadius;
  final bool enabled;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.filled,
    required this.color,
    required this.borderRadius,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveFeedbackButton(
      onPressed: enabled ? onPressed : null,
      scaleFactor: 0.98,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Container(
          height: 51,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: filled ? null : Border.all(color: color, width: 1),
          ),
          child: Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}
