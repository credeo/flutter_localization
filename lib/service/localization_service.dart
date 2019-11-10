import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_localization/model/localization_settings.dart';
import 'package:flutter_localization/model/localized_string.dart';
import 'package:flutter_localization/model/markdown_file.dart';
import 'package:flutter_localization/service/file_service.dart';
import 'package:flutter_localization/service/network_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class LocalizationService extends ChangeNotifier {
  NetworkService _networkService = kiwi.Container().resolve<NetworkService>();
  FileService _fileService = kiwi.Container().resolve<FileService>();

  final LocalizationSettings _settings;
  String _languageCode;
  Map<String, LocalizedString> localizationStrings = {};
  String _currentLocalizationVersion;

  LocalizationService({
    LocalizationSettings settings,
  })  : assert(settings.supportedLanguages != null && settings.supportedLanguages.length > 0,
            'Supported languages cannot be empty'),
        assert(settings.localizationJsonPath != null, 'Localization json path cannot be null'),
        _settings = settings,
        _currentLocalizationVersion = settings.initialLocalizationVersion;

  String getDefaultLanguage() => _settings.supportedLanguages[0];
  List<String> getSupportedLanguages() => _settings.supportedLanguages;

  Future<void> init() async {
    String appLanguageCode = window.locale?.languageCode;

    if (appLanguageCode != null) {
      _languageCode = _settings.supportedLanguages.firstWhere(
          (supportedLanguage) => supportedLanguage.startsWith(appLanguageCode),
          orElse: () => _settings.supportedLanguages[0]);
    } else {
      _languageCode = _settings.supportedLanguages[0];
    }

    print('_languageCode is: $_languageCode');

    await _getCurrentLocalization();
  }

  Future<void> _getCurrentLocalization() async {
    var localization = await _fileService.getLocalization();
    if (localization != null) {
      _currentLocalizationVersion = localization['version'];
      _initLocalizationStringFromJsonMap(localization['localization']);
    } else {
      Map<String, dynamic> localizationMap = jsonDecode(await rootBundle.loadString(_settings.localizationJsonPath));
      _initLocalizationStringFromJsonMap(localizationMap);
    }
  }

  void _initLocalizationStringFromJsonMap(Map<String, dynamic> jsonMap) {
    for (String key in jsonMap.keys) {
      Map<String, dynamic> localizationMap = jsonMap[key];
      localizationStrings[key] = LocalizedString.fromMap(localizationMap);
    }
    notifyListeners();
  }

  String getCurrentLanguageCode() => _languageCode;
  String getLocalizedString(String key, {Map<String, String> variables = const {}}) {
    String localizedString = localizationStrings[key]?.getLocalizedString() ?? key;
    variables.forEach((key, value) {
      localizedString = localizedString.replaceAll('{$key}', value);
    });
    return localizedString;
  }

  TextSpan getLocalizedRichString(String key, {Map<String, String> variables = const {}}) {
    String localizedString = getLocalizedString(key, variables: variables);

    var regex = RegExp(
      r"(?<=\*)(.*?)(?=\*)",
      caseSensitive: true,
      multiLine: false,
    );

    var index = 0;
    List<TextSpan> textSpans = [];

    var allMatches = regex.allMatches(localizedString);
    for (var i = 0; i < allMatches.length; i++) {
      if (i % 2 == 1) continue;

      var match = allMatches.elementAt(i);

      var span1 = TextSpan(
        text: localizedString.substring(index, match.start - 1),
      );
      if (span1.text.isNotEmpty) textSpans.add(span1);

      var span2 = TextSpan(
        text: localizedString.substring(match.start, match.end),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      );
      textSpans.add(span2);

      index = match.end + 1;
    }

    if (index < localizedString.length) {
      var span3 = TextSpan(
        text: localizedString.substring(index, localizedString.length),
      );
      textSpans.add(span3);
    }

    return TextSpan(children: textSpans);
  }

  LocalizedString getLocalization(String key) => localizationStrings[key];

  Future<String> getMarkdownFile(String name) async {
    MarkdownFile markdownFile = await _fileService.getMarkdownFile(name, getCurrentLanguageCode());

    if (markdownFile == null) {
      MarkdownFile file = _settings.markdownFiles
          .firstWhere((file) => (file.name == name) && (file.language == getCurrentLanguageCode()), orElse: () => null);
      if (file == null) {
        print('Markdown file: ${file.name} not found for language ${getCurrentLanguageCode()}. Fallback to default language');
        file = _settings.markdownFiles.firstWhere(
            (file) => (file.name == name) && (file.language == _settings.supportedLanguages[0]),
            orElse: () => null);
      }
      if (file != null) {
        String markdown = await rootBundle.loadString(file.localAssetsPath);
        return markdown;
      } else {
        print('Markdown file: ${file.name} not found');
        return null;
      }
    } else {
      return markdownFile.markdown;
    }
  }

  Future<void> updateMarkdownFiles() async {
    print('update markdown files called');
    for (MarkdownFile file in _settings.markdownFiles) {
      if (file.networkUrl != null) {
        String url = file.networkUrl;
        if (file.version != null) {
          url = url.replaceFirst('version', file.version);
        }
        Map<String, dynamic> markdownMap = await _networkService.getJson(url);
        if (markdownMap != null) {
          if (file.version != null && file.version == markdownMap['version']) {
            print('markdown file: ${file.name} already up to date.');
          } else {
            print('markdown file: ${file.name} needs update.');
            String markdownFileDownloadUrl = markdownMap['url'];
            Uint8List bytes = await _networkService.httpGet(markdownFileDownloadUrl);
            String markdown = Utf8Decoder().convert(bytes);
            file.markdown = markdown;
            file.version = markdownMap['version'];
            await _fileService.saveMarkdownFile(file);
            print('markdown file: ${file.name} updated.');
          }
        }
      }
    }
  }

  Future<void> updateLocalization() async {
    print('update localization called');

    if (_settings.updateLocalizationUrl != null) {
      String url = _settings.updateLocalizationUrl;

      bool useVersion = _settings.initialLocalizationVersion != null;

      if (useVersion) {
        url.replaceFirst('version', _currentLocalizationVersion);
      }

      Map<String, dynamic> localization = await _networkService.getJson(url);

      String newVersion = useVersion ? localization['version'] : null;
      if (newVersion == null || newVersion != _currentLocalizationVersion) {
        print('new localization downloaded');
        _fileService.saveLocalization(localization);
        _initLocalizationStringFromJsonMap(localization['localization']);
      } else {
        print('localization is up to date');
      }
    }
  }
}
