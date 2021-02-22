import 'package:flutter_localization/model/local_file.dart';

/// Localization Settings

class LocalizationSettings {
  /// The [supportedLanguages] of the app.
  ///
  /// cannot be null or empty, default is 'en'
  /// if no translation is found it will fallback to default language which is [supportedLanguages.first]
  /// if no entry is found for default language localization will return localization_key
  final List<String> supportedLanguages;

  /// Index of localization [LocalFile] in [localFiles].
  final int localizationIndex;

  /// List of local files used within the app
  /// Cannot be null or empty
  /// Can be updated via [sync]
  final List<LocalFile> localFiles;

  LocalizationSettings({
    this.supportedLanguages = const ['en'],
    this.localizationIndex = 0,
    this.localFiles,
  })  : assert(localFiles.length > 0, 'localFiles cannot be empty or null'),
        assert(localizationIndex < localFiles.length, 'localizationIndex needs to be lower than length of localFiles'),
        assert(supportedLanguages != null && supportedLanguages.length > 0, 'supportedLanguages cannot be empty');
}
