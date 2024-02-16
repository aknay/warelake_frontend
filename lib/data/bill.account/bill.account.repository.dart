import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/config/api.endpoint.dart';
import 'package:warelake/data/http.helper.dart';
import 'package:warelake/domain/bill.account/api.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/responses.dart';

part 'bill.account.repository.g.dart';

class BillAccountRepository extends BillAccountApi {
  @override
  Future<Either<ErrorResponse, ListResponse<BillAccount>>> list({required String teamId, required String token}) async {
    try {
      Map<String, String> map = {};
      map["team_id"] = teamId;
      final response =
          await HttpHelper.getWithQuery(url: ApiEndPoint.getBillAccountEndPoint(), token: token, query: map);
      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), BillAccount.fromJson);
        return Right(listResponse);
      }
      log("error while listing bill account: response code ${response.statusCode}");
      log("error while listing bill account:  response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, BillAccount>> get({
    required String billAccountId,
    required String teamId,
    required String token,
  }) async {
    try {
      final response = await HttpHelper.get(
          url: ApiEndPoint.getBillAccountEndPoint(billAccountId: billAccountId), token: token, teamId: teamId);
      log("bill account get response code ${response.statusCode}");
      log("bill account get response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return Right(BillAccount.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
BillAccountRepository billAccountRepository(BillAccountRepositoryRef ref) {
  return BillAccountRepository();
}
