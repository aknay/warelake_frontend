import 'package:timezone/timezone.dart' as tz;

String getTimeZoneString(tz.Location location) {
  final offset = location.currentTimeZone.offset;

  final offsetString = _convertMillisecondsToGMTOffset(offset);

  return '($offsetString) ${location.name}';
}

String _convertMillisecondsToGMTOffset(int milliseconds) {
  // Convert milliseconds to Duration
  Duration duration = Duration(milliseconds: milliseconds);

  // Calculate hours and minutes
  int hours = duration.inHours;
  int minutes = (duration.inMinutes % 60).abs();

  // Create GMT offset string
  String offsetString =
      'GMT ${hours < 0 ? '-' : '+'}${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

  return offsetString;
}
