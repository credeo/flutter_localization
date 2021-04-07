library flutter_localization;

import 'package:flutter_localization/model/localization_settings.dart';
import 'package:flutter_localization/model/localized_string.dart';
import 'package:flutter_localization/service/localization_service.dart';
import 'package:flutter/material.dart';

/// [init] needs to be called before using other [FlutterLocalization] methods
///
/// **************************************************************
class FlutterLocalization {
  static bool _initCalled = false;

  static Future<void> init(LocalizationSettings localizationSettings) async {
    _initCalled = true;
    await LocalizationService.instance.init(settings: localizationSettings);
  }
}

String getLocalizedString(String key, {Map<String, String> variables = const {}}) {
  assert(FlutterLocalization._initCalled, 'FlutterLocalization.init not called');
  return LocalizationService.instance.getLocalizedString(key, variables: variables);
}

LocalizedString getLocalization(String key) {
  assert(FlutterLocalization._initCalled, 'FlutterLocalization.init not called');
  return LocalizationService.instance.getLocalization(key);
}

TextSpan getLocalizedRichString(String key, {Map<String, String> variables = const {}}) {
  assert(FlutterLocalization._initCalled, 'FlutterLocalization.init not called');
  return LocalizationService.instance.getLocalizedRichString(key, variables: variables);
}

Future<String> getLocalFile({@required String id, @required String langCode}) async {
  assert(FlutterLocalization._initCalled, 'FlutterLocalization.init not called');
  assert(id != null, 'id is required');
  assert(langCode != null, 'langCode is required');
  return LocalizationService.instance.getLocalFile(id: id, languageCode: langCode);
}

/// If file with current language is not found, it will try to get file with default language
Future<String> getLocalizedLocalFile(String id) async {
  assert(FlutterLocalization._initCalled, 'FlutterLocalization.init not called');
  return LocalizationService.instance.getLocalizedLocalFile(id);
}

String getCurrentLocalizationCode() {
  assert(FlutterLocalization._initCalled, 'FlutterLocalization.init not called');
  return LocalizationService.instance.currentLanguageCode;
}
