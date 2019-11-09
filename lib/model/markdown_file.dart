import 'package:flutter/cupertino.dart';

class MarkdownFile {
  String name;
  String language;
  String markdown;
  String localAssetsPath;
  String networkUrl;
  String version;

  MarkdownFile({
    @required this.name,
    @required this.language,
    @required this.localAssetsPath,
    this.markdown,
    this.networkUrl,
    this.version,
  });
  MarkdownFile.fromMap(Map<String, dynamic> jsonMap) {
    name = jsonMap['name'];
    markdown = jsonMap['markdown'];
    networkUrl = jsonMap['networkUrl'];
    version = jsonMap['version'];
    language = jsonMap['language'];
    localAssetsPath = jsonMap['localPath'];
  }

  Map<String, dynamic> toJsonMap() {
    Map<String, dynamic> jsonMap = {};

    jsonMap['name'] = name;
    jsonMap['markdown'] = markdown;
    jsonMap['networkUrl'] = networkUrl;
    jsonMap['version'] = version;
    jsonMap['language'] = language;
    jsonMap['localPath'] = localAssetsPath;

    return jsonMap;
  }
}
