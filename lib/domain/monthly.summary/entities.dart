import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inventory_frontend/domain/valueobject.dart';

part 'entities.freezed.dart';

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
