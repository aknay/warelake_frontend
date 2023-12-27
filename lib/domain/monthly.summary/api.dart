import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/monthly.summary/entities.dart';

abstract class MonthlySummaryApi {
  Future<Either<ErrorResponse, List<MonthlySummary>>> list(
      {required String teamId, required BillAccountId billAccountId, required String token});
}
