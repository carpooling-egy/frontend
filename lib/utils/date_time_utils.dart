import 'package:intl/intl.dart';

/// Formats a DateTime object to ISO 8601 string with 'Z' suffix
String formatDateTimeToIso8601(DateTime dateTime) {
  final utc = dateTime.toUtc();
  return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(utc);
}

/// Parses an ISO 8601 string to DateTime, ensuring UTC timezone
DateTime parseIso8601String(String dateString) {
  if (!dateString.endsWith('Z')) {
    dateString = '${dateString}Z';
  }
  return DateTime.parse(dateString).toUtc();
} 