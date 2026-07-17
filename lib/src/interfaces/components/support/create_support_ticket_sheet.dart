import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/support_tickets_provider.dart';
import '../animated_dropdown.dart';
import '../primary_button.dart';

class CreateSupportTicketSheet extends ConsumerStatefulWidget {
  const CreateSupportTicketSheet({super.key});

  @override
  ConsumerState<CreateSupportTicketSheet> createState() =>
      _CreateSupportTicketSheetState();
}

class _CreateSupportTicketSheetState
    extends ConsumerState<CreateSupportTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _selectedCategory = 'redemption_issue';

  final List<String> _categoryIds = [
    'redemption_issue',
    'payment',
    'account',
    'offer',
    'other',
  ];

  String _getCategoryLabel(String id) {
    switch (id) {
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

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an issue category',
            style: kSmallTitleB.copyWith(color: kWhite),
          ),
          backgroundColor: kErrorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    final response = await ref
        .read(supportTicketsProvider.notifier)
        .createTicket(
          subject: subject,
          category: _selectedCategory!,
          message: message,
        );

    if (mounted) {
      if (response.success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: kWhite, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Support ticket raised successfully!',
                    style: kSmallTitleB.copyWith(color: kWhite),
                  ),
                ),
              ],
            ),
            backgroundColor: kGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? 'Failed to raise ticket. Please try again.',
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
    final isSubmitting = ref.watch(supportTicketsProvider).isSubmitting;

    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kStrokeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Raise Support Ticket',
                    style: kSubHeadingM.copyWith(
                      color: kTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        color: kSecondaryTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Category Dropdown
              Text(
                'Category',
                style: kSmallTitleB.copyWith(
                  color: kTextColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDropdown<String>(
                hint: 'Select Category',
                value: _selectedCategory,
                items: _categoryIds,
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
                itemLabel: _getCategoryLabel,
                height: 48,
                borderRadius: 12,
                borderColor: kStrokeColor,
                fillColor: kWhite,
              ),
              const SizedBox(height: 16),

              // 2. Subject Input
              Text(
                'Subject',
                style: kSmallTitleB.copyWith(
                  color: kTextColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _subjectController,
                style: kSubHeadingM.copyWith(color: kTextColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Brief summary of the issue',
                  hintStyle: kSmallTitleL.copyWith(
                    color: kSecondaryTextColor.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: kWhite,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kStrokeColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kStrokeColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: kPrimaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject';
                  }
                  if (value.trim().length < 4) {
                    return 'Subject must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Detailed Message
              Text(
                'Description',
                style: kSmallTitleB.copyWith(
                  color: kTextColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                style: kSubHeadingM.copyWith(color: kTextColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Provide details about your query or issue...',
                  hintStyle: kSmallTitleL.copyWith(
                    color: kSecondaryTextColor.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: kWhite,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kStrokeColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kStrokeColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: kPrimaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                height: 48,
                child: PrimaryButton(
                  text: 'Submit Ticket',
                  isLoading: isSubmitting,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
