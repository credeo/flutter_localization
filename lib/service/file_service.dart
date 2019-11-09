import 'dart:convert';
import 'dart:io';
import 'package:flutter_localization/model/markdown_file.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  final _localizationFileName = 'localization.json';

  Future<String> _getMarkdownFilePath(String name, String languageCode) async {
    var dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$name.$languageCode.md';
  }

  Future<MarkdownFile> getMarkdownFile(String name, String languageCode) async {
    String filePath = await _getMarkdownFilePath(name, languageCode);
    var file = File(filePath);
    if (file.existsSync()) {
      Map<String, dynamic> markdownMap = jsonDecode(await file.readAsString());
      return MarkdownFile.fromMap(markdownMap);
    } else {
      return null;
    }
  }

  Future<void> saveMarkdownFile(MarkdownFile file, {bool overwrite = false}) async {
    String filePath = await _getMarkdownFilePath(file.name, file.language);
    File mdFile = File(filePath);
    if (overwrite || !mdFile.existsSync()) {
      Map<String, dynamic> markdownMap = file.toJsonMap();
      await mdFile.writeAsString(jsonEncode(markdownMap), flush: true);
    }
  }

  Future<void> saveLocalization(Map<String, dynamic> localizationMap) async {
    var dir = await getApplicationDocumentsDirectory();
    String filePath = dir.path + "/" + _localizationFileName;
    File localizationFile = File(filePath);
    await localizationFile.writeAsString(jsonEncode(localizationMap), flush: true);
  }

  Future<Map<String, dynamic>> getLocalization() async {
    var dir = await getApplicationDocumentsDirectory();
    String filePath = dir.path + "/" + _localizationFileName;
    File localizationFile = File(filePath);
    if (localizationFile.existsSync()) {
      Map<String, dynamic> localization = jsonDecode(await localizationFile.readAsString());
      return localization;
    } else {
      return null;
    }
  }
}
