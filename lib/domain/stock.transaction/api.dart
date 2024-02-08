import 'package:dartz/dartz.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/domain/stock.transaction/search.field.dart';

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

  Future<Either<ErrorResponse, Unit>> delete({
    required String stockTransactionId,
    required String teamId,
    required String token,
  });

  Future<Either<ErrorResponse, ListResponse<StockTransaction>>> list({
    required String teamId,
    required String token,
    StockTransactionSearchField? searchField,
  });
}
