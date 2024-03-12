import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/config/api.endpoint.dart';
import 'package:warelake/data/http.helper.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/monthly.summary/api.dart';
import 'package:warelake/domain/monthly.summary/entities.dart';
import 'package:warelake/domain/responses.dart';

part 'monthly.summary.repository.g.dart';

class MonthlySummaryRepository extends MonthlySummaryApi {
  @override
  Future<Either<ErrorResponse, List<MonthlySummary>>> list(
      {required String teamId, required String billAccountId, required String token}) async {
    try {
      final response = await HttpHelper.get(
          url: ApiEndPoint.getMonthlyBillSummaryEndPoint(billAccountId: billAccountId), teamId: teamId, token: token);

      if (response.statusCode == 200) {
        final listResponse = ListResponse<MonthlySummary>.fromJson(jsonDecode(response.body), MonthlySummary.fromJson);
        return Right(listResponse.data);
      }
      log("monthly summary: response code ${response.statusCode}");
      log("monthly summary: response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withStatusCode(message: e.toString(), statusCode: 15));
    }
  }
}

@Riverpod(keepAlive: true)
MonthlySummaryApi monthlySummaryRepository(MonthlySummaryRepositoryRef ref) {
  return MonthlySummaryRepository();
}
