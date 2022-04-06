/// Localization Test Settings

class LocalizationTestSettings {
  /// Path to the localisation file in app bundle
  /// Use either [localisationFilePath] or [localisationJson]
  final String? localisationFilePath;

  /// Localisation json
  /// Use either [localisationFilePath] or [localisationJson]
  final String? localisationJson;

  /// Language Code to be used during testing
  ///
  /// Cannot be null, default is 'en'
  final String languageCode;

  LocalizationTestSettings({
    this.localisationFilePath,
    this.localisationJson,
    this.languageCode = 'en',
  }) : assert(localisationFilePath != null || localisationJson != null,
            'localisationFilePath or localisationJson must not be null');
}
