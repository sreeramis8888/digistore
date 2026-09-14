import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/partner_bookings_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/date_formatter.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../main_pages/partner/partner_booking_detail_page.dart';
import '../../main_pages/partner/partner_bookings_page.dart';

class PartnerBookingRequests extends ConsumerWidget {
  final ScreenSizeData screenSize;

  const PartnerBookingRequests({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(partnerHomeBookingRequestsProvider);

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) return const SizedBox.shrink();
        return _buildSection(context, bookings);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSection(BuildContext context, List<BookingModel> bookings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking Requests',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PartnerBookingsPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6154F5),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF6154F5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        CarouselSlider.builder(
          itemCount: bookings.length,
          options: CarouselOptions(
            height: screenSize.responsivePadding(123),
            viewportFraction: 0.62,
            enableInfiniteScroll: false,
            padEnds: false,
          ),
          itemBuilder: (context, index, realIndex) {
            final padding = screenSize.responsivePadding(16);
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? padding : 6,
                right: index == bookings.length - 1 ? padding : 6,
              ),
              child: _buildBookingCard(context, bookings[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    final serviceTitle = booking.services.isNotEmpty
        ? booking.services.first
        : (booking.service?.name ?? 'Service Booking');

    final customerName = booking.customer?.name ??
        booking.customerDetails?.name ??
        'Customer';

    String formattedDateStr = '';
    if (booking.date.isNotEmpty) {
      final parsed = DateTime.tryParse(booking.date);
      if (parsed != null) {
        formattedDateStr = formatDate(parsed);
      } else {
        formattedDateStr = booking.date;
      }
    }
    final dateTimeStr = [
      if (formattedDateStr.isNotEmpty) formattedDateStr,
      if (booking.timeSlot.isNotEmpty) booking.timeSlot,
    ].join(' • ');

    final status = booking.status.toUpperCase();
    Color statusBgColor = const Color(0xFFFFF6EE);
    Color statusTextColor = const Color(0xFFFF8D28);
    String displayStatus = 'Pending';

    if (status == 'CONFIRMED' || status == 'ACCEPTED') {
      statusBgColor = const Color(0xFFE6F7EE);
      statusTextColor = const Color(0xFF10B981);
      displayStatus = 'Confirmed';
    } else if (status == 'COMPLETED') {
      statusBgColor = const Color(0xFFEEF2FF);
      statusTextColor = const Color(0xFF6155F5);
      displayStatus = 'Completed';
    } else if (status == 'CANCELLED' || status == 'REJECTED') {
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFEF4444);
      displayStatus = 'Cancelled';
    }

    return InteractiveFeedbackButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerBookingDetailPage(booking: booking),
          ),
        );
      },
      scaleFactor: 0.98,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceTitle,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  customerName,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF202020),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (dateTimeStr.isNotEmpty)
              Text(
                dateTimeStr,
                style: GoogleFonts.urbanist(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayStatus,
                style: GoogleFonts.urbanist(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: statusTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
