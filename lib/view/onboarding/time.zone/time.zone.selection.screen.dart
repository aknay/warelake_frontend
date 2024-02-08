import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:warelake/view/onboarding/time.zone/time.zone.helper.dart';
import 'package:timezone/timezone.dart' as tz;

class TimeZoneScreen extends StatelessWidget {
  const TimeZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timeZoneList = getTimeZoneList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Zones'),
      ),
      body: ListView.builder(
        itemCount: timeZoneList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(getTimeZoneString(timeZoneList[index])),
            onTap: () {
              Navigator.pop(context, timeZoneList[index]);
            },
          );
        },
      ),
    );
  }

  List<tz.Location> getTimeZoneList() {
    // // Get the list of time zones
    final timeZones = tz.timeZoneDatabase.locations;
    final sortingTimeZones =
        timeZones.values.sorted((a, b) => a.currentTimeZone.offset.compareTo(b.currentTimeZone.offset));
    return sortingTimeZones;
  }
}
