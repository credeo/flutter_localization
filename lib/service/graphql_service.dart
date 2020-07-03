import 'dart:async';
import 'dart:io';

import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  GraphQLClient _client;

  Future<void> _initNetworkService(String syncEndpoint) async {
    try {
//      var firebaseUser = await FirebaseAuth.instance.currentUser();
//
//      if (firebaseUser != null) {
//        var token = await firebaseUser.getIdToken();
//        if (token != null) {
//          authLink = AuthLink(
//            getToken: () => 'Bearer ${token.token}',
//          );
//          link = authLink.concat(_httpLink);
//        } else {
//          link = _httpLink;
//        }
//      } else {
//        link = _httpLink;
//      }

      _client = GraphQLClient(
        link: HttpLink(uri: syncEndpoint),
        cache: OptimisticCache(
          dataIdFromObject: typenameDataIdFromObject,
        ),
      );
    } catch (e) {
      if (e is SocketException) {
        print("flutter_localization: graphql_service: SocketException on initing graphQLClient with error: $e");
      } else {
        print("flutter_localization: graphql_service: error on initing graphQLClient with error: $e");
      }
    }
  }

  Future<dynamic> _callQuery(String query, Map<String, dynamic> vars) async {
    final WatchQueryOptions _options = WatchQueryOptions(
      documentNode: gql(query),
      variables: vars,
    );
    QueryResult result;
    try {
      result = await _client.query(_options).timeout(const Duration(seconds: 20), onTimeout: () {
        throw TimeoutException("flutter_localization: graphql_service: query timeout");
      });
    } catch (e) {
      rethrow;
    }

    if (result.hasException) {
      print("flutter_localization: graphql_service: querry resulted in graphql errors: ${result.exception.graphqlErrors[0]}");
      print(
          "flutter_localization: graphql_service: querry resulted in client errors: ${result.exception.clientException.toString()}");
    } else {
      return result.data;
    }

    if (result.loading) {
      print("flutter_localization: graphql_service: loading...");
    } else {
      if (result.data == null) {
        print("flutter_localization: graphql_service: No Data Found !");
      } else {
        return result.data;
      }
    }
  }

  Future<dynamic> sync(String authToken, String graphQLEndpoint, String uuid, String fcmToken, String platform, String device,
      String os, String version) async {
    await _initNetworkService('$graphQLEndpoint');

    try {
      var result = await _callQuery(
        _syncQuery,
        <String, dynamic>{
          "uuid": uuid,
          "fcmToken": fcmToken,
          "platform": platform,
          "device": device,
          "os": os,
          "version": version,
        },
      );
      if (result != null && result.data != null && result.data['sync'] != null) {
        print('flutter_localization: fetch sync success');
        return result.data['sync'];
      } else {
        throw Exception('sync result is null');
      }
    } catch (e) {
      print('flutter_localization: sync error: ${e.toString()}');
      rethrow;
    }
  }

  static const String _syncQuery = r"""
    query sync($uuid: ID!, $fcmToken: String, $platform: Platform, $device: Device, $os: String, $version: String) {
      sync(uuid: $uuid, fcmToken: $fcmToken, platform: $platform, device: $device, os: $os, version: $version) {
        assets {
          id
          path
          md5
        }
        messages {
          id
          platform
          os
          devices
          version
          title {
            en
            de
          }
          message {
            en
            de
          }
          validFrom {
            isoString
          }
          validUntil {
            isoString
          }
        }
      }
    }
  """;
}
