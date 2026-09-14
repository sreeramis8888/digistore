import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/partner_bookings_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/services/snackbar_service.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/confirmation_dialog.dart';
import '../../components/loading_indicator.dart';

class PartnerBookingCalendarPage extends ConsumerStatefulWidget {
  const PartnerBookingCalendarPage({super.key});

  @override
  ConsumerState<PartnerBookingCalendarPage> createState() =>
      _PartnerBookingCalendarPageState();
}

class _PartnerBookingCalendarPageState
    extends ConsumerState<PartnerBookingCalendarPage> {
  static const _bg = Color(0xFFF8FAFC);
  static const _cardBorder = Color(0xFFE5E9F1);
  static const _labelColor = Color(0xFF74767D);
  static const _valueColor = Color(0xFF4E4E4E);

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

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> _showBlockSlotSheet() async {
    TimeOfDay start = const TimeOfDay(hour: 14, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 15, minute: 0);
    final reasonController =
        TextEditingController(text: 'Maintenance / Staff break');
    final snackbar = SnackbarService();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> pickTime({required bool isStart}) async {
              final picked = await showTimePicker(
                context: ctx,
                initialTime: isStart ? start : end,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: kPrimaryColor,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: _valueColor,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked == null) return;
              setSheetState(() {
                if (isStart) {
                  start = picked;
                } else {
                  end = picked;
                }
              });
            }

            String formatTod(TimeOfDay t) =>
                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

            return _SheetScaffold(
              title: 'Block Slot',
              subtitle:
                  'Block a time range on ${DateFormat('EEE, d MMM').format(_selectedDate)} so customers cannot book it.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _TimeField(
                          label: 'Start',
                          value: formatTod(start),
                          onTap: () => pickTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeField(
                          label: 'End',
                          value: formatTod(end),
                          onTap: () => pickTime(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: 'Reason',
                    controller: reasonController,
                    hint: 'Why is this slot blocked?',
                  ),
                ],
              ),
              primaryLabel: 'Block Slot',
              onPrimary: () => Navigator.pop(ctx, true),
              onCancel: () => Navigator.pop(ctx, false),
            );
          },
        );
      },
    );

    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (confirmed != true || !mounted) return;

    String formatTod(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final res = await ref.read(partnerBookingsProvider.notifier).blockSlot({
      'date': _formattedDate,
      'startTime': formatTod(start),
      'endTime': formatTod(end),
      'reason': reason,
    });
    if (!mounted) return;
    if (res.success) {
      ref.invalidate(partnerBlockedSlotsProvider);
      snackbar.showSnackBar(context, 'Slot blocked successfully');
    } else {
      snackbar.showSnackBar(
        context,
        res.message ?? 'Failed to block slot',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> _showDelaySheet() async {
    final delayController = TextEditingController(text: '15');
    final reasonController = TextEditingController();
    final snackbar = SnackbarService();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _SheetScaffold(
          title: 'Broadcast Delay',
          subtitle:
              'Notify all upcoming customers booked on ${DateFormat('EEE, d MMM').format(_selectedDate)} that you are running late.',
          icon: Icons.campaign_rounded,
          iconColor: const Color(0xFFFF8D28),
          iconBg: const Color(0xFFFFF3E9),
          child: Column(
            children: [
              _LabeledField(
                label: 'Delay (minutes)',
                controller: delayController,
                hint: 'e.g. 15',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: 'Reason (optional)',
                controller: reasonController,
                hint: 'Share a short note with guests',
                maxLines: 3,
              ),
            ],
          ),
          primaryLabel: 'Send Broadcast',
          primaryColor: const Color(0xFFFF8D28),
          onPrimary: () => Navigator.pop(ctx, true),
          onCancel: () => Navigator.pop(ctx, false),
        );
      },
    );

    final minutes = int.tryParse(delayController.text.trim()) ?? 15;
    final reason = reasonController.text.trim();
    delayController.dispose();
    reasonController.dispose();
    if (confirmed != true || !mounted) return;

    final res = await ref.read(partnerBookingsProvider.notifier).emergencyDelay(
          date: _formattedDate,
          delayMinutes: minutes,
          reason: reason,
        );
    if (!mounted) return;
    if (res.success) {
      snackbar.showSnackBar(context, 'Delay broadcasted to guests');
    } else {
      snackbar.showSnackBar(
        context,
        res.message ?? 'Failed to broadcast delay',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> _unblockSlot(BlockedSlotModel slot) async {
    final snackbar = SnackbarService();
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Unblock Slot',
      message:
          'Remove the block for ${slot.startTime} – ${slot.endTime}? Customers will be able to book this time again.',
      confirmText: 'Unblock',
      cancelText: 'Keep Blocked',
      icon: Icons.lock_open_rounded,
    );
    if (confirmed != true || !mounted) return;

    final res = await ref
        .read(partnerBookingsProvider.notifier)
        .unblockSlot({'slotId': slot.id});
    if (!mounted) return;
    if (res.success) {
      ref.invalidate(partnerBlockedSlotsProvider);
      snackbar.showSnackBar(context, 'Slot unblocked');
    } else {
      snackbar.showSnackBar(
        context,
        res.message ?? 'Failed to unblock slot',
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final blockedSlotsAsync = ref.watch(partnerBlockedSlotsProvider);

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
          'Slot Calendar',
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
        actions: [
          IconButton(
            tooltip: 'Broadcast Delay',
            icon: const Icon(
              Icons.campaign_rounded,
              color: Color(0xFFFF8D28),
              size: 24,
            ),
            onPressed: _showDelaySheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: kPrimaryColor,
        onRefresh: () async {
          ref.invalidate(partnerBlockedSlotsProvider);
          await ref.read(partnerBlockedSlotsProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            screenSize.responsivePadding(24),
            screenSize.responsivePadding(8),
            screenSize.responsivePadding(24),
            screenSize.responsivePadding(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _valueColor,
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(12)),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _dates.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final date = _dates[index];
                    final isSelected =
                        DateFormat('yyyy-MM-dd').format(date) == _formattedDate;
                    final isToday = DateFormat('yyyy-MM-dd').format(date) ==
                        DateFormat('yyyy-MM-dd').format(DateTime.now());

                    return InteractiveFeedbackButton(
                      onPressed: () => setState(() => _selectedDate = date),
                      scaleFactor: 0.96,
                      child: Container(
                        width: 56,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? kPrimaryColor
                                : (isToday
                                    ? kPrimaryColor.withValues(alpha: 0.35)
                                    : _cardBorder),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: kPrimaryColor.withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date).toUpperCase(),
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : _labelColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d').format(date),
                              style: GoogleFonts.urbanist(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : _valueColor,
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

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Blocked Slots',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _valueColor,
                      ),
                    ),
                  ),
                  InteractiveFeedbackButton(
                    onPressed: _showBlockSlotSheet,
                    scaleFactor: 0.96,
                    child: Container(
                      height: 33,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Block Slot',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM').format(_selectedDate),
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: _labelColor,
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(12)),

              blockedSlotsAsync.when(
                data: (blocked) {
                  final forDate =
                      blocked.where((b) => b.date == _formattedDate).toList();
                  if (forDate.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.event_available_rounded,
                              color: kPrimaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No blocked slots',
                            style: GoogleFonts.urbanist(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _valueColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All times are open for bookings on this day.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: _labelColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      for (int i = 0; i < forDate.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _BlockedSlotCard(
                          slot: forDate[i],
                          onUnblock: () => _unblockSlot(forDate[i]),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: LoadingAnimation(size: 36)),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),

              SizedBox(height: screenSize.responsivePadding(24)),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
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
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.campaign_rounded,
                            color: Color(0xFFFF8D28),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Broadcast Delay',
                                style: GoogleFonts.urbanist(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _valueColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Running late? Notify today’s guests.',
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: _labelColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Send a push notification to all upcoming booked customers for the selected date.',
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: _labelColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InteractiveFeedbackButton(
                      onPressed: _showDelaySheet,
                      scaleFactor: 0.98,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8D28),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Broadcast Delay',
                          style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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
    );
  }
}

class _BlockedSlotCard extends StatelessWidget {
  final BlockedSlotModel slot;
  final VoidCallback onUnblock;

  const _BlockedSlotCard({
    required this.slot,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.block_rounded,
              color: Color(0xFFFF383C),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.startTime} – ${slot.endTime}',
                  style: GoogleFonts.urbanist(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4E4E4E),
                  ),
                ),
                if (slot.reason != null && slot.reason!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    slot.reason!,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF74767D),
                    ),
                  ),
                ],
              ],
            ),
          ),
          InteractiveFeedbackButton(
            onPressed: onUnblock,
            scaleFactor: 0.94,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFFF383C),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onCancel;
  final Color primaryColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _SheetScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onCancel,
    this.primaryColor = kPrimaryColor,
    this.icon = Icons.event_busy_rounded,
    this.iconColor = kPrimaryColor,
    this.iconBg = const Color(0xFFEEF2FF),
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E9F1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4E4E4E),
                        ),
                      ),
                    ),
                    InteractiveFeedbackButton(
                      onPressed: onCancel,
                      scaleFactor: 0.94,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4F4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF74767D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF74767D),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                child,
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InteractiveFeedbackButton(
                        onPressed: onCancel,
                        scaleFactor: 0.98,
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F4F4),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.urbanist(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF74767D),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InteractiveFeedbackButton(
                        onPressed: onPrimary,
                        scaleFactor: 0.98,
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            primaryLabel,
                            style: GoogleFonts.urbanist(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF74767D),
          ),
        ),
        const SizedBox(height: 8),
        InteractiveFeedbackButton(
          onPressed: onTap,
          scaleFactor: 0.98,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E9F1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4E4E4E),
                    ),
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: Color(0xFF74767D),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF74767D),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: GoogleFonts.urbanist(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4E4E4E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E9F1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E9F1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
