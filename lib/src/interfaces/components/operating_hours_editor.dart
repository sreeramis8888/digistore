import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/models/business_info.dart';

class OperatingHoursEditor extends StatelessWidget {
  final OperatingHours? operatingHours;
  final bool isEditMode;
  final ValueChanged<OperatingHours> onChanged;

  const OperatingHoursEditor({
    super.key,
    required this.operatingHours,
    required this.isEditMode,
    required this.onChanged,
  });

  void _updateDayStatus(
    BuildContext context,
    String day, {
    bool? isOpen,
    String? open,
    String? close,
  }) {
    final current = operatingHours ?? const OperatingHours();
    DayStatus? status;
    switch (day) {
      case 'Monday':
        status = current.monday;
        break;
      case 'Tuesday':
        status = current.tuesday;
        break;
      case 'Wednesday':
        status = current.wednesday;
        break;
      case 'Thursday':
        status = current.thursday;
        break;
      case 'Friday':
        status = current.friday;
        break;
      case 'Saturday':
        status = current.saturday;
        break;
      case 'Sunday':
        status = current.sunday;
        break;
    }

    final newStatus = DayStatus(
      isOpen: isOpen ?? status?.isOpen ?? false,
      open: open ?? status?.open ?? '09:00 AM',
      close: close ?? status?.close ?? '09:00 PM',
    );

    final updatedHours = OperatingHours(
      monday: day == 'Monday' ? newStatus : current.monday,
      tuesday: day == 'Tuesday' ? newStatus : current.tuesday,
      wednesday: day == 'Wednesday' ? newStatus : current.wednesday,
      thursday: day == 'Thursday' ? newStatus : current.thursday,
      friday: day == 'Friday' ? newStatus : current.friday,
      saturday: day == 'Saturday' ? newStatus : current.saturday,
      sunday: day == 'Sunday' ? newStatus : current.sunday,
    );

    onChanged(updatedHours);
  }

  Widget _buildWorkingHourRow(BuildContext context, String day) {
    final current = operatingHours ?? const OperatingHours();
    DayStatus? status;
    switch (day) {
      case 'Monday':
        status = current.monday;
        break;
      case 'Tuesday':
        status = current.tuesday;
        break;
      case 'Wednesday':
        status = current.wednesday;
        break;
      case 'Thursday':
        status = current.thursday;
        break;
      case 'Friday':
        status = current.friday;
        break;
      case 'Saturday':
        status = current.saturday;
        break;
      case 'Sunday':
        status = current.sunday;
        break;
    }

    bool isOpen = status?.isOpen ?? false;
    String start = status?.open ?? '09:00 AM';
    String end = status?.close ?? '09:00 PM';

    if (isEditMode) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            SizedBox(
              width: 65,
              child: Text(
                day,
                style: kSmallTitleL.copyWith(color: const Color(0xFF373737)),
              ),
            ),
            const SizedBox(width: 12),
            if (isOpen) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          timePickerTheme: TimePickerThemeData(
                            backgroundColor: kWhite,
                            dialBackgroundColor: kField,
                            dialHandColor: kPrimaryColor,
                            dialTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? kWhite
                                  : kTextColor,
                            ),
                            hourMinuteColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? kPrimaryColor
                                  : kField,
                            ),
                            hourMinuteTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? kWhite
                                  : kTextColor,
                            ),
                            dayPeriodColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? kPrimaryLightColor
                                  : kField,
                            ),
                            dayPeriodTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? kPrimaryColor
                                  : kSecondaryTextColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            hourMinuteShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            dayPeriodShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            entryModeIconColor: kPrimaryColor,
                          ),
                          colorScheme: const ColorScheme.light(
                            primary: kPrimaryColor,
                            onPrimary: kWhite,
                            surface: kWhite,
                            onSurface: kTextColor,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: kPrimaryColor,
                            ),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (time != null && context.mounted) {
                      _updateDayStatus(context, day, open: time.format(context));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      start,
                      style: kSmallTitleL.copyWith(
                        color: const Color(0xFF373737),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          timePickerTheme: TimePickerThemeData(
                            backgroundColor: kWhite,
                            dialBackgroundColor: kField,
                            dialHandColor: kPrimaryColor,
                            dialTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? kWhite
                                  : kTextColor,
                            ),
                            hourMinuteColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? kPrimaryColor
                                  : kField,
                            ),
                            hourMinuteTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? kWhite
                                  : kTextColor,
                            ),
                            dayPeriodColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? kPrimaryLightColor
                                  : kField,
                            ),
                            dayPeriodTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected)
                                  ? kPrimaryColor
                                  : kSecondaryTextColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            hourMinuteShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            dayPeriodShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            entryModeIconColor: kPrimaryColor,
                          ),
                          colorScheme: const ColorScheme.light(
                            primary: kPrimaryColor,
                            onPrimary: kWhite,
                            surface: kWhite,
                            onSurface: kTextColor,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: kPrimaryColor,
                            ),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (time != null && context.mounted) {
                      _updateDayStatus(context, day, close: time.format(context));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      end,
                      style: kSmallTitleL.copyWith(
                        color: const Color(0xFF373737),
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text(
                    'Closed',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
            const SizedBox(width: 12),
            Transform.scale(
              scale: 0.75,
              child: CupertinoSwitch(
                value: isOpen,
                onChanged: (v) => _updateDayStatus(context, day, isOpen: v),
                activeTrackColor: kPrimaryColor,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            SizedBox(
              width: 85,
              child: Text(
                day,
                style: kSmallTitleL.copyWith(color: const Color(0xFF373737)),
              ),
            ),
            const SizedBox(width: 12),
            if (isOpen) ...[
              Expanded(
                child: Center(
                  child: Text(
                    start,
                    style: kSmallTitleL.copyWith(
                      color: const Color(0xFF373737),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    end,
                    style: kSmallTitleL.copyWith(
                      color: const Color(0xFF373737),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'Closed',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 40),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWorkingHourRow(context, 'Monday'),
        _buildWorkingHourRow(context, 'Tuesday'),
        _buildWorkingHourRow(context, 'Wednesday'),
        _buildWorkingHourRow(context, 'Thursday'),
        _buildWorkingHourRow(context, 'Friday'),
        _buildWorkingHourRow(context, 'Saturday'),
        _buildWorkingHourRow(context, 'Sunday'),
      ],
    );
  }
}
