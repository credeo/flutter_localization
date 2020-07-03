import 'dart:convert';
import 'dart:io';
import 'package:flutter_localization/model/local_file.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<String> _getLocalFilePath(String id) async {
    var dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$id.md';
  }

  Future<LocalFile> getLocalFile(String id) async {
    String filePath = await _getLocalFilePath(id);
    var file = File(filePath);
    if (file.existsSync()) {
      Map<String, dynamic> localFileMap = jsonDecode(await file.readAsString());
      return LocalFile.fromMap(localFileMap);
    } else {
      return null;
    }
  }

  Future<void> saveLocalFile(LocalFile file, {bool overwrite = false}) async {
    String filePath = await _getLocalFilePath(file.id);
    File mdFile = File(filePath);
    if (overwrite || !mdFile.existsSync()) {
      Map<String, dynamic> localFileMap = file.toJsonMap();
      await mdFile.writeAsString(jsonEncode(localFileMap), flush: true);
    }
  }
}
