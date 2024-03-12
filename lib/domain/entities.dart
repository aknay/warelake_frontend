class DateRange {
  DateTime startDate;
  DateTime endDate;
  DateRange({required this.startDate, required this.endDate});

  Map<String, String> toMap() {
    return {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
