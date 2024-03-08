import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class HttpHelper {
  static post({required String url, Map<String, dynamic>? body, required String token, String? teamId}) {
    Map<String, String> map = {};
    if (teamId != null) {
      map["team_id"] = teamId;
    }

    final uri = teamId == null ? Uri.parse(url) : Uri.parse(url).replace(queryParameters: map);

    return http.post(uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body == null ? null : jsonEncode(body));
  }

  static postWithoutBody({required String url, required String token}) {
    return http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  static jsonToFormData(http.MultipartRequest request, Map<String, dynamic> data) {
    for (var key in data.keys) {
      request.fields[key] = data[key].toString();
    }
    return request;
  }

  static postImage(
      {required String url,
      Map<String, dynamic>? body,
      required File imageFile,
      required String token,
      String? teamId}) async {
    Map<String, String> map = {};
    if (teamId != null) {
      map["team_id"] = teamId;
    }
    var request = http.MultipartRequest('POST', Uri.parse(url).replace(queryParameters: map));
    request.fields['json'] = jsonEncode(body);
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // This should match the name expected by your server
        imageFile.path,
        // contentType: MediaType('image', 'jpeg'), // Adjust the content type based on your image type
      ),
    );

    request.headers['Authorization'] = 'Bearer $token';

    return await request.send();
  }

  static patch({required String url, required Map<String, dynamic> body, required String token}) {
    return http.patch(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body));
  }

  static get({required String url, required String token, String? teamId, Map<String, dynamic>? additionalQuery}) {
    Map<String, dynamic> map = {};
    if (teamId != null) {
      map["team_id"] = teamId;
    }
    if (additionalQuery != null) {
      map.addAll(additionalQuery);
    }

    //query must all string type //it will faill if int type
    final uri = teamId == null ? Uri.parse(url) : Uri.parse(url).replace(queryParameters: map);
    return http.get(uri, headers: {'Authorization': 'Bearer $token'});
  }

  static getWithQuery({required String url, required String token, required Map<String, String> query}) {
    final uri = Uri.parse(url).replace(queryParameters: query);
    return http.get(uri, headers: {'Authorization': 'Bearer $token'});
  }

  static delete({required String url, required String token, Map<String, dynamic>? body, String? teamId}) {
    Map<String, String> map = {};
    if (teamId != null) {
      map["team_id"] = teamId;
    }

    final uri = teamId == null ? Uri.parse(url) : Uri.parse(url).replace(queryParameters: map);
    return http.delete(uri, headers: {'Authorization': 'Bearer $token'}, body: jsonEncode(body));
  }
}
