import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  Future<Uint8List> httpGet({@required String url, @required String token}) async {
    http.Response response = await http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(response.body);
    }
  }
}
