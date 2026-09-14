import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/partner_bookings_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/primary_button.dart';

class PartnerBookingCalendarPage extends ConsumerStatefulWidget {
  const PartnerBookingCalendarPage({super.key});

  @override
  ConsumerState<PartnerBookingCalendarPage> createState() => _PartnerBookingCalendarPageState();
}

class _PartnerBookingCalendarPageState extends ConsumerState<PartnerBookingCalendarPage> {
  late DateTime _selectedDate;
  final List<DateTime> _dates = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 14; i++) {
      _dates.add(_selectedDate.add(Duration(days: i)));
    }
  }

  Future<void> _showBlockSlotDialog([BuildContext? _]) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final startController = TextEditingController(text: '14:00');
    final endController = TextEditingController(text: '15:00');
    final reasonController = TextEditingController(text: 'Maintenance / Staff break');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Block Slot', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startController,
              decoration: const InputDecoration(labelText: 'Start Time (HH:MM)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: endController,
              decoration: const InputDecoration(labelText: 'End Time (HH:MM)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Block Slot', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final res = await ref.read(partnerBookingsProvider.notifier).blockSlot({
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'startTime': startController.text.trim(),
      'endTime': endController.text.trim(),
      'reason': reasonController.text.trim(),
    });
    if (!mounted) return;
    if (res.success) {
      ref.invalidate(partnerBlockedSlotsProvider);
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Slot blocked successfully')));
    } else {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(res.message ?? 'Failed to block slot'), backgroundColor: Colors.red));
    }
  }

  void _showDelayDialog([BuildContext? ctx]) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final delayController = TextEditingController(text: '15');
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Broadcast Delay', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notify all upcoming booked customers on this day about a delay.',
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: delayController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Delay (in minutes)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (optional)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9500)),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Send Broadcast', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final minutes = int.tryParse(delayController.text.trim()) ?? 15;
    final res = await ref.read(partnerBookingsProvider.notifier).emergencyDelay(
          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
          delayMinutes: minutes,
          reason: reasonController.text.trim(),
        );
    if (!mounted) return;
    if (res.success) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Delay broadcasted to guests')));
    } else {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(res.message ?? 'Failed to broadcast delay'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final blockedSlotsAsync = ref.watch(partnerBlockedSlotsProvider);

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
          'Booking Calendar & Slots',
          style: kSubHeadingM.copyWith(
            color: const Color(0xFF373737),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_important_rounded, color: Color(0xFFFF9500)),
            tooltip: 'Broadcast Delay',
            onPressed: () => _showDelayDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenSize.responsivePadding(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date strip
              Text(
                'Select Date',
                style: kBodyTitleM.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
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
                        setState(() => _selectedDate = date);
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
              SizedBox(height: screenSize.responsivePadding(24)),

              // Block Slot action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Blocked Slots',
                    style: kBodyTitleM.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text('Block Slot', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
                    onPressed: () => _showBlockSlotDialog(context),
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(12)),

              blockedSlotsAsync.when(
                data: (blocked) {
                  final forDate = blocked.where((b) => b.date == formattedDate).toList();
                  if (forDate.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Center(
                        child: Text(
                          'No slots blocked for this date',
                          style: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: Color(0xFF6B7280)),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: forDate.length,
                    separatorBuilder: (_, _) => SizedBox(height: screenSize.responsivePadding(8)),
                    itemBuilder: (context, index) {
                      final b = forDate[index];
                      return Container(
                        padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${b.startTime} - ${b.endTime}',
                                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFBE123C)),
                                ),
                                if (b.reason != null)
                                  Text(
                                    b.reason!,
                                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF881337)),
                                  ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFBE123C)),
                              onPressed: () async {
                                final res = await ref.read(partnerBookingsProvider.notifier).unblockSlot({'slotId': b.id});
                                if (res.success) {
                                  ref.invalidate(partnerBlockedSlotsProvider);
                                }
                              },
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
              SizedBox(height: screenSize.responsivePadding(24)),

              // Broadcast delay card
              Container(
                padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time_filled_rounded, color: Color(0xFFD97706), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Schedule Delay Broadcast',
                          style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'If appointments are running late, broadcast an automatic delay notification to all upcoming booked guests.',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF78350F)),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      onPressed: () => _showDelayDialog(context),
                      width: double.infinity,
                      height: screenSize.responsivePadding(40),
                      text: 'Broadcast Delay (Push Notification)',
                      textSize: 13,
                      backgroundColor: const Color(0xFFD97706),
                      textColor: kWhite,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
