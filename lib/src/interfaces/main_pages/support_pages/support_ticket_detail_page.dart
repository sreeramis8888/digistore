import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/support_ticket_model.dart';
import '../../../data/providers/support_tickets_provider.dart';

class SupportTicketDetailPage extends ConsumerStatefulWidget {
  final SupportTicketModel? initialTicket;
  final String? ticketId;

  const SupportTicketDetailPage({
    super.key,
    this.initialTicket,
    this.ticketId,
  });

  @override
  ConsumerState<SupportTicketDetailPage> createState() =>
      _SupportTicketDetailPageState();
}

class _SupportTicketDetailPageState
    extends ConsumerState<SupportTicketDetailPage> {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSendingReply = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      final id = widget.initialTicket?.id ?? widget.ticketId;
      if (id != null) {
        ref.read(supportTicketsProvider.notifier).getTicketById(id);
      }
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendReply(String id) async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSendingReply) return;

    setState(() {
      _isSendingReply = true;
    });

    final response = await ref
        .read(supportTicketsProvider.notifier)
        .replyToTicket(ticketId: id, message: text);

    if (mounted) {
      setState(() {
        _isSendingReply = false;
      });

      if (response.success) {
        _replyController.clear();
        _scrollToBottom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? 'Failed to send reply',
              style: kSmallTitleB.copyWith(color: kWhite),
            ),
            backgroundColor: kErrorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(supportTicketsProvider);

    final targetId = widget.initialTicket?.id ?? widget.ticketId;
    final ticket = ticketsState.tickets.firstWhere(
      (t) => t.id == targetId,
      orElse: () => widget.initialTicket ??
          SupportTicketModel(
            id: targetId ?? '',
            subject: 'Loading ticket details...',
            category: 'other',
            status: 'open',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );

    final isResolvedOrClosed =
        ticket.status == 'resolved' || ticket.status == 'closed';

    final formattedId = ticket.id.length > 8
        ? '#${ticket.id.substring(ticket.id.length - 8).toUpperCase()}'
        : '#${ticket.id.toUpperCase()}';

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
          'Ticket $formattedId',
          style: kSubHeadingM.copyWith(color: kTextColor),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: ticket.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ticket.statusDisplayName,
              style: kSmallTitleB.copyWith(
                color: ticket.statusColor,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Subject & Category Header Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        ticket.categoryIcon,
                        size: 15,
                        color: ticket.categoryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ticket.categoryDisplayName,
                        style: kSmallTitleB.copyWith(
                          color: ticket.categoryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket.subject,
                    style: kSubHeadingM.copyWith(
                      color: kTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Created on ${_formatFullDate(ticket.createdAt)}',
                    style: kSmallTitleL.copyWith(
                      color: kSecondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Messages Timeline / Chat List
            Expanded(
              child: ticket.messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet',
                        style: kSmallTitleL.copyWith(color: kSecondaryTextColor),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: ticket.messages.length,
                      itemBuilder: (context, index) {
                        final msg = ticket.messages[index];
                        final isUser = msg.isUserOrPartner;

                        return _buildChatBubble(msg: msg, isUser: isUser);
                      },
                    ),
            ),

            // Reply Box or Closed Status Bar
            if (isResolvedOrClosed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  border: Border(
                    top: BorderSide(color: kStrokeColor, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: kSecondaryTextColor,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This ticket is ${ticket.statusDisplayName.toLowerCase()}. If needed, please raise a new ticket.',
                        style: kSmallTitleL.copyWith(
                          color: kSecondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: const BoxDecoration(
                  color: kWhite,
                  border: Border(
                    top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        maxLines: 3,
                        minLines: 1,
                        style: kSubHeadingM.copyWith(
                          color: kTextColor,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a reply...',
                          hintStyle: kSmallTitleL.copyWith(
                            color: kSecondaryTextColor.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: kStrokeColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: kStrokeColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: kPrimaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _isSendingReply
                            ? null
                            : () => _sendReply(ticket.id),
                        icon: _isSendingReply
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: kWhite,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: kWhite,
                                size: 18,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble({
    required SupportTicketMessage msg,
    required bool isUser,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUser
                      ? (msg.sender == 'partner' ? 'You (Partner)' : 'You')
                      : 'Support Team',
                  style: kSmallTitleB.copyWith(
                    color: isUser ? kSecondaryTextColor : kPrimaryColor,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(msg.createdAt),
                  style: kSmallTitleL.copyWith(
                    color: kSecondaryTextColor.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? kPrimaryColor : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 14),
                ),
              ),
              child: Text(
                msg.message,
                style: kSubHeadingM.copyWith(
                  color: isUser ? kWhite : kTextColor,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
