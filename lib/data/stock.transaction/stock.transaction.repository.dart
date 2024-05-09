import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:warelake/config/api.endpoint.dart';
import 'package:warelake/data/http.helper.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/stock.transaction/api.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/domain/stock.transaction/search.field.dart';

part 'stock.transaction.repository.g.dart';

class StockTransactionRepository extends StockTransactionApi {
  StockTransactionRepository();

  @override
  Future<Either<ErrorResponse, StockTransaction>> create(
      {required StockTransaction stockTransaction, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.post(
          url: ApiEndPoint.getStockTransacitonEndPoint(), body: stockTransaction.toMap(), token: token, teamId: teamId);
      if (response.statusCode == 201) {
        return Right(StockTransaction.fromMap(jsonDecode(response.body)));
      }
      log("stock transaction create response code ${response.statusCode}");
      log("stock transaction  create response ${jsonDecode(response.body)}");
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");

      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, StockTransaction>> get({
    required String stockTransactionId,
    required String teamId,
    required String token,
  }) async {
    try {
      final response = await HttpHelper.get(
          url: ApiEndPoint.getStockTransacitonEndPoint(stockTransactionId: stockTransactionId),
          token: token,
          teamId: teamId);
      log("stock transaction get response code ${response.statusCode}");
      log("stock transaction get response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return Right(StockTransaction.fromMap(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, Unit>> delete({
    required String stockTransactionId,
    required String teamId,
    required String token,
  }) async {
    try {
      final response = await HttpHelper.delete(
          url: ApiEndPoint.getStockTransacitonEndPoint(stockTransactionId: stockTransactionId),
          token: token,
          teamId: teamId);
      log("stock transaction delete response code ${response.statusCode}");
      log("stock transaction delete response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return const Right(unit);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ListResponse<StockTransaction>>> list(
      {required String teamId, required String token, StockTransactionSearchField? searchField}) async {
    try {
      Map<String, String> additionalQuery = {};
      if (searchField != null) {
        if (searchField.startingAfterStockTransactionId != null) {
          additionalQuery["starting_after"] = searchField.startingAfterStockTransactionId!;
        }
        if (searchField.stockMovement != null) {
          additionalQuery["stock_movement"] = searchField.stockMovement!.toFormattedString();
        }
        if (searchField.itemVaraiationName != null) {
          additionalQuery["item_variation_name"] = searchField.itemVaraiationName!;
        }
      }

      final response = await HttpHelper.get(
          url: ApiEndPoint.getStockTransacitonEndPoint(),
          token: token,
          teamId: teamId,
          additionalQuery: additionalQuery);
      log("list stock transaction response code ${response.statusCode}");
      log("list stock transaction response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), StockTransaction.fromMap);
        return Right(listResponse);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
StockTransactionRepository stockTransactionRepository(StockTransactionRepositoryRef ref) {
  return StockTransactionRepository();
}
