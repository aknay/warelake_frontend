import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/config/api.endpoint.dart';
import 'package:warelake/data/http.helper.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/monthly.order.summary/api.dart';
import 'package:warelake/domain/monthly.order.summary/entities.dart';

part 'monthly.order.summary.repository.g.dart';

class MonthlyOrderSummaryRepository extends MonthlyOrderSummaryApi {
  @override
  Future<Either<ErrorResponse, MonthlyOrderSummary>> get({required String teamId, required String token, DateTime? date}) async {
    try {
      Map<String, String> additionalQuery = {};
      final now = date ?? DateTime.now();
      additionalQuery['month'] = now.month.toString();
      additionalQuery['year'] = now.year.toString();

      final response = await HttpHelper.get(
          url: ApiEndPoint.getMonthlyOrderSummaryEndPoint(),
          additionalQuery: additionalQuery,
          teamId: teamId,
          token: token);
      if (response.statusCode == 200) {
        return Right(MonthlyOrderSummary.fromJson(jsonDecode(response.body)));
      }
      log("monthly order summary: response code ${response.statusCode}");
      log("monthly oder summary: response ${response.body}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is: $e");
      return Left(ErrorResponse.withStatusCode(message: e.toString(), statusCode: 15));
    }
  }
}

@Riverpod(keepAlive: true)
MonthlyOrderSummaryApi monthlyOrderSummaryRepository(MonthlyOrderSummaryRepositoryRef ref) {
  return MonthlyOrderSummaryRepository();
}
