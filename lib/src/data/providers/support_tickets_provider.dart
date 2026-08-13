import 'dart:developer';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/support_ticket_model.dart';
import 'api_provider.dart';

part 'support_tickets_provider.g.dart';

class SupportTicketsState {
  final List<SupportTicketModel> tickets;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSubmitting;
  final String? error;
  final String statusFilter; // 'all', 'open', 'in_progress', 'resolved', 'closed'
  final String searchQuery;
  final int page;
  final int totalPages;

  SupportTicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.error,
    this.statusFilter = 'all',
    this.searchQuery = '',
    this.page = 1,
    this.totalPages = 1,
  });

  SupportTicketsState copyWith({
    List<SupportTicketModel>? tickets,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSubmitting,
    String? error,
    String? statusFilter,
    String? searchQuery,
    int? page,
    int? totalPages,
  }) {
    return SupportTicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error, // Can pass null to clear error
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  List<SupportTicketModel> get filteredTickets {
    if (searchQuery.isEmpty) return tickets;
    final query = searchQuery.toLowerCase();
    return tickets.where((t) {
      return t.subject.toLowerCase().contains(query) ||
          t.id.toLowerCase().contains(query) ||
          t.categoryDisplayName.toLowerCase().contains(query);
    }).toList();
  }
}

@Riverpod(keepAlive: true)
class SupportTickets extends _$SupportTickets {
  @override
  SupportTicketsState build() {
    Future(() => fetchTickets(isRefresh: true));
    return SupportTicketsState(isLoading: true);
  }

