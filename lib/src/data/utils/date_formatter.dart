import 'package:intl/intl.dart';

String formatDate(DateTime? date) {
  if (date == null) return "-";
  return DateFormat('dd MMM yyyy').format(date);
}

String formatDateTime(DateTime? date) {
  if (date == null) return "-";
  return DateFormat('dd-MM-yyyy at h:mm a').format(date);
}

String formatOfferDate(DateTime? date) {
  if (date == null) return "-";
  final day = date.day;
  String suffix = 'th';
  if (day >= 11 && day <= 13) {
    suffix = 'th';
  } else {
    switch (day % 10) {
      case 1:
        suffix = 'st';
        break;
      case 2:
        suffix = 'nd';
        break;
      case 3:
        suffix = 'rd';
        break;
      default:
        suffix = 'th';
    }
  }
  return "${day}$suffix ${DateFormat('MMMM yyyy').format(date)}";
}
