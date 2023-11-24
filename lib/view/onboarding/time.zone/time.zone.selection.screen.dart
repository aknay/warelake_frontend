import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class TimeZoneScreen extends StatelessWidget {
  const TimeZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> timeZoneList = getTimeZoneList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Zones'),
      ),
      body: ListView.builder(
        itemCount: timeZoneList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(timeZoneList[index]),
          );
        },
      ),
    );
  }

  List<String> getTimeZoneList() {
    List<String> timeZoneList = [];

    // Get the list of time zones
    final timeZones = tz.timeZoneDatabase.locations;
    final sortingTimeZones =
        timeZones.values.sorted((a, b) => a.currentTimeZone.offset.compareTo(b.currentTimeZone.offset));

    for (var element in sortingTimeZones) {
      final offset = element.currentTimeZone.offset;

      final offsetString = convertMillisecondsToGMTOffset(offset);

      final timeZoneString = '($offsetString) $element ( ${element.name} )';
      timeZoneList.add(timeZoneString);
    }

    return timeZoneList;
  }

  String convertMillisecondsToGMTOffset(int milliseconds) {
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
}
