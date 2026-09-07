/// Formats currency values to show as L (Lakh) or Cr (Crore) when appropriate
/// 
/// Examples:
/// - 50000 -> "₹50,000"
/// - 100000 -> "₹1L"
/// - 1250000 -> "₹12.5L"
/// - 10000000 -> "₹1Cr"
/// - 125000000 -> "₹12.5Cr"
String formatCurrency(dynamic value) {
  if (value is String) {
    // If it's already a formatted string like "₹50,000", return as is
    if (value.startsWith('₹')) {
      return value;
    }
    // Try to parse string to number
    value = int.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  }

  final amount = (value as num).toInt();

  if (amount >= 10000000) {
    // Crore
    final crores = amount / 10000000;
    if (crores % 1 == 0) {
      return '₹${crores.toInt()}Cr';
    }
    return '₹${(crores * 10).toInt() / 10}Cr';
  } else if (amount >= 100000) {
    // Lakh
    final lakhs = amount / 100000;
    if (lakhs % 1 == 0) {
      return '₹${lakhs.toInt()}L';
    }
    return '₹${(lakhs * 10).toInt() / 10}L';
  } else {
    // Regular format with commas
    return '₹${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
  }
}

/// Formats reward benefit based on value and valueType
/// e.g.
/// - flat + gift_card / voucher / null: "Worth ₹10,000"
/// - flat + discount: "Flat ₹500 OFF"
/// - percentage: "20% OFF"
String formatRewardBenefit({
  double? value,
  String? valueType,
  String? category,
  bool showWorthPrefix = true,
}) {
  if (value == null || value <= 0) return '';
  final type = valueType?.toLowerCase().trim();
  final isPercentage = type == 'percentage' || type == 'percent' || type == '%';

  if (isPercentage) {
    final valStr = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
    return '$valStr% OFF';
  }

  final valStr = formatCurrency(value);
  final cat = category?.toLowerCase();
  final isGiftCard = cat == 'gift_card' || cat == 'giftcard' || cat == 'voucher';
  if (isGiftCard) {
    return showWorthPrefix ? 'Worth $valStr' : valStr;
  }
  return 'Flat $valStr OFF';
}

/// Formats raw category code into a human-friendly string
/// e.g. "gift_card" -> "Gift Card"
String formatRewardCategory(String? category) {
  if (category == null || category.isEmpty) return '';
  return category
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}
