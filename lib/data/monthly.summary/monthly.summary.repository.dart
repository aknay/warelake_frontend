import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/monthly.summary/api.dart';
import 'package:inventory_frontend/domain/monthly.summary/entities.dart';
import 'package:inventory_frontend/domain/responses.dart';

class MonthlySummaryRepository extends MonthlySummaryApi {
  @override
  Future<Either<ErrorResponse, List<MonthlySummary>>> get(
      {required String teamId, required String billAccountId, required String token}) async {
    try {
      final response = await HttpHelper.get(
          url: ApiEndPoint.getMonthlySummaryEndPoint(billAccountId: billAccountId), teamId: teamId, token: token);
      log("monthly summary: response code ${response.statusCode}");
      log("monthly summary: response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        final listResponse = ListResponse<MonthlySummary>.fromJson(jsonDecode(response.body), MonthlySummary.fromJson);
        return Right(listResponse.data);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withStatusCode(message: e.toString(), statusCode: 15));
    }
  }
}
