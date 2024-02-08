import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndPoint {
  static String getApiBaseUrl() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return 'http://0.0.0.0:9888/api';
    }
    if (kDebugMode) {
      return 'http://10.0.2.2:9888/api';
    }
    return 'www.example.com'; //TODO
  }

  static String getTeamEndPoint({String? teamId}) {
    return teamId == null ? "${getApiBaseUrl()}/v1/teams" : "${getApiBaseUrl()}/v1/teams/$teamId";
  }

  static String getRoleEndPoint({String? roleId}) {
    return roleId == null ? "${getApiBaseUrl()}/v1/roles" : "${getApiBaseUrl()}/v1/roles/$roleId";
  }

  static String getUserEndPoint({String? userId}) {
    return userId == null ? "${getApiBaseUrl()}/v1/users" : "${getApiBaseUrl()}/v1/users/$userId";
  }

  static String get getCurrentUserEndPoint {
    return "${getApiBaseUrl()}/v1/user";
  }

  static String getItemEndPoint({String? itemId}) {
    return itemId == null ? "${getApiBaseUrl()}/v1/items" : "${getApiBaseUrl()}/v1/items/$itemId";
  }

  static String get itemUtilizationEndPoint => "${getApiBaseUrl()}/v1/item_utilization";

  static String get itemSerchEndPoint => "${getApiBaseUrl()}/v1/items/search";

  static String getItemVariationEndPoint({required String itemId, String? itemVariationId}) {
    return itemVariationId == null
        ? "${getApiBaseUrl()}/v1/items/$itemId/item_variations"
        : "${getApiBaseUrl()}/v1/items/$itemId/item_variations/$itemVariationId";
  }

  static String getItemImageEndPoint({String? imageId}) {
    return imageId == null ? "${getApiBaseUrl()}/v1/items/images" : "${getApiBaseUrl()}/v1/items/images/$imageId";
  }

  static String getPurchaseOrderEndPoint({String? purchaseOrderId}) {
    return purchaseOrderId == null
        ? "${getApiBaseUrl()}/v1/purchase_orders"
        : "${getApiBaseUrl()}/v1/purchase_orders/$purchaseOrderId";
  }

  static String getReceivedItemsPurchaseOrderEndPoint({required String purchaseOrderId}) {
    return "${getApiBaseUrl()}/v1/purchase_orders/$purchaseOrderId/received";
  }

  static String getSaleOrderEndPoint({String? saleOrderId}) {
    return saleOrderId == null ? "${getApiBaseUrl()}/v1/sale_orders" : "${getApiBaseUrl()}/v1/sale_orders/$saleOrderId";
  }

  static String getDelieveredItemsSaleOrderEndPoint({required String saleOrderId}) {
    return "${getApiBaseUrl()}/v1/sale_orders/$saleOrderId/delivered";
  }

  static String getBillAccountEndPoint({String? billAccountId}) {
    return billAccountId == null
        ? "${getApiBaseUrl()}/v1/bill_accounts"
        : "${getApiBaseUrl()}/v1/bill_accounts/$billAccountId";
  }

  static String getMonthlySummaryEndPoint({required String billAccountId, String? monthlySummary}) {
    return monthlySummary == null
        ? "${getApiBaseUrl()}/v1/monthly_summary/$billAccountId"
        : "${getApiBaseUrl()}/v1/monthly_summary/$billAccountId/$monthlySummary";
  }

  static String getStockTransacitonEndPoint({String? stockTransactionId}) {
    return stockTransactionId == null
        ? "${getApiBaseUrl()}/v1/stock_transactions"
        : "${getApiBaseUrl()}/v1/stock_transactions/$stockTransactionId";
  }
}
