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

    static String getItemEndPoint({String? itemId}) {
    return itemId == null ? "${getApiBaseUrl()}/v1/items" : "${getApiBaseUrl()}/v1/items/$itemId";
  }

      static String getPurchaseOrderEndPoint({String? purchaseOrderId}) {
    return purchaseOrderId == null ? "${getApiBaseUrl()}/v1/purchase_orders" : "${getApiBaseUrl()}/v1/purchase_orders/$purchaseOrderId";
  }
}
