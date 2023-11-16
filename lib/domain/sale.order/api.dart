import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';

abstract class SaleOrderApi {
  // Future<Either<ErrorResponse, ListResponse<Item>>> getItemList({required String teamId, required String token});
  Future<Either<ErrorResponse, SaleOrder>> issuedSaleOrder(
      {required SaleOrder saleOrder, required String teamId, required String token});
  // Future<Either<ErrorResponse, PurchaseOrder>> receivedItems(
  //     {required PurchaseOrder purchaseOrder, required String teamId, required String token});
}
