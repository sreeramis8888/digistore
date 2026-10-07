/// Title Case for person / business display names.
///
/// Matches backend `helpers/case-formatter.helper.js` (`toTitleCase`):
/// e.g. "JOHN DOE" / "john doe" → "John Doe", "super salon" → "Super Salon".
/// (Product language often calls this "camel case"; it is Title Case, not camelCase.)
class NameCase {
  NameCase._();

  static String? maybe(String? value) {
    if (value == null) return null;
    final formatted = toTitleCase(value);
    return formatted.isEmpty ? value : formatted;
  }

  static String toTitleCase(String str) {
    final trimmed = str.trim();
    if (trimmed.isEmpty) return str;

    // Skip values that must not be re-cased (same rules as backend).
    if (RegExp(
          r'^(https?:\/\/|\/|data:image)',
          caseSensitive: false,
        ).hasMatch(trimmed) ||
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(trimmed) ||
        RegExp(r'^\+?\d[\d\s\-()]{6,}$').hasMatch(trimmed) ||
        RegExp(r'^[0-9a-f]{24}$', caseSensitive: false).hasMatch(trimmed) ||
        RegExp(r'^[A-Z0-9]+_[A-Z0-9_]+$').hasMatch(trimmed)) {
      return str;
    }

    final lower = trimmed.toLowerCase();
    final buffer = StringBuffer();
    var capitalizeNext = true;
    for (final rune in lower.runes) {
      final ch = String.fromCharCode(rune);
      if (capitalizeNext && RegExp(r'\S').hasMatch(ch)) {
        buffer.write(ch.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(ch);
      }
      if (RegExp(r'[\s/()\-&,]').hasMatch(ch)) {
        capitalizeNext = true;
      }
    }
    return buffer.toString();
  }
}
