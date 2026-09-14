import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/models/service_model.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/loading_indicator.dart';
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

    final serviceIds = widget.services
        .map((s) => s.id ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    final res = await BookingService.createBooking(
      api: ref.read(apiProvider),
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
    final user = ref.watch(userProvider);
    final savings = widget.originalPrice - widget.totalPrice;

    // Fetch full shop data for logo/address fallback
    final ShopModel? fetchedShop = widget.partnerId.isNotEmpty
        ? ref.watch(getShopByPartnerIdProvider(widget.partnerId)).value
        : null;

    final String rawPartnerName = widget.partner.name ?? '';
    final String effectiveShopName = rawPartnerName.isNotEmpty &&
            rawPartnerName != 'SetGo Partner'
        ? rawPartnerName
        : (fetchedShop?.businessDetails?.businessName ??
            rawPartnerName.ifEmpty('Partner Store'));

    final String? rawPartnerLogo = widget.partner.logo;
    final String? effectiveShopLogo = (rawPartnerLogo != null &&
            rawPartnerLogo.isNotEmpty)
        ? rawPartnerLogo
        : (fetchedShop?.businessInfo?.businessLogo ??
            fetchedShop?.businessInfo?.coverImage);

    final rawPartnerAddress = [
      if (widget.partner.addressLine1 != null &&
          widget.partner.addressLine1!.isNotEmpty)
        widget.partner.addressLine1!,
      if (widget.partner.city != null && widget.partner.city!.isNotEmpty)
        widget.partner.city!,
    ].join(', ');
    final String effectiveShopAddress = rawPartnerAddress.isNotEmpty
        ? rawPartnerAddress
        : (fetchedShop?.businessDetails?.address ?? '');

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(widget.bookingDate);
    } catch (_) {
      parsedDate = DateTime.now();
    }
    final displayDate = DateFormat('EEEE, d MMM yyyy').format(parsedDate);

    final String servicesSummary = widget.services.isNotEmpty
        ? widget.services.map((s) => s.name).join(', ')
        : 'Service';
    final int totalDuration =
        widget.services.fold(0, (sum, s) => sum + s.totalTimeMinutes);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5F4),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF373737),
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking Summary',
          style: GoogleFonts.urbanist(
            color: const Color(0xFF373737),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
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
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16),
                  vertical: screenSize.responsivePadding(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Shop and Service Info Card (Figma shop-info-card 2158:3424)
                    _buildShopAndServiceCard(
                      screenSize: screenSize,
                      partnerName: effectiveShopName,
                      partnerLogo: effectiveShopLogo,
                      partnerAddress: effectiveShopAddress,
                      servicesSummary: servicesSummary,
                      totalDuration: totalDuration,
                    ),
                    SizedBox(height: screenSize.responsivePadding(16)),

                    // 2. Booking Details Card (Figma 2158:3437)
                    _buildBookingDetailsCard(
                      screenSize: screenSize,
                      servicesSummary: servicesSummary,
                      displayDate: displayDate,
                      slotTime: widget.selectedSlot.startTime,
                      savings: savings,
                      userName: user?.name,
                      userPhone: user?.phone,
                    ),
                    SizedBox(height: screenSize.responsivePadding(24)),
                  ],
                ),
              ),
            ),

            // 3. Bottom Sticky CTA Bar (Figma 2158:3464)
            _buildBottomBar(screenSize: screenSize),
          ],
        ),
      ),
    );
  }

  // Shop & Service Info Card
  Widget _buildShopAndServiceCard({
    required ScreenSizeData screenSize,
    required String partnerName,
    required String? partnerLogo,
    required String partnerAddress,
    required String servicesSummary,
    required int totalDuration,
  }) {
    final firstService =
        widget.services.isNotEmpty ? widget.services.first : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Partner Details Row
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                ),
                child: ClipOval(
                  child: (partnerLogo != null && partnerLogo.isNotEmpty)
                      ? AdvancedNetworkImage(
                          imageUrl: partnerLogo,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 26,
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 26,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partnerName,
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            partnerAddress.isNotEmpty
                                ? partnerAddress
                                : 'Partner Store',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              height: 1,
              color: const Color(0xFFF3F4F6),
            ),
          ),

          // Service Title
          Text(
            servicesSummary,
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (firstService?.description != null &&
              firstService!.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              firstService.description!.trim(),
              style: GoogleFonts.urbanist(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '₹${widget.totalPrice.toInt()}',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF07838C),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$totalDuration mins total',
                  style: GoogleFonts.urbanist(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Booking Details Card
  Widget _buildBookingDetailsCard({
    required ScreenSizeData screenSize,
    required String servicesSummary,
    required String displayDate,
    required String slotTime,
    required double savings,
    required String? userName,
    required String? userPhone,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: EdgeInsets.all(screenSize.responsivePadding(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Appointment Details
          _buildDetailRow(
            label: 'Service',
            value: servicesSummary,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            label: 'Date',
            value: displayDate,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            label: 'Time',
            value: slotTime,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(
              height: 1,
              color: const Color(0xFFEDEDED),
            ),
          ),

          // Section 2: Pricing & Payment
          _buildDetailRow(
            label: 'Service Fee',
            value: '₹${widget.totalPrice.toInt()}',
            isValueBold: true,
          ),
          if (savings > 0) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              label: 'Offer Discount',
              value: '- ₹${savings.toInt()}',
              valueColor: const Color(0xFF07982C),
              isValueBold: true,
            ),
          ],
          const SizedBox(height: 10),
          _buildDetailRow(
            label: 'Payment Mode',
            value: 'Pay at Venue',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(
              height: 1,
              color: const Color(0xFFEDEDED),
            ),
          ),

          // Section 3: Customer Details
          _buildDetailRow(
            label: 'Name',
            value: (userName != null && userName.isNotEmpty)
                ? userName
                : 'Customer',
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            label: 'Phone',
            value: (userPhone != null && userPhone.isNotEmpty)
                ? userPhone
                : 'Not provided',
          ),

          // Optional Notes
          if (widget.notes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(
                height: 1,
                color: const Color(0xFFEDEDED),
              ),
            ),
            _buildDetailRow(
              label: 'Notes',
              value: widget.notes,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isValueBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF808080),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: isValueBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? const Color(0xFF1C1C1C),
            ),
          ),
        ),
      ],
    );
  }

  // Bottom Sticky CTA Bar
  Widget _buildBottomBar({required ScreenSizeData screenSize}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        screenSize.responsivePadding(16),
        screenSize.responsivePadding(10),
        screenSize.responsivePadding(16),
        screenSize.responsivePadding(16),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleConfirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6155F5),
              disabledBackgroundColor: const Color(0xFF6155F5).withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const LoadingAnimation(size: 24, loadingColor: Colors.white)
                : Text(
                    'Confirm Booking',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