  Future<void> fetchTickets({bool isRefresh = false, int pageNum = 1}) async {
    if (isRefresh) {
      state = state.copyWith(isLoading: true, error: null, page: 1);
    } else {
      if (state.isLoadingMore || state.page >= state.totalPages) return;
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final api = ref.read(apiProvider);
    final queryParams = {
      'page': pageNum.toString(),
      'limit': '20',
    };

    if (state.statusFilter != 'all') {
      queryParams['status'] = state.statusFilter;
    }

    try {
      var response = await api.get('/tickets', queryParams: queryParams);

      // Fallback to loyalty unified endpoint if mobile/partner/tickets is not found
      if (!response.success && response.statusCode == 404) {
        final baseUrl = api.baseUrl;
        if (baseUrl.contains('/mobile')) {
          final loyaltyUrl = baseUrl
                  .replaceFirst('/mobile/partner', '/loyalty')
                  .replaceFirst('/mobile', '/loyalty') +
              '/tickets';
          response = await api.get(
            loyaltyUrl.replaceFirst(api.baseUrl, ''),
            queryParams: queryParams,
          );
        }
      }

      if (response.success && response.data != null) {
        final rawData = response.data!['data'];
        final List<dynamic> list = rawData is List<dynamic> ? rawData : [];
        final newTickets = list
            .map((e) =>
                SupportTicketModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final pagination = response.data!['pagination'] as Map<String, dynamic>?;
        final totalPages = pagination != null
            ? (pagination['pages'] as num?)?.toInt() ?? 1
            : 1;

        if (isRefresh || pageNum == 1) {
          state = state.copyWith(
            tickets: newTickets,
            isLoading: false,
            isLoadingMore: false,
            page: pageNum,
            totalPages: totalPages,
          );
        } else {
          state = state.copyWith(
            tickets: [...state.tickets, ...newTickets],
            isLoading: false,
            isLoadingMore: false,
            page: pageNum,
            totalPages: totalPages,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: response.message ?? 'Failed to load support tickets',
        );
      }
    } catch (e) {
      log('Error fetching support tickets: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'Failed to load support tickets: $e',
      );
    }
  }

  void updateStatusFilter(String status) {
    if (state.statusFilter == status) return;
    state = state.copyWith(statusFilter: status);
    fetchTickets(isRefresh: true, pageNum: 1);
  }

  void updateSearchQuery(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
  }

  Future<SupportTicketModel?> getTicketById(String ticketId, {bool forceRefresh = false}) async {
    try {
      final existing = state.tickets.firstWhere((t) => t.id == ticketId);
      if (!forceRefresh) {
        return existing;
      }
    } catch (e) { log('Error: $e'); }

    return await _fetchSingleTicket(ticketId);
  }

  Future<SupportTicketModel?> _fetchSingleTicket(String ticketId) async {
    final api = ref.read(apiProvider);
    try {
      var response = await api.get('/tickets/$ticketId');
      if (!response.success && response.statusCode == 404) {
        final baseUrl = api.baseUrl;
        if (baseUrl.contains('/mobile')) {
          final loyaltyUrl = baseUrl
                  .replaceFirst('/mobile/partner', '/loyalty')
                  .replaceFirst('/mobile', '/loyalty') +
              '/tickets/$ticketId';
          response = await api.get(loyaltyUrl.replaceFirst(api.baseUrl, ''));
        }
      }

      if (response.success && response.data != null) {
        final rawData = response.data!['data'];
        if (rawData != null && rawData is Map<String, dynamic>) {
          final ticket = SupportTicketModel.fromJson(rawData);
          // Update in local state if exists
          final index = state.tickets.indexWhere((t) => t.id == ticket.id);
          if (index != -1) {
            final updatedList = List<SupportTicketModel>.from(state.tickets);
            updatedList[index] = ticket;
            state = state.copyWith(tickets: updatedList);
          } else {
            state = state.copyWith(tickets: [ticket, ...state.tickets]);
          }
          return ticket;
        }
      }
    } catch (e) {
      log('Error fetching single ticket $ticketId: $e');
    }
    return null;
  }

  Future<ApiResponse<Map<String, dynamic>>> createTicket({
    required String subject,
    required String category,
    required String message,
  }) async {
    state = state.copyWith(isSubmitting: true);
    final api = ref.read(apiProvider);
    try {
      final payload = {
        'subject': subject,
        'category': category,
        'message': message,
      };

      var response = await api.post('/tickets', payload);

      if (!response.success && response.statusCode == 404) {
        final baseUrl = api.baseUrl;
        if (baseUrl.contains('/mobile')) {
          final loyaltyUrl = baseUrl
                  .replaceFirst('/mobile/partner', '/loyalty')
                  .replaceFirst('/mobile', '/loyalty') +
              '/tickets';
          response = await api.post(
              loyaltyUrl.replaceFirst(api.baseUrl, ''), payload);
        }
      }

      state = state.copyWith(isSubmitting: false);

      if (response.success) {
        final rawData = response.data?['data'];
        if (rawData != null && rawData is Map<String, dynamic>) {
          final newTicket = SupportTicketModel.fromJson(rawData);
          state = state.copyWith(tickets: [newTicket, ...state.tickets]);
        } else {
          final localTicket = SupportTicketModel(
            id: response.data?['id']?.toString() ?? 'T${DateTime.now().millisecondsSinceEpoch}',
            subject: subject,
            category: category,
            status: 'open',
            messages: [
              SupportTicketMessage(
                id: 'M${DateTime.now().millisecondsSinceEpoch}',
                sender: 'public_user',
                message: message,
                createdAt: DateTime.now(),
              )
            ],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          state = state.copyWith(tickets: [localTicket, ...state.tickets]);
        }
      }
      return response;
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      log('Error creating ticket: $e');
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> replyToTicket({
    required String ticketId,
    required String message,
  }) async {
    final api = ref.read(apiProvider);
    try {
      final payload = {'message': message};
      var response = await api.post('/tickets/$ticketId/reply', payload);

      if (!response.success && response.statusCode == 404) {
        final baseUrl = api.baseUrl;
        if (baseUrl.contains('/mobile')) {
          final loyaltyUrl = baseUrl
                  .replaceFirst('/mobile/partner', '/loyalty')
                  .replaceFirst('/mobile', '/loyalty') +
              '/tickets/$ticketId/reply';
          response = await api.post(
              loyaltyUrl.replaceFirst(api.baseUrl, ''), payload);
        }
      }

      if (response.success) {
        final rawData = response.data?['data'];
        final index = state.tickets.indexWhere((t) => t.id == ticketId);
        if (index != -1) {
          if (rawData != null && rawData is Map<String, dynamic>) {
            final updatedTicket = SupportTicketModel.fromJson(rawData);
            final updatedList = List<SupportTicketModel>.from(state.tickets);
            updatedList[index] = updatedTicket;
            state = state.copyWith(tickets: updatedList);
          } else {
            final oldTicket = state.tickets[index];
            final newMessage = SupportTicketMessage(
              id: 'M${DateTime.now().millisecondsSinceEpoch}',
              sender: 'public_user',
              message: message,
              createdAt: DateTime.now(),
            );
            final updatedTicket = oldTicket.copyWith(
              messages: [...oldTicket.messages, newMessage],
              updatedAt: DateTime.now(),
            );
            final updatedList = List<SupportTicketModel>.from(state.tickets);
            updatedList[index] = updatedTicket;
            state = state.copyWith(tickets: updatedList);
          }
        }
      }
      return response;
    } catch (e) {
      log('Error replying to ticket: $e');
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }
}
