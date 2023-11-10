import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpHelper {
  static post({required String url, required Map<String, dynamic> body, required String token}) {
    return http.post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body));
  }

    static postWithoutBody({required String url, required String token}) {
    return http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  static patch({required String url, required Map<String, dynamic> body, required String token}) {
    return http.patch(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body));
  }

  static get({required String url, required String token}) {
    return http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
  }

  static getWithQuery({required String url, required String token, required Map<String, String> query}) {
    final uri = Uri.parse(url).replace(queryParameters: query);
    return http.get(uri, headers: {'Authorization': 'Bearer $token'});
  }

  static delete({required String url, required String token, Map<String, dynamic>? body}) {
    return http.delete(Uri.parse(url), headers: {'Authorization': 'Bearer $token'}, body: jsonEncode(body));
  }
}
