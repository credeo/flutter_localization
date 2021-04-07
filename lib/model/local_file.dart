import 'package:flutter/foundation.dart';

/// Needs to point to a textual file.
class LocalFile {
  final String id;
  final String assetsPath;
  final String langCode;

  const LocalFile({
    @required this.id,
    @required this.assetsPath,
    @required this.langCode,
  });
}
