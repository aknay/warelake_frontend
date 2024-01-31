import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/responses.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';
import 'package:inventory_frontend/domain/sale.order/search.field.dart';

abstract class SaleOrderApi {
  Future<Either<ErrorResponse, ListResponse<SaleOrder>>> list({
    required String teamId,
    required String token,
    SaleOrderSearchField? searchField,
  });
  Future<Either<ErrorResponse, SaleOrder>> issued(
      {required SaleOrder saleOrder, required String teamId, required String token});
  Future<Either<ErrorResponse, Unit>> deliveredItems({
    required String saleOrderId,
    required DateTime date,
    required String teamId,
    required String token,
  });
  Future<Either<ErrorResponse, SaleOrder>> get(
      {required String saleOrderId, required String teamId, required String token});

  Future<Either<ErrorResponse, Unit>> delete(
      {required String saleOrderId, required String teamId, required String token});
}
