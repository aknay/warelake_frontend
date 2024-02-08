import 'package:dartz/dartz.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/monthly.summary/entities.dart';

abstract class MonthlySummaryApi {
  Future<Either<ErrorResponse, List<MonthlySummary>>> list(
      {required String teamId, required BillAccountId billAccountId, required String token});
}
