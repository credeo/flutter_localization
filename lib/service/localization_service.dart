import 'dart:convert';
import 'dart:ui';

import 'package:flutter_localization/model/local_file.dart';
import 'package:flutter_localization/model/localization_settings.dart';
import 'package:flutter_localization/model/localized_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:devicelocale/devicelocale.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._();
  static LocalizationService get instance => _instance;

  LocalizationService._();

  LocalizationSettings _settings;
  String _languageCode;
  Map<String, LocalizedString> _localizationStrings = {};

  String get currentLanguageCode => _languageCode;
  String get defaultLanguageCode => _settings.supportedLanguages[0];
  List<String> get supportedLanguages => _settings.supportedLanguages;

  Future<void> init({LocalizationSettings settings}) async {
    _settings = settings;
    String appLanguageCode = await Devicelocale.currentLocale;
    if (appLanguageCode.contains('-')) {
      appLanguageCode = appLanguageCode.split('-')[0];
    } else {
      appLanguageCode = appLanguageCode.split('_')[0];
    }

    if (appLanguageCode != null) {
      _languageCode = _settings.supportedLanguages.firstWhere(
          (supportedLanguage) => supportedLanguage.startsWith(appLanguageCode),
          orElse: () => _settings.supportedLanguages[0]);
    } else {
      _languageCode = _settings.supportedLanguages[0];
    }

    print('flutter_localization: currentLanguageCode is "$_languageCode"');

    await _readLocalization();
  }

  Future<void> _readLocalization() async {
    final Map<String, dynamic> localizationMap = jsonDecode(await rootBundle.loadString(_settings.localisationFilePath));
    _initLocalizationStringFromJsonMap(localizationMap);
  }

  void _initLocalizationStringFromJsonMap(Map<String, dynamic> jsonMap) {
    _localizationStrings = {};
    for (String key in jsonMap.keys) {
      Map<String, dynamic> localizationMap = jsonMap[key];
      _localizationStrings[key] = LocalizedString.fromMap(localizationMap);
    }
  }

  String getLocalizedString(String key, {Map<String, String> variables = const {}}) {
    String localizedString = _localizationStrings[key]?.getLocalizedString() ?? key;
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

  LocalizedString getLocalization(String key) => _localizationStrings[key];

  Future<String> getLocalFile({@required String id, @required String languageCode}) async {
    final localFile =
        _settings.localFiles.firstWhere((file) => file.id == id && file.langCode == languageCode, orElse: () => null);
    if (localFile == null) {
      print('flutter_localization: Local file with id: $id and langCode: $languageCode not found');
      return null;
    } else {
      return rootBundle.loadString(localFile.assetsPath);
    }
  }

  Future<String> getLocalizedLocalFile(String id) async {
    LocalFile localFile =
        _settings.localFiles.firstWhere((file) => file.id == id && file.langCode == currentLanguageCode, orElse: () => null);
    if (localFile == null) {
      print('flutter_localization: Local file with id: $id not found for current language. Fallback to default language');
      localFile =
          _settings.localFiles.firstWhere((file) => file.id == id && file.langCode == defaultLanguageCode, orElse: () => null);
    }
    if (localFile == null) {
      print('flutter_localization: Local file with id: $id not found for default language');
      return null;
    }
    return rootBundle.loadString(localFile.assetsPath);
  }
}
