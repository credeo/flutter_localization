import 'package:flutter_localization/model/markdown_file.dart';
import 'package:flutter/foundation.dart';

/// Localization Settings

class LocalizationSettings {
  /// The [supportedLanguages] of the app.
  ///
  /// cannot be null or empty, default is 'en'
  /// if no translation is found it will fallback to default language which is first entry in [supportedLanguages]
  /// if no entry is found for default language localization will return localization_key
  final List<String> supportedLanguages;

  /// Initial [localizationJson] of the app.
  ///
  /// if no translation is found it will fallback to default language which is first entry in [supportedLanguages]
  /// if no entry is found for default language localization will return localization_key
  final String localizationJsonPath;

  /// Optional url to update localization.
  /// Url needs to return json in format:
  /// {"version" : "versionNum", "localization" : {localization_key1: {"language1" : "value", "languageX" : "value}}}
  /// if [initialLocalizationVersion] is not provided then "version" param is not required
  /// if no translation is found for current system language it will fallback to default language which is first entry in [supportedLanguages]
  /// if no entry is found for default language localization will return localization_key
  /// url should contain text "version" if endpoint supports versioning, ex. https://server/api/version/localization
  final String updateLocalizationUrl;

  /// If [initialLocalizationVersion] is provided, [FlutterLocalization] will use versioning when fetching new localization.
  /// In this case [updateLocalizationUrl] should contain text "version" and it will be replaced by the version initially provided
  /// in [initialLocalizationVersion] or with newer one if it is saved in local file system.
  ///
  final String initialLocalizationVersion;

  final List<MarkdownFile> markdownFiles;

  LocalizationSettings({
    this.supportedLanguages = const ['en'],
    @required this.localizationJsonPath,
    this.updateLocalizationUrl,
    this.initialLocalizationVersion,
    this.markdownFiles,
  });
}
