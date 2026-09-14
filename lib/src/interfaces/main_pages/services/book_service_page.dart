import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/advanced_network_image.dart';
import '../../components/primary_button.dart';
import 'booking_summary_page.dart';

class BookServicePage extends ConsumerStatefulWidget {
  final ServiceModel service;

  const BookServicePage({super.key, required this.service});

  @override
  ConsumerState<BookServicePage> createState() => _BookServicePageState();
}

class _BookServicePageState extends ConsumerState<BookServicePage> {
  late DateTime _selectedDate;
  final List<DateTime> _dates = [];
  final Set<String> _selectedServiceIds = {};
  final List<ServiceModel> _selectedServices = [];
  TimeSlotModel? _selectedSlot;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 14; i++) {
      _dates.add(_selectedDate.add(Duration(days: i)));
    }
    _selectedServiceIds.add(widget.service.id ?? '');
    _selectedServices.add(widget.service);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _totalDuration => _selectedServices.fold(0, (sum, s) => sum + s.totalTimeMinutes);
  double get _totalPrice => _selectedServices.fold(0.0, (sum, s) => sum + s.effectivePrice);
  double get _originalPrice => _selectedServices.fold(0.0, (sum, s) => sum + s.originalPrice);

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final partner = widget.service.partner;
    final partnerId = widget.service.partnerId ?? partner?.id ?? '';
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final storeServicesAsync = partnerId.isNotEmpty
        ? ref.watch(storeServicesProvider(partnerId))
        : const AsyncValue.data(<ServiceModel>[]);

    final slotsParams = {
      'partnerId': partnerId,
      'date': formattedDate,
      'serviceIds': _selectedServiceIds.toList(),
    };

    final slotsAsync = partnerId.isNotEmpty
        ? ref.watch(bookingSlotsFamily(slotsParams))
        : const AsyncValue<SlotsResponseModel?>.data(null);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF373737),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Service',
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
                    // Shop Info Card
                    if (partner != null) ...[
                      Container(
                        padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: screenSize.responsivePadding(54),
                                height: screenSize.responsivePadding(54),
                                child: AdvancedNetworkImage(
                                  imageUrl: partner.logo ?? '',
                                  fit: BoxFit.cover,
                                  errorWidget: Container(
                                    color: const Color(0xFFF3F4F6),
                                    child: const Icon(
                                      Icons.storefront_rounded,
                                      color: Color(0xFF9CA3AF),
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: screenSize.responsivePadding(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    partner.name ?? 'Shop',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: screenSize.responsivePadding(2)),
                                  Text(
                                    partner.addressLine1 ?? partner.category ?? 'Partner Store',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9E6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    partner.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFCB2B)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenSize.responsivePadding(16)),
                    ],

                    // Date Selection Header
                    Text(
                      'Select Date',
                      style: kBodyTitleM.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(10)),
                    SizedBox(
                      height: screenSize.responsivePadding(70),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _dates.length,
                        itemBuilder: (context, index) {
                          final date = _dates[index];
                          final isSelected = DateFormat('yyyy-MM-dd').format(date) == formattedDate;

                          return InteractiveFeedbackButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = date;
                                _selectedSlot = null;
                              });
                            },
                            child: Container(
                              width: screenSize.responsivePadding(54),
                              margin: EdgeInsets.only(right: screenSize.responsivePadding(8)),
                              decoration: BoxDecoration(
                                color: isSelected ? kPrimaryColor : kWhite,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? kPrimaryColor : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('E').format(date).toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? kWhite.withValues(alpha: 0.9) : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  SizedBox(height: screenSize.responsivePadding(4)),
                                  Text(
                                    DateFormat('d').format(date),
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? kWhite : const Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(20)),

                    // Services & Add-ons
                    Text(
                      'Services & Add-ons',
                      style: kBodyTitleM.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(10)),
                    storeServicesAsync.when(
                      data: (storeServices) {
                        final servicesToDisplay = storeServices.isNotEmpty
                            ? storeServices
                            : [widget.service];

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: servicesToDisplay.length,
                          separatorBuilder: (_, _) => SizedBox(height: screenSize.responsivePadding(8)),
                          itemBuilder: (context, index) {
                            final s = servicesToDisplay[index];
                            final isChecked = _selectedServiceIds.contains(s.id ?? '');

                            return Container(
                              padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                              decoration: BoxDecoration(
                                color: kWhite,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isChecked ? kPrimaryColor : const Color(0xFFE5E7EB),
                                  width: isChecked ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    activeColor: kPrimaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
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
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.name,
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        Text(
                                          '${s.totalTimeMinutes} mins • ${s.category ?? "Service"}',
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹ ${s.effectivePrice.toInt()}',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    SizedBox(height: screenSize.responsivePadding(20)),

                    // Available Time Slots
                    Text(
                      'Select Time Slot',
                      style: kBodyTitleM.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(10)),
                    slotsAsync.when(
                      data: (slotsData) {
                        if (slotsData == null || !slotsData.isPartnerOpen) {
                          return Container(
                            padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Store is closed on this date. Please choose another date.',
                                style: TextStyle(color: Color(0xFF6B7280)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final slots = slotsData.slots;
                        if (slots.isEmpty) {
                          return Container(
                            padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'No available slots for this date.',
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),
                            ),
                          );
                        }

                        return Wrap(
                          spacing: screenSize.responsivePadding(8),
                          runSpacing: screenSize.responsivePadding(8),
                          children: slots.map((slot) {
                            final isSelected = _selectedSlot?.startTime == slot.startTime;
                            final isAvailable = slot.available;

                            return InteractiveFeedbackButton(
                              onPressed: isAvailable
                                  ? () {
                                      setState(() {
                                        _selectedSlot = slot;
                                      });
                                    }
                                  : () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.responsivePadding(14),
                                  vertical: screenSize.responsivePadding(10),
                                ),
                                decoration: BoxDecoration(
                                  color: !isAvailable
                                      ? const Color(0xFFF3F4F6)
                                      : isSelected
                                          ? kPrimaryColor
                                          : kWhite,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !isAvailable
                                        ? const Color(0xFFE5E7EB)
                                        : isSelected
                                            ? kPrimaryColor
                                            : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Text(
                                  slot.startTime,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: !isAvailable
                                        ? const Color(0xFF9CA3AF)
                                        : isSelected
                                            ? kWhite
                                            : const Color(0xFF111827),
                                    decoration: !isAvailable ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, _) => Container(
                        padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Failed to load slots for this date'),
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(20)),

                    // Special Notes
                    Text(
                      'Special Instructions (Optional)',
                      style: kBodyTitleM.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(8)),
                    Container(
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Add notes for the staff (e.g. preferred stylist, quiet service)...',
                          hintStyle: kSmallerTitleM.copyWith(color: const Color(0xFF9CA3AF)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(screenSize.responsivePadding(12)),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(30)),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹ ${_totalPrice.toInt()}',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          '$_totalDuration mins total',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PrimaryButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingSummaryPage(
                            partner: partner ?? widget.service.partner ?? const ServicePartnerModel(name: 'Store'),
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
                    },
                    isEnabled: _selectedSlot != null,
                    width: screenSize.responsivePadding(180),
                    height: screenSize.responsivePadding(46),
                    text: 'Continue',
                    textSize: 15,
                    backgroundColor: _selectedSlot == null ? const Color(0xFF9CA3AF) : kPrimaryColor,
                    textColor: kWhite,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
