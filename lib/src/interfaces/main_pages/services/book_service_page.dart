import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../data/models/service_model.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/advanced_network_image.dart';
import '../../components/loading_indicator.dart';
import 'booking_summary_page.dart';

class BookServicePage extends ConsumerStatefulWidget {
  final ServiceModel service;

  const BookServicePage({super.key, required this.service});

  @override
  ConsumerState<BookServicePage> createState() => _BookServicePageState();
}

class _BookServicePageState extends ConsumerState<BookServicePage> {
  late DateTime _selectedDate;
  late DateTime _viewMonth;
  final Set<String> _selectedServiceIds = {};
  final List<ServiceModel> _selectedServices = [];
  TimeSlotModel? _selectedSlot;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _viewMonth = DateTime(now.year, now.month, 1);

    if (widget.service.id != null && widget.service.id!.isNotEmpty) {
      _selectedServiceIds.add(widget.service.id!);
    }
    _selectedServices.add(widget.service);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _totalDuration =>
      _selectedServices.fold(0, (sum, s) => sum + s.totalTimeMinutes);
  double get _totalPrice =>
      _selectedServices.fold(0.0, (sum, s) => sum + s.effectivePrice);
  double get _originalPrice =>
      _selectedServices.fold(0.0, (sum, s) => sum + s.originalPrice);

  void _onPrevMonth() {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final prevMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    if (!prevMonth.isBefore(currentMonthStart)) {
      setState(() {
        _viewMonth = prevMonth;
      });
    }
  }

  void _onNextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final partner = widget.service.partner;
    final partnerId = widget.service.partnerId ?? partner?.id ?? '';
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Fetch full shop data if available to get address/logo fallback
    final ShopModel? fetchedShop = partnerId.isNotEmpty
        ? ref.watch(getShopByPartnerIdProvider(partnerId)).value
        : null;

    final String rawPartnerName = partner?.name ?? '';
    final String effectiveShopName = rawPartnerName.isNotEmpty &&
            rawPartnerName != 'SetGo Partner'
        ? rawPartnerName
        : (fetchedShop?.businessDetails?.businessName ??
            rawPartnerName.ifEmpty('Partner Store'));

    final String? rawPartnerLogo = partner?.logo;
    final String? effectiveShopLogo = (rawPartnerLogo != null &&
            rawPartnerLogo.isNotEmpty)
        ? rawPartnerLogo
        : (fetchedShop?.businessInfo?.businessLogo ??
            fetchedShop?.businessInfo?.coverImage);

    final rawPartnerAddress = [
      if (partner?.addressLine1 != null && partner!.addressLine1!.isNotEmpty)
        partner.addressLine1!,
      if (partner?.city != null && partner!.city!.isNotEmpty) partner.city!,
    ].join(', ');
    final String effectiveShopAddress = rawPartnerAddress.isNotEmpty
        ? rawPartnerAddress
        : (fetchedShop?.businessDetails?.address ?? '');

    final storeServicesAsync = partnerId.isNotEmpty
        ? ref.watch(storeServicesProvider(partnerId))
        : const AsyncValue.data(<ServiceModel>[]);

    final selectedServiceIds = _selectedServiceIds.isNotEmpty
        ? _selectedServiceIds.toList()
        : [
            if (widget.service.id != null && widget.service.id!.isNotEmpty)
              widget.service.id!,
          ];
    // Stable, sorted key so Riverpod family does not refetch every rebuild.
    final serviceIdsKey = (List<String>.from(selectedServiceIds)..sort()).join(',');

    final slotsAsync = partnerId.isNotEmpty
        ? ref.watch(bookingSlotsProvider((
            serviceIds: serviceIdsKey,
            partnerId: partnerId,
            date: formattedDate,
          )))
        : const AsyncValue<SlotsResponseModel?>.data(null);

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
          'Booking',
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
                    // Shop & Service Info Card (Figma shop-info-card 2158:3269)
                    _buildShopAndServiceCard(
                      screenSize: screenSize,
                      partnerName: effectiveShopName,
                      partnerLogo: effectiveShopLogo,
                      partnerAddress: effectiveShopAddress,
                    ),
                    SizedBox(height: screenSize.responsivePadding(16)),

                    // Select Date Section with Monthly Calendar Grid (Figma 2158:3284)
                    _buildDateSelectionCard(screenSize: screenSize),
                    SizedBox(height: screenSize.responsivePadding(16)),

