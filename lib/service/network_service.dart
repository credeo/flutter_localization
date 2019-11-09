import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class NetworkService {
  Future<Map<String, dynamic>> getJson(String url) async {
    http.Response response = await http.get(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
//        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Uint8List> httpGet(String url) async {
    http.Response response = await http.get(
      url,
    );

    return response.bodyBytes;
  }
}
