import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/bill.account/api.dart';
import 'package:inventory_frontend/domain/bill.account/entities.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/responses.dart';

class BillAccountRestApi extends BillAccountApi {
  @override
  Future<Either<ErrorResponse, ListResponse<BillAccount>>> list({required String teamId, required String token}) async {
    try {
      Map<String, String> map = {};
      map["team_id"] = teamId;
      final response =
          await HttpHelper.getWithQuery(url: ApiEndPoint.getBillAccountEndPoint(), token: token, query: map);
      log("team create response code ${response.statusCode}");
      log("team create response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), BillAccount.fromJson);
        return Right(listResponse);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
  // @override
  // Future<Either<ErrorResponse, ListResponse<Role>>> getRoleList({required String teamId, required String token}) async {
  //   try {
  //     Map<String, String> map = {};
  //     map["team_id"] = teamId;
  //     final response = await HttpHelper.getWithQuery(url: ApiEndPoint.getRoleEndPoint(), token: token, query: map);
  //     log("team create response code ${response.statusCode}");
  //     log("team create response ${jsonDecode(response.body)}");
  //     if (response.statusCode == 200) {
  //       final listResponse = ListResponse.fromJson(jsonDecode(response.body), Role.fromJson);
  //       return Right(listResponse);
  //     }
  //     return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
  //   } catch (e) {
  //     log("the error is $e");
  //     return Left(ErrorResponse.withOtherError(message: e.toString()));
  //   }
  // }
}
