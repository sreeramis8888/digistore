import '../models/offer_model.dart';

/// Matches backend `deal-exclusivity.helper.js`:
/// Hour > Day > Week > Month — one offer, one active deal.
const List<String> kDealPriorityOrder = [
  'deal_of_hour',
  'deal_of_day',
  'deal_of_week',
  'deal_of_month',
];

const Map<String, String> kDealTypeLabels = {
  'deal_of_hour': 'Deal of the Hour',
  'deal_of_day': 'Deal of the Day',
  'deal_of_week': 'Deal of the Week',
  'deal_of_month': 'Deal of the Month',
};

/// Resolved active promotion for display across customer / partner UIs.
class ResolvedActiveDeal {
  final String type;
  final String label;
  final DateTime? startDate;
  final DateTime? expiryDate;

  const ResolvedActiveDeal({
    required this.type,
    required this.label,
    this.startDate,
    this.expiryDate,
  });
}

bool _isDealCurrentlyActive(DealItemModel? deal, DateTime now) {
  if (deal == null || deal.isActive != true) return false;
  final start = deal.startDate;
  final expiry = deal.expiryDate;
  if (expiry != null && expiry.isBefore(now)) return false;
  if (start != null && start.isAfter(now)) return false;
  return true;
}

DealItemModel? _dealForType(DealsModel deals, String type) {
  switch (type) {
    case 'deal_of_hour':
      return deals.dealOfHour;
    case 'deal_of_day':
      return deals.dealOfDay;
    case 'deal_of_week':
      return deals.dealOfWeek;
    case 'deal_of_month':
      return deals.dealOfMonth;
    default:
      return null;
  }
}

/// Prefer API `activeDeal` when present; otherwise resolve from `deals` flags
/// using the same priority as the backend.
ResolvedActiveDeal? resolveActiveDeal({
  ActiveDealModel? activeDeal,
  DealsModel? deals,
  Map<String, dynamic>? rawActiveDeal,
  Map<String, dynamic>? rawDeals,
  DateTime? now,
}) {
  final at = now ?? DateTime.now();

  if (activeDeal != null &&
      activeDeal.type != null &&
      activeDeal.type!.trim().isNotEmpty) {
    final type = activeDeal.type!.trim();
    final expiry = activeDeal.expiryDate;
    final start = activeDeal.startDate;
    final stillValid =
        (expiry == null || !expiry.isBefore(at)) &&
        (start == null || !start.isAfter(at));
    if (stillValid) {
      return ResolvedActiveDeal(
        type: type,
        label: activeDeal.label?.trim().isNotEmpty == true
            ? activeDeal.label!.trim()
            : (kDealTypeLabels[type] ?? type),
        startDate: start,
        expiryDate: expiry,
      );
    }
  }

  if (rawActiveDeal != null) {
    final type = rawActiveDeal['type']?.toString().trim();
    if (type != null && type.isNotEmpty) {
      final expiry = rawActiveDeal['expiryDate'] != null
          ? DateTime.tryParse(rawActiveDeal['expiryDate'].toString())?.toLocal()
          : null;
      final start = rawActiveDeal['startDate'] != null
          ? DateTime.tryParse(rawActiveDeal['startDate'].toString())?.toLocal()
          : null;
      final stillValid =
          (expiry == null || !expiry.isBefore(at)) &&
          (start == null || !start.isAfter(at));
      if (stillValid) {
        final label = rawActiveDeal['label']?.toString().trim();
        return ResolvedActiveDeal(
          type: type,
          label: (label != null && label.isNotEmpty)
              ? label
              : (kDealTypeLabels[type] ?? type),
          startDate: start,
          expiryDate: expiry,
        );
      }
    }
  }

  final modelDeals = deals ??
      (rawDeals != null ? DealsModel.fromJson(rawDeals) : null);
  if (modelDeals == null) return null;

  for (final type in kDealPriorityOrder) {
    final deal = _dealForType(modelDeals, type);
    if (_isDealCurrentlyActive(deal, at)) {
      return ResolvedActiveDeal(
        type: type,
        label: kDealTypeLabels[type] ?? type,
        startDate: deal?.startDate,
        expiryDate: deal?.expiryDate,
      );
    }
  }
  return null;
}

/// Convenience: label only (for pills / badges).
String? resolveActiveDealLabel({
  ActiveDealModel? activeDeal,
  DealsModel? deals,
  Map<String, dynamic>? rawActiveDeal,
  Map<String, dynamic>? rawDeals,
  DateTime? now,
}) {
  return resolveActiveDeal(
    activeDeal: activeDeal,
    deals: deals,
    rawActiveDeal: rawActiveDeal,
    rawDeals: rawDeals,
    now: now,
  )?.label;
}
