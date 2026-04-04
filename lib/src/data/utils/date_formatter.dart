import 'package:intl/intl.dart';

String formatDate(DateTime? date) {
  if (date == null) return "-";
  return DateFormat('dd MMM yyyy').format(date);
}

String formatDateTime(DateTime? date) {
  if (date == null) return "-";
  return DateFormat('dd-MM-yyyy at h:mm a').format(date);
}
