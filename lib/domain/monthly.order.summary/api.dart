import 'package:dartz/dartz.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/monthly.order.summary/entities.dart';

abstract class MonthlyOrderSummaryApi {
  Future<Either<ErrorResponse, MonthlyOrderSummary>> get({required String teamId, required String token});
}
