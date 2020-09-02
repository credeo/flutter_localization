import 'package:flutter_localization/service/localization_service.dart';
import 'package:kiwi/kiwi.dart';

class LocalizedString {
  LocalizationService _localizationService = KiwiContainer().resolve<LocalizationService>();
  Map<String, String> localizedStrings;

  LocalizedString({this.localizedStrings = const {}});
  LocalizedString.fromMap(Map<String, dynamic> jsonMap) {
    localizedStrings = {};
    for (String languageCode in _localizationService.getSupportedLanguages()) {
      localizedStrings[languageCode] = jsonMap[languageCode] ?? '';
    }
  }

  Map<String, dynamic> toJsonMap() {
    Map<String, dynamic> jsonMap = {};
    for (String languageCode in _localizationService.getSupportedLanguages()) {
      jsonMap[languageCode] = localizedStrings[languageCode] ?? '';
    }
    return jsonMap;
  }

  LocalizedString.copy(LocalizedString copy) {
    localizedStrings = Map.from(copy.localizedStrings);
  }

  String getLocalizedString() {
    String localizedString = localizedStrings[_localizationService.getCurrentLanguageCode()];
    if (localizedString == null || localizedString.isEmpty) {
      localizedString = localizedStrings[_localizationService.getDefaultLanguage()] ?? '';
    }
    return localizedString;
  }
}
