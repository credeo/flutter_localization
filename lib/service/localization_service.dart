import 'dart:convert';
import 'dart:ui';

import 'package:flutter_localization/model/localization_settings.dart';
import 'package:flutter_localization/model/localized_string.dart';
import 'package:flutter_localization/model/local_file.dart';
import 'package:flutter_localization/service/file_service.dart';
import 'package:flutter_localization/service/graphql_service.dart';
import 'package:flutter_localization/service/network_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:devicelocale/devicelocale.dart';

class LocalizationService extends ChangeNotifier {
  final NetworkService _networkService = kiwi.Container().resolve<NetworkService>();
  final GraphQLService _graphQLService = kiwi.Container().resolve<GraphQLService>();
  final FileService _fileService = kiwi.Container().resolve<FileService>();

  final LocalizationSettings _settings;
  String _languageCode;
  Map<String, LocalizedString> localizationStrings = {};

  LocalizationService({
    LocalizationSettings settings,
  }) : _settings = settings;

  String getDefaultLanguage() => _settings.supportedLanguages[0];
  List<String> getSupportedLanguages() => _settings.supportedLanguages;

  Future<void> init() async {
    String appLanguageCode = await Devicelocale.currentLocale;
    if (appLanguageCode.contains('-')) {
      appLanguageCode = appLanguageCode.split('-')[0];
    } else {
      appLanguageCode = appLanguageCode.split('_')[0];
    }

    if (appLanguageCode != null) {
      _languageCode = _settings.supportedLanguages.firstWhere(
          (supportedLanguage) => supportedLanguage.startsWith(appLanguageCode),
          orElse: () => _settings.supportedLanguages[0]);
    } else {
      _languageCode = _settings.supportedLanguages[0];
    }

    print('flutter_localization: currentLanguageCode is "$_languageCode"');

    await _getCurrentLocalization();
  }

  Future<void> _getCurrentLocalization() async {
    LocalFile settingsLocalFile = _settings.localFiles[_settings.localizationIndex];
    LocalFile localizationFile = await _fileService.getLocalFile(settingsLocalFile.id);
    if (localizationFile != null) {
      _initLocalizationStringFromJsonMap(jsonDecode(localizationFile.data));
    } else {
      Map<String, dynamic> localizationMap = jsonDecode(await rootBundle.loadString(settingsLocalFile.assetsPath));
      _initLocalizationStringFromJsonMap(localizationMap);
    }
  }

  void _initLocalizationStringFromJsonMap(Map<String, dynamic> jsonMap) {
    localizationStrings = {};
    for (String key in jsonMap.keys) {
      Map<String, dynamic> localizationMap = jsonMap[key];
      localizationStrings[key] = LocalizedString.fromMap(localizationMap);
    }
    notifyListeners();
  }

  String getCurrentLanguageCode() => _languageCode;

  String getLocalizedString(String key, {Map<String, String> variables = const {}}) {
    String localizedString = localizationStrings[key]?.getLocalizedString() ?? key;
    variables.forEach((key, value) {
      localizedString = localizedString.replaceAll('{$key}', value);
    });
    return localizedString;
  }

  TextSpan getLocalizedRichString(String key, {Map<String, String> variables = const {}}) {
    String localizedString = getLocalizedString(key, variables: variables);

    var regex = RegExp(
      r"(?<=\*)(.*?)(?=\*)",
      caseSensitive: true,
      multiLine: false,
    );

    var index = 0;
    List<TextSpan> textSpans = [];

    var allMatches = regex.allMatches(localizedString);
    for (var i = 0; i < allMatches.length; i++) {
      if (i % 2 == 1) continue;

      var match = allMatches.elementAt(i);

      var span1 = TextSpan(
        text: localizedString.substring(index, match.start - 1),
      );
      if (span1.text.isNotEmpty) textSpans.add(span1);

      var span2 = TextSpan(
        text: localizedString.substring(match.start, match.end),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      );
      textSpans.add(span2);

      index = match.end + 1;
    }

    if (index < localizedString.length) {
      var span3 = TextSpan(
        text: localizedString.substring(index, localizedString.length),
      );
      textSpans.add(span3);
    }

    return TextSpan(children: textSpans);
  }

  LocalizedString getLocalization(String key) => localizationStrings[key];

  Future<String> getLocalFile(String id) async {
    LocalFile localFile = await _fileService.getLocalFile(id);
    if (localFile == null) {
      localFile = _settings.localFiles.firstWhere((file) => file.id == id, orElse: () => null);
      if (localFile == null) {
        print('flutter_localization: Local file: $id not found');
        return null;
      } else {
        String data = await rootBundle.loadString(localFile.assetsPath);
        return data;
      }
    } else {
      return localFile.data;
    }
  }

  Future<void> sync(
      String authHeader, String uuid, String fcmToken, String platform, String device, String os, String version) async {
    print('flutter_localization: sync called');

    Map<String, dynamic> sync =
        await _graphQLService.sync(authHeader, _settings.graphQLEndpoint, uuid, fcmToken, platform, device, os, version);

    List<dynamic> assets = sync['assets'];
    //TODO: implement messages
//    List<dynamic> messages = sync['messages'];

    for (LocalFile file in _settings.localFiles) {
      Map<String, dynamic> asset = assets.firstWhere((element) => element['id'] == file.id, orElse: () => null);
      if (asset != null) {
        LocalFile storedFile = await _fileService.getLocalFile(file.id);
        String localMd5 = storedFile != null ? storedFile.md5 : file.md5;

        String md5 = asset['md5'];
        if (md5 != localMd5) {
          try {
            var responseBytes =
                await _networkService.httpGet(url: '${_settings.assetsEndpoint}/${asset['path']}', token: authToken);
            String data = Utf8Decoder().convert(responseBytes);
            file.data = data;
            file.md5 = md5;
            await _fileService.saveLocalFile(file, overwrite: true);
            print('flutter_localization: ${file.id} successfully updated');
          } catch (e) {
            print('flutter_localization: error fetching file with id: ${file.id} with error: ${e.toString()}');
          }
        } else {
          print('flutter_localization: local file with id: ${file.id} already up to date');
        }
      } else {
        print('flutter_localization: local file with name: ${file.id} not found in sync assets');
      }
    }

    // update localization after sync
    await _getCurrentLocalization();
  }
}
