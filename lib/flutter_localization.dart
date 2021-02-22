library flutter_localization;

import 'package:flutter_localization/model/localization_settings.dart';
import 'package:flutter_localization/model/localized_string.dart';
import 'package:flutter_localization/service/file_service.dart';
import 'package:flutter_localization/service/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';

/// [init] needs to be called before using other [FlutterLocalization] methods
///
/// **************************************************************
///
/// Local file naming rule: "name.language.md"

class FlutterLocalization {
  static LocalizationSettings _localizationSettings;
  static bool _initCalled = false;

  static Future<void> init(LocalizationSettings localizationSettings) async {
    assert(_initCalled == false, 'init() can be called only once');
    _initCalled = true;
    _localizationSettings = localizationSettings;
    KiwiContainer().registerSingleton((c) => FileService());
    KiwiContainer().registerSingleton(
      (c) => LocalizationService(
        settings: _localizationSettings,
      ),
    );

    LocalizationService localizationService = KiwiContainer().resolve<LocalizationService>();
    await localizationService.init();
  }
}

LocalizationService _localizationService = KiwiContainer().resolve<LocalizationService>();

String getLocalizedString(String key, {Map<String, String> variables = const {}}) {
  assert(FlutterLocalization._localizationSettings != null, 'FlutterLocalization.init not called');
  return _localizationService.getLocalizedString(key, variables: variables);
}

LocalizedString getLocalization(String key) {
  assert(FlutterLocalization._localizationSettings != null, 'FlutterLocalization.init not called');
  return _localizationService.getLocalization(key);
}

TextSpan getLocalizedRichString(String key, {Map<String, String> variables = const {}}) {
  assert(FlutterLocalization._localizationSettings != null, 'FlutterLocalization.init not called');
  return _localizationService.getLocalizedRichString(key, variables: variables);
}

Future<String> getLocalFile(String id) async {
  assert(FlutterLocalization._localizationSettings != null, 'FlutterLocalization.init not called');
  return await _localizationService.getLocalFile(id);
}

String getCurrentLocalizationCode() {
  assert(FlutterLocalization._localizationSettings != null, 'FlutterLocalization.init not called');
  return _localizationService.getCurrentLanguageCode();
}
