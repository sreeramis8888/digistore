import 'package:intl/intl.dart';

String formatDate(DateTime? date) {
  if (date == null) return "-";
  return DateFormat('dd MMM yyyy').format(date.toLocal());
}

String formatDateTime(DateTime? date) {
  if (date == null) return "-";
  return DateFormat('dd-MM-yyyy \'at\' h:mm a').format(date.toLocal());
}

String formatOfferDate(DateTime? date) {
  if (date == null) return "-";
  final localDate = date.toLocal();
  final day = localDate.day;
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
  return "${day}$suffix ${DateFormat('MMMM yyyy').format(localDate)}";
}
