import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:inventory_frontend/domain/valueobject.dart';

part 'entities.freezed.dart';

typedef Timestamp = int;

@freezed
class MonthlySummary with _$MonthlySummary {
  const factory MonthlySummary({
    required String id,
    required String monthYear,
    required int incomingMilliAmount,
    required int outgoingMilliAmount,
  }) = _MonthlySummary;

  const MonthlySummary._();

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    final id = json["id"];
    final incomingAmount = json['incoming_amount'];
    final outgoingAmount = json['outgoing_amount'];
    final monthYearTimestamp = json['month'];

    return MonthlySummary(
        id: id,
        monthYear: monthYearTimestamp,
        incomingMilliAmount: incomingAmount,
        outgoingMilliAmount: outgoingAmount);
  }

  Amount get incomingAmount => (incomingMilliAmount / 1000);
  Amount get outgoingAmount => (outgoingMilliAmount / 1000);
}

// import 'package:billsible/domain/valueobject.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:intl/intl.dart';

// part 'entities.freezed.dart';

@freezed
class MonthYear with _$MonthYear {
  // We need to define a private empty constructor so that we can add function to this dataclass
  const MonthYear._();

  const factory MonthYear({required int month, required int year}) = _MonthYear;

  factory MonthYear.thisMonth() {
    final now = DateTime.timestamp();
    return MonthYear(month: now.month, year: now.year);
  }

  factory MonthYear.deltaMonthFromNow({required int deltaMonth}) {
    final now = DateTime.timestamp();
    return MonthYear(month: now.month - deltaMonth, year: now.year);
  }

  Timestamp get toMonthYearStartTimestamp => TimestampHelper(now: toDateTime).monthYearStart;
  Timestamp get toMonthYearEndTimestamp => TimestampHelper(now: toDateTime).monthYearEnd;

  DateTime get toDateTime => DateTime.utc(year, month);

  String toYearMonthDayString() {
    final df = DateFormat('yyyy-MM-dd');
    return df.format(DateTime(year, month));
  }

  String toShortMonthString() {
    final df = DateFormat('MMM');
    return df.format(DateTime(year, month));
  }

  String toMonthYearString({required MonthYear thisMonthYear}) {
    if (thisMonthYear.year == year && thisMonthYear.month == month) {
      return "This Month";
    }
    final df = DateFormat('MMM y');
    return df.format(DateTime(year, month));
  }

  MonthYear decreaseByOne() {
    return _getDeltaMonth(MonthYear(month: month, year: year), -1);
  }

  MonthYear increaseByOne() {
    return _getDeltaMonth(MonthYear(month: month, year: year), 1);
  }

  MonthYear getDeltaMonth(int value) {
    return _getDeltaMonth(MonthYear(month: month, year: year), value);
  }

  static MonthYear _getDeltaMonth(MonthYear monthYear, int deltaMonth) {
    final dt = DateTime(monthYear.year, monthYear.month);
    final newDt = DateTime(dt.year, dt.month + deltaMonth);
    return MonthYear(month: newDt.month, year: newDt.year);
  }
}

class TimestampHelper {
  final DateTime now;
  //ref: https://stackoverflow.com/a/56489812 // using non-const values as default arguments.
  TimestampHelper({DateTime? now}) : now = now ?? DateTime.timestamp();

  Timestamp get monthYearStart {
    final thisMonthStart = DateTime.utc(now.year, now.month);
    return thisMonthStart.millisecondsSinceEpoch ~/ 1000;
  }

  Timestamp get monthYearEnd {
    final thisMonthStart = DateTime.utc(now.year, now.month + 1, 0);
    return thisMonthStart.millisecondsSinceEpoch ~/ 1000;
  }
}
