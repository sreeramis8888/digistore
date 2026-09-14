import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/partner_bookings_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import 'partner_booking_calendar_page.dart';
import 'partner_booking_detail_page.dart';

class PartnerBookingsPage extends ConsumerStatefulWidget {
  const PartnerBookingsPage({super.key});

  @override
  ConsumerState<PartnerBookingsPage> createState() => _PartnerBookingsPageState();
}

class _PartnerBookingsPageState extends ConsumerState<PartnerBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['all', 'confirmed', 'in_progress', 'completed', 'cancelled'];
  final List<String> _tabLabels = ['All', 'Confirmed', 'In Progress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF34C759);
      case 'in_progress':
        return const Color(0xFF2563EB);
      case 'completed':
        return const Color(0xFF6B7280);
      case 'cancelled':
      case 'no_show':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF34C759);
    }
  }

  String _formatStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'no_show':
        return 'No Show';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final bookingsState = ref.watch(partnerBookingsProvider);
    final dashboardAsync = ref.watch(partnerBookingDashboardProvider(null));

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
          'Bookings Management',
          style: kSubHeadingM.copyWith(
            color: const Color(0xFF373737),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: kPrimaryColor),
            tooltip: 'Slot Calendar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PartnerBookingCalendarPage(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: kPrimaryColor,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: kPrimaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 13),
          tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
          onTap: (index) {
            ref.read(partnerBookingsProvider.notifier).fetchBookings(status: _statuses[index]);
          },
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: () async {
            ref.read(partnerBookingsProvider.notifier).fetchBookings();
            ref.invalidate(partnerBookingDashboardProvider(null));
          },
          child: CustomScrollView(
            slivers: [
              // Dashboard metrics row
              SliverToBoxAdapter(
                child: dashboardAsync.when(
                  data: (dash) {
                    if (dash == null) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                      child: Row(
                        children: [
                          Expanded(child: _buildMetricCard('Today', '${dash.todayAppointmentsCount}', const Color(0xFF2563EB))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMetricCard('In Queue', '${dash.inQueueCount}', const Color(0xFFFF9500))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMetricCard('Completed', '${dash.completedCount}', const Color(0xFF34C759))),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),

              // Bookings List
              if (bookingsState.isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (bookingsState.bookings.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No bookings found',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, color: Color(0xFF6B7280)),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final b = bookingsState.bookings[index];
                        final token = b.tokenNumber;
                        final statusColor = _getStatusColor(b.status);

                        return Container(
                          margin: EdgeInsets.only(bottom: screenSize.responsivePadding(12)),
                          padding: EdgeInsets.all(screenSize.responsivePadding(14)),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      token,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _formatStatusLabel(b.status),
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenSize.responsivePadding(8)),
                              Text(
                                b.customerDetails?.name ?? 'Customer',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: screenSize.responsivePadding(2)),
                              Text(
                                '${b.bookingDate} at ${b.startTime} • ${b.services.join(", ")}',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Divider(height: 16, color: Color(0xFFE5E7EB)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹ ${b.totalAmount.toInt()}',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (b.status == 'confirmed') ...[
                                        _buildActionBtn('Start', const Color(0xFF2563EB), () {
                                          ref.read(partnerBookingsProvider.notifier).updateBookingStatus(b.id, 'in_progress');
                                        }),
                                        const SizedBox(width: 8),
                                      ],
                                      if (b.status == 'in_progress') ...[
                                        _buildActionBtn('Complete', const Color(0xFF34C759), () {
                                          ref.read(partnerBookingsProvider.notifier).updateBookingStatus(b.id, 'completed');
                                        }),
                                        const SizedBox(width: 8),
                                      ],
                                      InteractiveFeedbackButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PartnerBookingDetailPage(booking: b),
                                            ),
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Text(
                                            'Details →',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Color(0xFF4B5563),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: bookingsState.bookings.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
