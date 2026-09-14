import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';
import 'my_bookings_page.dart';

class BookingConfirmedPage extends ConsumerWidget {
  final BookingModel booking;

  const BookingConfirmedPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final token = booking.tokenNumber;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F4),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(screenSize.responsivePadding(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Green Success Circle
                Container(
                  width: screenSize.responsivePadding(80),
                  height: screenSize.responsivePadding(80),
                  decoration: const BoxDecoration(
                    color: Color(0xFF34C759),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: kWhite,
                      size: 48,
                    ),
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(20)),
                Text(
                  'Booking Confirmed!',
                  style: kSubHeadingL.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(6)),
                Text(
                  'Your appointment has been successfully scheduled.',
                  style: kSmallerTitleL.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenSize.responsivePadding(24)),

                // Token Badge Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenSize.responsivePadding(20)),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'YOUR TOKEN NUMBER',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: screenSize.responsivePadding(6)),
                      Text(
                        token,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Divider(height: 24, color: Color(0xFFE5E7EB)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Date & Time', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                          Text(
                            '${booking.bookingDate} • ${booking.startTime}',
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (booking.partner?.name != null) ...[
                        SizedBox(height: screenSize.responsivePadding(8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Partner Store', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                            Text(
                              booking.partner!.name!,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),

                // Actions
                PrimaryButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyBookingsPage(),
                      ),
                    );
                  },
                  width: double.infinity,
                  height: screenSize.responsivePadding(48),
                  text: 'View My Bookings',
                  textSize: 15,
                  backgroundColor: kPrimaryColor,
                  textColor: kWhite,
                ),
                SizedBox(height: screenSize.responsivePadding(10)),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
