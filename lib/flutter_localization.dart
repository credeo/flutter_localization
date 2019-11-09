library flutter_localization;

import 'package:flutter_localization/model/localization_settings.dart';
import 'package:flutter_localization/model/localized_string.dart';
import 'package:flutter_localization/service/file_service.dart';
import 'package:flutter_localization/service/localization_service.dart';
import 'package:flutter_localization/service/network_service.dart';
import 'package:flutter_localization/model/markdown_file.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

/// [init] needs to be called before using other [FlutterLocalization] methods
///
/// If [LocalizationSettings.updateLocalizationUrl] is provided localization file can be updated
/// In that case expected format of localization return data is:
/// {
///   "version" : "some_value",
///   "localization" : {
///     "supportedLanguage1: "value",
///     "supportedLanguage2: "value",
///     ...
///     "supportedLanguageX: "value",
///   }
/// }
/// Note: "version" is used only if [LocalizationSettings.initialLocalizationVersion] is provided
///
/// **************************************************************
///
/// Markdown file naming rule in local file system: "name.supportedLanguageX.md"
///
/// If [MarkdownFile.networkUrl] is provided markdown file can be updated
/// In that case expected format of markdown return data is:
/// {
///   "version" : "some_value",
///   "url" : "url_to_download_text-markdown_file"
/// }
/// Note: "version" is used only if [MarkdownFile.version] is provided

class FlutterLocalization {
  static LocalizationSettings _localizationSettings;
  static bool _initCalled = false;

  static Future<void> init(LocalizationSettings localizationSettings) async {
    assert(_initCalled == false, 'init() can be called only once');
    _initCalled = true;
    _localizationSettings = localizationSettings;
    kiwi.Container().registerSingleton((c) => NetworkService());
    kiwi.Container().registerSingleton((c) => FileService());
    kiwi.Container().registerSingleton(
      (c) => LocalizationService(
        settings: _localizationSettings,
      ),
    );

    LocalizationService localizationService = kiwi.Container().resolve<LocalizationService>();
    await localizationService.init();
  }

  /// update localization file
  static Future<void> update() async {
    assert(_initCalled == true, 'init() not called');
    assert(_localizationSettings.updateLocalizationUrl != null, 'update localization url cannot be null');
    LocalizationService localizationService = kiwi.Container().resolve<LocalizationService>();
    return localizationService.updateLocalization();
  }

  /// update markdown files
  static Future<void> updateMarkdownFiles() async {
    assert(_initCalled == true, 'init() not called');
    LocalizationService localizationService = kiwi.Container().resolve<LocalizationService>();
    return localizationService.updateMarkdownFiles();
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

Future<String> getMarkdownFile(String name) async {
  assert(FlutterLocalization._localizationSettings != null, 'FlutterLocalization.init not called');
  return await _localizationService.getMarkdownFile(name);
}
