import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/responses.dart';
import 'package:inventory_frontend/domain/sale.order/api.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale.order.repository.g.dart';

class SaleOrderRepository extends SaleOrderApi {
  SaleOrderRepository();

  @override
  Future<Either<ErrorResponse, SaleOrder>> deliveredItems(
      {required SaleOrder saleOrder, required String teamId, required String token}) {
    // TODO: implement deliveredItems
    throw UnimplementedError();
  }

  @override
  Future<Either<ErrorResponse, SaleOrder>> issuedSaleOrder(
      {required SaleOrder saleOrder, required String teamId, required String token}) {
    // TODO: implement issuedSaleOrder
    throw UnimplementedError();
  }

  @override
  Future<Either<ErrorResponse, ListResponse<SaleOrder>>> listSaleOrder(
      {required String teamId, required String token}) {
    // TODO: implement listSaleOrder
    throw UnimplementedError();
  }
}

@Riverpod(keepAlive: true)
SaleOrderRepository saleOrderRepository(SaleOrderRepositoryRef ref) {
  return SaleOrderRepository();
}
