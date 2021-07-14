import 'package:flutter_localization/service/localization_service.dart';

class LocalizedString {
  final Map<String, String> localizedStrings;

  LocalizedString({this.localizedStrings = const {}});
  LocalizedString.copy(LocalizedString copy) : localizedStrings = Map.from(copy.localizedStrings);

  factory LocalizedString.fromMap(Map<String, dynamic> jsonMap) {
    Map<String, String> localizedStrings = {};
    for (String languageCode in LocalizationService.instance.supportedLanguages) {
      localizedStrings[languageCode] = jsonMap[languageCode] ?? '';
    }
    return LocalizedString(localizedStrings: localizedStrings);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = {};
    for (String languageCode in LocalizationService.instance.supportedLanguages) {
      jsonMap[languageCode] = localizedStrings[languageCode] ?? '';
    }
    return jsonMap;
  }

  String getLocalizedString() {
    String? localizedString = localizedStrings[LocalizationService.instance.currentLanguageCode];
    if (localizedString == null || localizedString.isEmpty) {
      localizedString = localizedStrings[LocalizationService.instance.defaultLanguageCode] ?? '';
    }
    return localizedString;
  }
}
