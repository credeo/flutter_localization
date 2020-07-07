library flutter_localization;

import 'package:flutter_localization/model/localization_settings.dart';
import 'package:flutter_localization/model/localized_string.dart';
import 'package:flutter_localization/service/file_service.dart';
import 'package:flutter_localization/service/graphql_service.dart';
import 'package:flutter_localization/service/localization_service.dart';
import 'package:flutter_localization/service/network_service.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

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
    kiwi.Container().registerSingleton((c) => NetworkService());
    kiwi.Container().registerSingleton((c) => FileService());
    kiwi.Container().registerSingleton((c) => GraphQLService());
    kiwi.Container().registerSingleton(
      (c) => LocalizationService(
        settings: _localizationSettings,
      ),
    );

    LocalizationService localizationService = kiwi.Container().resolve<LocalizationService>();
    await localizationService.init();
  }

  /// sync local files, throws Exception if failed
  static Future<void> sync(
      String authHeader, String uuid, String fcmToken, String platform, String device, String os, String version) async {
    assert(_initCalled == true, 'init() not called');
    assert(_localizationSettings.graphQLEndpoint != null, 'graphQLEndpoint cannot be null');
    assert(_localizationSettings.assetsEndpoint != null, 'assetsEndpoint cannot be null');
    LocalizationService localizationService = kiwi.Container().resolve<LocalizationService>();
    return localizationService.sync(authHeader, uuid, fcmToken, platform, device, os, version);
  }
}

LocalizationService _localizationService = kiwi.Container().resolve<LocalizationService>();

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
