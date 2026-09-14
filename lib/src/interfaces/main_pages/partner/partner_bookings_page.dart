import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/partner_bookings_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/confirmation_dialog.dart';
import '../../components/loading_indicator.dart';
import 'partner_booking_detail_page.dart';

class PartnerBookingsPage extends ConsumerStatefulWidget {
  const PartnerBookingsPage({super.key});

  @override
  ConsumerState<PartnerBookingsPage> createState() => _PartnerBookingsPageState();
}

class _PartnerBookingsPageState extends ConsumerState<PartnerBookingsPage> {
  static const _bg = Color(0xFFF8FAFC);
  static const _chipIdleBg = Color(0xFFF7F4F4);
  static const _chipIdleText = Color(0xFF808080);
  static const _nameColor = Color(0xFF4E4E4E);
  static const _metaColor = Color(0xFF74767D);
  static const _declineColor = Color(0xFFFF383C);

  String _selectedFilter = 'pending';
  int _pendingCount = 0;

  final List<Map<String, String>> _filters = const [
    {'label': 'Pending', 'key': 'pending'},
    {'label': 'Confirmed', 'key': 'confirmed'},
    {'label': 'Completed', 'key': 'completed'},
    {'label': 'Cancelled', 'key': 'cancelled'},
    {'label': 'Home Services', 'key': 'home_services'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFilter('pending');
    });
  }

  Future<void> _loadFilter(String key) async {
    setState(() => _selectedFilter = key);
    final notifier = ref.read(partnerBookingsProvider.notifier);
    if (key == 'home_services') {
      await notifier.fetchBookings(status: 'all');
    } else {
      await notifier.fetchBookings(status: key);
    }
    if (!mounted) return;
    if (key == 'pending') {
      setState(() {
        _pendingCount = ref.read(partnerBookingsProvider).bookings.length;
      });
    }
  }

  List<BookingModel> _visibleBookings(List<BookingModel> bookings) {
    if (_selectedFilter != 'home_services') return bookings;
    return bookings.where((b) {
      final category =
          (b.service?.categoryName ?? b.service?.category ?? '').toLowerCase();
      final name = b.services.join(' ').toLowerCase();
      return category.contains('home') || name.contains('home');
    }).toList();
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed != null) {
      return DateFormat('EEE, d MMM').format(parsed);
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

  Future<void> _updateStatus(BookingModel booking, String status) async {
    final messenger = ScaffoldMessenger.of(context);
    final res = await ref
        .read(partnerBookingsProvider.notifier)
        .updateBookingStatus(booking.id, status);
    if (!mounted) return;
    if (res.success) {
      if (_selectedFilter == 'pending') {
        setState(() {
          _pendingCount = ref.read(partnerBookingsProvider).bookings.length;
        });
      } else if (booking.status.toUpperCase() == 'PENDING') {
        setState(() {
          _pendingCount = (_pendingCount - 1).clamp(0, 9999);
        });
      }
      messenger.showSnackBar(
        SnackBar(content: Text('Booking ${status.replaceAll('_', ' ')}')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Failed to update booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDecline(BookingModel booking) async {
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
      await _updateStatus(booking, 'cancelled');
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openDetail(BookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerBookingDetailPage(booking: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final bookingsState = ref.watch(partnerBookingsProvider);
    final bookings = _visibleBookings(bookingsState.bookings);

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
          'Bookings',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 33,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
              ),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final key = filter['key']!;
                final isSelected = _selectedFilter == key;
                final showBadge = key == 'pending' && _pendingCount > 0;

                return GestureDetector(
                  onTap: () => _loadFilter(key),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 24 : 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.transparent : _chipIdleBg,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(color: kPrimaryColor, width: 1)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter['label']!,
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? kPrimaryColor : _chipIdleText,
                          ),
                        ),
                        if (showBadge) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '$_pendingCount',
                              style: GoogleFonts.urbanist(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(8)),
          Expanded(
            child: bookingsState.isLoading
                ? const Center(child: LoadingAnimation(size: 36))
                : bookings.isEmpty
                    ? Center(
                        child: Text(
                          'No bookings found',
                          style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: kPrimaryColor,
                        onRefresh: () => _loadFilter(_selectedFilter),
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            screenSize.responsivePadding(24),
                            screenSize.responsivePadding(8),
                            screenSize.responsivePadding(24),
                            screenSize.responsivePadding(24),
                          ),
                          itemCount: bookings.length,
                          separatorBuilder: (_, _) => SizedBox(
                            height: screenSize.responsivePadding(12),
                          ),
                          itemBuilder: (context, index) {
                            return _buildBookingCard(bookings[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final customerName =
        booking.customer?.name ?? booking.customerDetails?.name ?? 'Customer';
    final serviceName = booking.services.isNotEmpty
        ? booking.services.join(', ')
        : (booking.service?.name ?? 'Service');
    final phone =
        booking.customer?.phone ?? booking.customerDetails?.phone ?? '';
    final dateFormatted = _formatDate(booking.bookingDate);
    final timeFormatted = _formatTime(booking.startTime);
    final dateTimeDisplay = [
      if (dateFormatted.isNotEmpty) dateFormatted,
      if (timeFormatted.isNotEmpty) timeFormatted,
    ].join(' • ');
    final status = booking.status.toUpperCase();
    final isPending = status == 'PENDING';
    final isConfirmed = status == 'CONFIRMED' || status == 'ACCEPTED';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          InteractiveFeedbackButton(
            onPressed: () => _openDetail(booking),
            scaleFactor: 0.99,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _nameColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  serviceName,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryColor,
                  ),
                ),
                if (dateTimeDisplay.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: _metaColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dateTimeDisplay,
                          style: GoogleFonts.urbanist(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: _metaColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 6),
            InteractiveFeedbackButton(
              onPressed: () => _callPhone(phone),
              scaleFactor: 0.99,
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: _metaColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    phone,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: _metaColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isPending || isConfirmed) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PillButton(
                    label: isPending ? 'Confirm' : 'Start',
                    filled: true,
                    color: kPrimaryColor,
                    onPressed: () {
                      _updateStatus(
                        booking,
                        isPending ? 'confirmed' : 'in_progress',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PillButton(
                    label: isPending ? 'Decline' : 'Cancel',
                    filled: false,
                    color: _declineColor,
                    onPressed: () => _handleDecline(booking),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool filled;
  final Color color;
  final VoidCallback onPressed;

  const _PillButton({
    required this.label,
    required this.filled,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveFeedbackButton(
      onPressed: onPressed,
      scaleFactor: 0.98,
      child: Container(
        height: 41,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: filled ? null : Border.all(color: color, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: filled ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
