import 'dart:io';

import 'package:mime/mime.dart';

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class LocalizationPath {
  const LocalizationPath(this.path);

  final String path;

  File get file => File(path);

  String? get mime => lookupMimeType(path);

  /// https://api.flutter.dev/flutter/widgets/Image-class.html
  bool get isCsv => mime == 'text/csv';
}
