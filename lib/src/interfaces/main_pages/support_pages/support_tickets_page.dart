import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/support_tickets_provider.dart';
import '../../components/support/create_support_ticket_sheet.dart';
import '../../components/support/support_ticket_card.dart';
import 'support_ticket_detail_page.dart';

class SupportTicketsPage extends ConsumerStatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  ConsumerState<SupportTicketsPage> createState() =>
      _SupportTicketsPageState();
}

class _SupportTicketsPageState extends ConsumerState<SupportTicketsPage> {
  final List<Map<String, String>> _statusTabs = [
    {'id': 'all', 'label': 'All'},
    {'id': 'open', 'label': 'Open'},
    {'id': 'in_progress', 'label': 'In Progress'},
    {'id': 'resolved', 'label': 'Resolved'},
    {'id': 'closed', 'label': 'Closed'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportTicketsProvider.notifier).fetchTickets(isRefresh: true);
    });
  }

  void _openCreateTicketSheet() {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateSupportTicketSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final ticketsState = ref.watch(supportTicketsProvider);
    final tickets = ticketsState.filteredTickets;

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Support Tickets',
          style: kBodyTitleR.copyWith(color: kTextColor),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _openCreateTicketSheet,
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Raise Ticket',
                style: kSmallTitleB.copyWith(color: kPrimaryColor, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Filter Tabs
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: _statusTabs.length,
                itemBuilder: (context, index) {
                  final tab = _statusTabs[index];
                  final isSelected = ticketsState.statusFilter == tab['id'];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(supportTicketsProvider.notifier)
                            .updateStatusFilter(tab['id']!);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimaryColor : kWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? kPrimaryColor : kStrokeColor,
                          ),
                        ),
                        child: Text(
                          tab['label']!,
                          style: kSmallTitleB.copyWith(
                            color: isSelected ? kWhite : kSecondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Ticket List or Empty/Loading States
            Expanded(
              child: RefreshIndicator(
                color: kPrimaryColor,
                onRefresh: () => ref
                    .read(supportTicketsProvider.notifier)
                    .fetchTickets(isRefresh: true),
                child: ticketsState.isLoading && tickets.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      )
                    : ticketsState.error != null && tickets.isEmpty
                        ? _buildErrorState(ticketsState.error!)
                        : tickets.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: tickets.length +
                                    (ticketsState.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == tickets.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: kPrimaryColor,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }

                                  final ticket = tickets[index];
                                  return SupportTicketCard(
                                    ticket: ticket,
                                    screenSize: screenSize,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SupportTicketDetailPage(
                                            initialTicket: ticket,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.support_agent_rounded,
                color: kSecondaryTextColor,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No support tickets found',
                style: kSubHeadingM.copyWith(color: kTextColor, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Have an issue or question? Raise a ticket and we will help you promptly.',
                  style: kSmallTitleL.copyWith(
                    color: kSecondaryTextColor,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _openCreateTicketSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: kWhite,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Raise Support Ticket',
                  style: kSmallTitleB.copyWith(color: kWhite, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: kErrorColor,
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not load tickets',
                style: kSubHeadingM.copyWith(color: kTextColor, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  error,
                  style: kSmallTitleL.copyWith(
                    color: kSecondaryTextColor,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref
                    .read(supportTicketsProvider.notifier)
                    .fetchTickets(isRefresh: true),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Try Again',
                  style: kSmallTitleB.copyWith(color: kPrimaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
