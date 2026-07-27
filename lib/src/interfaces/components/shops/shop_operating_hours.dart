import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/business_info.dart';

class ShopOperatingHours extends ConsumerStatefulWidget {
  final OperatingHours? operatingHours;

  const ShopOperatingHours({super.key, this.operatingHours});

  @override
  ConsumerState<ShopOperatingHours> createState() => _ShopOperatingHoursState();
}

class _ShopOperatingHoursState extends ConsumerState<ShopOperatingHours>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _iconAnimation =
        Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  DayStatus? _getDayStatus(int weekday) {
    if (widget.operatingHours == null) return null;
    switch (weekday) {
      case 1:
        return widget.operatingHours!.monday;
      case 2:
        return widget.operatingHours!.tuesday;
      case 3:
        return widget.operatingHours!.wednesday;
      case 4:
        return widget.operatingHours!.thursday;
      case 5:
        return widget.operatingHours!.friday;
      case 6:
        return widget.operatingHours!.saturday;
      case 7:
        return widget.operatingHours!.sunday;
      default:
        return null;
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _formatHours(DayStatus? status) {
    if (status == null) return 'Not available';
    if (status.isOpen != true) return 'Closed';
    final open = status.open ?? '';
    final close = status.close ?? '';
    if (open.isEmpty && close.isEmpty) return 'Open 24 hours';
    return '$open - $close';
  }

  bool _hasAnyOperatingHours() {
    if (widget.operatingHours == null) return false;
    final hours = widget.operatingHours!;
    return hours.monday != null ||
        hours.tuesday != null ||
        hours.wednesday != null ||
        hours.thursday != null ||
        hours.friday != null ||
        hours.saturday != null ||
        hours.sunday != null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAnyOperatingHours()) return const SizedBox.shrink();

    final screenSize = ref.watch(screenSizeProvider);
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    final todayStatus = _getDayStatus(todayWeekday);
    final todayHoursStr = _formatHours(todayStatus);

    bool isCurrentlyOpen = todayStatus?.isOpen == true;

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            InkWell(
              onTap: _toggleExpand,
              child: Padding(
                padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenSize.responsivePadding(10)),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.access_time_filled,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: screenSize.responsivePadding(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operating Hours',
                            style: kSmallTitleSB,
                          ),
                          SizedBox(height: screenSize.responsivePadding(4)),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrentlyOpen
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              SizedBox(width: screenSize.responsivePadding(6)),
                              Expanded(
                                child: Text(
                                  isCurrentlyOpen
                                      ? 'Open Today • $todayHoursStr'
                                      : 'Closed Today',
                                  style: kSmallerTitleL.copyWith(
                                    color: isCurrentlyOpen
                                        ? Colors.green[700]
                                        : Colors.red[700],
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
                    RotationTransition(
                      turns: _iconAnimation,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                padding: EdgeInsets.only(
                  left: screenSize.responsivePadding(16),
                  right: screenSize.responsivePadding(16),
                  bottom: screenSize.responsivePadding(16),
                ),
                child: Column(
                  children: [
                    const Divider(color: kBorder),
                    SizedBox(height: screenSize.responsivePadding(8)),
                    ...List.generate(7, (index) {
                      final dayIndex = index + 1;
                      final isToday = dayIndex == todayWeekday;
                      final status = _getDayStatus(dayIndex);
                      final hoursStr = _formatHours(status);
                      final isOpen = status?.isOpen == true;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenSize.responsivePadding(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getDayName(dayIndex),
                              style: isToday
                                  ? kSmallerTitleSB.copyWith(
                                      color: kPrimaryColor)
                                  : kSmallerTitleM.copyWith(
                                      color: kTextColor),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.responsivePadding(8),
                                vertical: screenSize.responsivePadding(4),
                              ),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? kPrimaryColor.withOpacity(0.1)
                                    : (isOpen
                                        ? Colors.green.withOpacity(0.05)
                                        : Colors.red.withOpacity(0.05)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hoursStr,
                                style: isToday
                                    ? kSmallerTitleSB.copyWith(
                                        color: kPrimaryColor)
                                    : kSmallerTitleM.copyWith(
                                        color: isOpen
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
