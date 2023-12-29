import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/stock.transaction/api.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stock.transaction.repository.g.dart';

class StockTransactionRepository extends StockTransactionApi {
  StockTransactionRepository();

  @override
  Future<Either<ErrorResponse, StockTransaction>> create(
      {required StockTransaction stockTransaction, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.post(
          url: ApiEndPoint.getStockTransacitonEndPoint(), body: stockTransaction.toMap(), token: token, teamId: teamId);
      log("stock transaction create response code ${response.statusCode}");
      log("stock transaction  create response ${jsonDecode(response.body)}");
      if (response.statusCode == 201) {
        return Right(StockTransaction.fromMap(jsonDecode(response.body)));
      }
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
}

@Riverpod(keepAlive: true)
StockTransactionRepository stockTransactionRepository(StockTransactionRepositoryRef ref) {
  return StockTransactionRepository();
}
