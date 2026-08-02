import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';

class SupportTicketMessage {
  final String id;
  final String sender; // 'public_user', 'partner', 'admin', 'system'
  final String message;
  final List<String> attachments;
  final DateTime createdAt;

  SupportTicketMessage({
    required this.id,
    required this.sender,
    required this.message,
    this.attachments = const [],
    required this.createdAt,
  });

  factory SupportTicketMessage.fromJson(Map<String, dynamic> json) {
    return SupportTicketMessage(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      sender: (json['sender'] ?? 'system').toString(),
      message: (json['message'] ?? '').toString(),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'message': message,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isUserOrPartner =>
      sender == 'public_user' || sender == 'partner' || sender == 'user';
}

class SupportTicketModel {
  final String id;
  final String subject;
  final String category; // 'redemption_issue', 'payment', 'account', 'offer', 'other'
  final String status; // 'open', 'in_progress', 'resolved', 'closed'
  final String priority; // 'low', 'medium', 'high'
  final List<SupportTicketMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicketModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    this.priority = 'medium',
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      subject: (json['subject'] ?? 'Untitled Ticket').toString(),
      category: (json['category'] ?? 'other').toString().toLowerCase(),
      status: (json['status'] ?? 'open').toString().toLowerCase(),
      priority: (json['priority'] ?? 'medium').toString().toLowerCase(),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) =>
                  SupportTicketMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'subject': subject,
      'category': category,
      'status': status,
      'priority': priority,
      'messages': messages.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SupportTicketModel copyWith({
    String? id,
    String? subject,
    String? category,
    String? status,
    String? priority,
    List<SupportTicketMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
      case 'inprogress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status.toUpperCase();
    }
  }

  Color get statusColor {
    switch (status) {
      case 'open':
        return const Color(0xFF2B74E1); // Blue
      case 'in_progress':
      case 'inprogress':
        return const Color(0xFFFF6900); // Orange
      case 'resolved':
        return kGreen; // Green
      case 'closed':
        return const Color(0xFF6B7280); // Gray
      default:
        return kPrimaryColor;
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case 'redemption_issue':
        return 'Redemption Issue';
      case 'payment':
        return 'Payment & Billing';
      case 'account':
        return 'Account & Profile';
      case 'offer':
        return 'Offers & Discounts';
      case 'other':
      default:
        return 'General Support';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'redemption_issue':
        return Icons.confirmation_number_outlined;
      case 'payment':
        return Icons.account_balance_wallet_outlined;
      case 'account':
        return Icons.person_outline_rounded;
      case 'offer':
        return Icons.local_offer_outlined;
      case 'other':
      default:
        return Icons.support_agent_rounded;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'redemption_issue':
        return const Color(0xFF8B5CF6); // Purple
      case 'payment':
        return const Color(0xFF10B981); // Green
      case 'account':
        return const Color(0xFF3B82F6); // Blue
      case 'offer':
        return const Color(0xFFF59E0B); // Amber
      case 'other':
      default:
        return const Color(0xFF6366F1); // Indigo
    }
  }
}
