import 'package:flutter_localization/model/local_file.dart';

/// Localization Settings

class LocalizationSettings {
  /// Path to the localisation file in app bundle
  /// Use either [localisationFilePath] or [localisationJson]
  final String? localisationFilePath;

  /// Localisation json
  /// Use either [localisationFilePath] or [localisationJson]
  final String? localisationJson;

  /// The [supportedLanguages] of the app.
  ///
  /// cannot be null or empty, default is 'en'
  /// if no translation is found it will fallback to default language which is [supportedLanguages.first]
  /// if no entry is found for default language localization will return localization_key
  final List<String> supportedLanguages;

  /// List of local files used within the app
  final List<LocalFile> localFiles;

  LocalizationSettings({
    this.localisationFilePath,
    this.localisationJson,
    this.supportedLanguages = const ['en'],
    this.localFiles = const [],
  })  : assert(supportedLanguages.length > 0, 'supportedLanguages cannot be empty'),
        assert(localisationFilePath != null || localisationJson != null,
            'localisationFilePath or localisationJson must not be null');
}
