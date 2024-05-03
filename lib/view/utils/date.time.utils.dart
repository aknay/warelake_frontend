extension RemoveSeconds on DateTime {
  DateTime removeTime() {
    return DateTime(year, month, day);
  }
}
