import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';

abstract class PurchaseOrderApi {
  Future<Either<ErrorResponse, PurchaseOrder>> issuedPurchaseOrder(
      {required PurchaseOrder purchaseOrder, required String teamId, required String token});
  Future<Either<ErrorResponse, PurchaseOrder>> receivedItems(
      {required PurchaseOrder purchaseOrder, required String teamId, required String token});
  Future<Either<ErrorResponse, Unit>> delete(
      {required String purchaseOrderId, required String teamId, required String token});
  Future<Either<ErrorResponse, PurchaseOrder>> get(
      {required String purchaseOrderId, required String teamId, required String token});
}
