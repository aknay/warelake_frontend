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
}
