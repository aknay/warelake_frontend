import 'package:dartz/dartz.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/responses.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/domain/sale.order/search.field.dart';

abstract class SaleOrderApi {
  Future<Either<ErrorResponse, ListResponse<SaleOrder>>> list({
    required String teamId,
    required String token,
    SaleOrderSearchField? searchField,
  });
  Future<Either<ErrorResponse, SaleOrder>> create(
      {required SaleOrder saleOrder, required String teamId, required String token});
  Future<Either<ErrorResponse, Unit>> setToDelivered({
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
