import 'package:flutter/cupertino.dart';
import 'package:flutter_localization/model/local_file.dart';

/// Localization Settings

class LocalizationSettings {
  /// Path to the localisation file in app bundle
  final String localisationFilePath;

  /// The [supportedLanguages] of the app.
  ///
  /// cannot be null or empty, default is 'en'
  /// if no translation is found it will fallback to default language which is [supportedLanguages.first]
  /// if no entry is found for default language localization will return localization_key
  final List<String> supportedLanguages;

  /// List of local files used within the app
  final List<LocalFile> localFiles;

  LocalizationSettings({
    @required this.localisationFilePath,
    this.supportedLanguages = const ['en'],
    this.localFiles = const [],
  })  : assert(localisationFilePath != null, 'localisationFilePath cannot be null'),
        assert(supportedLanguages != null && supportedLanguages.length > 0, 'supportedLanguages cannot be empty');
}
