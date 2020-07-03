import 'package:flutter/cupertino.dart';

/// Needs to point to a textual file.
class LocalFile {
  String id;
  String data;
  String assetsPath;
  String md5;

  LocalFile({
    @required this.id,
    @required this.assetsPath,
    this.data,
    this.md5,
  });

  LocalFile.fromMap(Map<String, dynamic> jsonMap) {
    id = jsonMap['id'];
    data = jsonMap['data'];
    md5 = jsonMap['md5'];
    assetsPath = jsonMap['assetsPath'];
  }

  Map<String, dynamic> toJsonMap() {
    Map<String, dynamic> jsonMap = {};

    jsonMap['id'] = id;
    jsonMap['data'] = data;
    jsonMap['md5'] = md5;
    jsonMap['assetsPath'] = assetsPath;

    return jsonMap;
  }
}
