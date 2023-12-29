import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';

abstract class StockTransactionApi {
  Future<Either<ErrorResponse, StockTransaction>> create({
    required StockTransaction stockTransaction,
    required String teamId,
    required String token,
  });

  Future<Either<ErrorResponse, StockTransaction>> get({
    required String stockTransactionId,
    required String teamId,
    required String token,
  });
}