                    // Available Time Slots Section (Figma 2158:3378)
                    _buildAvailableSlotsSection(
                      screenSize: screenSize,
                      slotsAsync: slotsAsync,
                    ),
                    SizedBox(height: screenSize.responsivePadding(16)),

                    // Services & Add-ons (Existing app feature)
                    _buildServicesAndAddOnsSection(
                      screenSize: screenSize,
                      storeServicesAsync: storeServicesAsync,
                    ),
                    SizedBox(height: screenSize.responsivePadding(16)),

                    // Special Instructions / Notes (Existing app feature)
                    _buildSpecialNotesSection(screenSize: screenSize),
                    SizedBox(height: screenSize.responsivePadding(24)),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA Bar (Figma 2158:3395)
            _buildStickyBottomBar(
              screenSize: screenSize,
              partner: partner,
              partnerId: partnerId,
              formattedDate: formattedDate,
            ),
          ],
        ),
      ),
    );
  }

  // 1. Shop and Service Info Card
  Widget _buildShopAndServiceCard({
    required ScreenSizeData screenSize,
    required String partnerName,
    required String? partnerLogo,
    required String partnerAddress,
  }) {
    final service = widget.service;
    final displayPrice = service.hasOffer && service.offerPrice != null
        ? (service.offerPrice!.truncateToDouble() == service.offerPrice
            ? service.offerPrice!.toStringAsFixed(0)
            : service.offerPrice!.toStringAsFixed(2))
        : (service.originalPrice.truncateToDouble() == service.originalPrice
            ? service.originalPrice.toStringAsFixed(0)
            : service.originalPrice.toStringAsFixed(2));

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

          // Service Title & Details
          Text(
            service.name,
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (service.description != null &&
              service.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              service.description!.trim(),
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
                '₹$displayPrice',
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
                  '${service.totalTimeMinutes} mins',
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

  // 2. Monthly Calendar Grid Date Selection Card
  Widget _buildDateSelectionCard({required ScreenSizeData screenSize}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthTitle = DateFormat('MMMM yyyy').format(_viewMonth);

    // Days in current view month
    final firstDayOfMonth = DateTime(_viewMonth.year, _viewMonth.month, 1);
    final daysInMonth =
        DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    // Monday is 1, Sunday is 7 -> offset 0 to 6
    final startOffset = firstDayOfMonth.weekday - 1;

    final canGoPrev = !_viewMonth.isBefore(DateTime(now.year, now.month, 1));
    const weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          padding: EdgeInsets.all(screenSize.responsivePadding(16)),
          child: Column(
            children: [
              // Month Header with Chevrons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthTitle,
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C1C1C),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          size: 22,
                          color: canGoPrev
                              ? const Color(0xFF4E4E4E)
                              : const Color(0xFFD1D5DB),
                        ),
                        onPressed: canGoPrev ? _onPrevMonth : null,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: Color(0xFF4E4E4E),
                        ),
                        onPressed: _onNextMonth,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Weekday Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekdays.map((day) {
                  return SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        day,
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF74767D),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Calendar Grid (7 columns)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: startOffset + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  if (index < startOffset) {
                    return const SizedBox.shrink();
                  }

                  final dayNum = index - startOffset + 1;
                  final cellDate =
                      DateTime(_viewMonth.year, _viewMonth.month, dayNum);
                  final isPast = cellDate.isBefore(today);
                  final isSelected = cellDate.year == _selectedDate.year &&
                      cellDate.month == _selectedDate.month &&
                      cellDate.day == _selectedDate.day;

                  return Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isPast
                            ? null
                            : () {
                                setState(() {
                                  _selectedDate = cellDate;
                                  _selectedSlot = null;
                                });
                              },
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFF07982C)
                                : Colors.transparent,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNum',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isPast
                                      ? const Color(0xFFD1D5DB)
                                      : const Color(0xFF4E4E4E)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bookable slots only — respects backend `available`/`isPast` and drops
  /// any times already passed on the device (guards server TZ drift).
  List<TimeSlotModel> _visibleSlots(List<TimeSlotModel> slots) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final isToday = selectedDay == today;
    final nowMins = now.hour * 60 + now.minute;

    return slots.where((slot) {
      if (!slot.isBookable) return false;
      if (!isToday) return true;

      final parts = slot.startTime.split(':');
      if (parts.length < 2) return true;
      final slotMins =
          (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
      return slotMins > nowMins;
    }).toList();
  }

  // 3. Available Slots Section
  Widget _buildAvailableSlotsSection({
    required ScreenSizeData screenSize,
    required AsyncValue<SlotsResponseModel?> slotsAsync,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Slots',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          padding: EdgeInsets.all(screenSize.responsivePadding(16)),
          child: slotsAsync.when(
            data: (slotsData) {
              if (slotsData == null || !slotsData.isPartnerOpen) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'Store is closed on this date. Please choose another date.',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final slots = _visibleSlots(slotsData.slots);

              // Drop a stale selection if it disappeared after refresh/filter.
              if (_selectedSlot != null &&
                  !slots.any((s) => s.startTime == _selectedSlot!.startTime)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => _selectedSlot = null);
                });
              }

              if (slots.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No available slots for this date.',
                      style: GoogleFonts.urbanist(
                        color: const Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: slots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.8,
                ),
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  final isSelected =
                      _selectedSlot?.startTime == slot.startTime;

                  return InteractiveFeedbackButton(
                    onPressed: () {
                      setState(() {
                        _selectedSlot = slot;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF07982C)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF07982C)
                              : const Color(0xFFEDEDED),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        slot.startTime,
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1C1C1C),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: LoadingAnimation(
                  size: 32,
                  loadingColor: Color(0xFF07838C),
                ),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Failed to load slots. Please try again.',
                  style: GoogleFonts.urbanist(
                    color: const Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 4. Services and Add-ons Section
  Widget _buildServicesAndAddOnsSection({
    required ScreenSizeData screenSize,
    required AsyncValue<List<ServiceModel>> storeServicesAsync,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services & Add-ons',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 10),
        storeServicesAsync.when(
          data: (storeServices) {
            final servicesToDisplay = storeServices.isNotEmpty
                ? storeServices
                : [widget.service];

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: servicesToDisplay.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = servicesToDisplay[index];
                final isChecked = _selectedServiceIds.contains(s.id ?? '');

                void toggleService() {
                  setState(() {
                    if (!isChecked) {
                      _selectedServiceIds.add(s.id ?? '');
                      if (!_selectedServices.any((item) => item.id == s.id)) {
                        _selectedServices.add(s);
                      }
                    } else {
                      if (_selectedServiceIds.length > 1) {
                        _selectedServiceIds.remove(s.id ?? '');
                        _selectedServices.removeWhere((item) => item.id == s.id);
                      }
                    }
                    _selectedSlot = null;
                  });
                }

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: toggleService,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isChecked
                              ? const Color(0xFF07838C)
                              : const Color(0xFFE5E7EB),
                          width: isChecked ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: const Color(0xFF07838C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) => toggleService(),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${s.totalTimeMinutes} mins • ${s.categoryName ?? s.category ?? "Service"}',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${s.effectivePrice.toInt()}',
                            style: GoogleFonts.urbanist(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF07838C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: LoadingAnimation(
                size: 28,
                loadingColor: Color(0xFF07838C),
              ),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  // 5. Special Instructions Section
  Widget _buildSpecialNotesSection({required ScreenSizeData screenSize}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Instructions (Optional)',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 2,
            style: GoogleFonts.urbanist(
              fontSize: 13,
              color: const Color(0xFF111827),
            ),
            decoration: InputDecoration(
              hintText:
                  'Add notes for the staff (e.g. preferred stylist, quiet service)...',
              hintStyle: GoogleFonts.urbanist(
                fontSize: 13,
                color: const Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(screenSize.responsivePadding(14)),
            ),
          ),
        ),
      ],
    );
  }

  // 6. Sticky Bottom CTA Bar
  Widget _buildStickyBottomBar({
    required ScreenSizeData screenSize,
    required ServicePartnerModel? partner,
    required String partnerId,
    required String formattedDate,
  }) {
    final bool canContinue = _selectedSlot != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        screenSize.responsivePadding(16),
        screenSize.responsivePadding(12),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${_totalPrice.toInt()}',
                    style: GoogleFonts.urbanist(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    '$_totalDuration mins total',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 52,
              width: screenSize.responsivePadding(180),
              child: ElevatedButton(
                onPressed: canContinue
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingSummaryPage(
                              partner: partner ??
                                  widget.service.partner ??
                                  const ServicePartnerModel(name: 'Store'),
                              partnerId: partnerId,
                              services: _selectedServices,
                              bookingDate: formattedDate,
                              selectedSlot: _selectedSlot!,
                              notes: _notesController.text.trim(),
                              totalPrice: _totalPrice,
                              originalPrice: _originalPrice,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6155F5),
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

