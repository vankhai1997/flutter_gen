import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen_core/settings/localization_path.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../settings/pubspec.dart';
import '../utils/error.dart';
import 'generator_helper.dart';

Future<String> generateLocalization(
  DartFormatter formatter,
  FlutterGenLocalization localization,
) async {
  if (!localization.enabled || localization.sheetId.isEmpty) {
    throw const InvalidSettingsException(
        'The value of "flutter_gen/localization:" is incorrect.');
  }
  final headers = {'Content-Type': 'text/csv; charset=utf-8', 'Accept': '*/*'};
  final response = await http.get(
      Uri.parse(
          'https://docs.google.com/spreadsheets/export?format=csv&id=${localization.sheetId}'),
      headers: headers);
  print(response.body);
  final buffer = StringBuffer();
  buffer.writeln(header);
  buffer.writeln(ignore);
  buffer.writeln(import('dart:ui'));
  buffer.writeln();
  buffer.writeln('class LocaleKeys {');
  buffer.writeln('LocaleKeys._();');
  buffer.writeln();
  if (response.statusCode == 200) {
    final outputDir = localization.outDir;
    final outputFileName = localization.outName;
    final preservedKeywords = localization.preservedKeywords;
    final current = Directory.current;
    final output = Directory.fromUri(Uri.parse(outputDir));
    final outputPath =
        Directory(path.join(current.path, output.path, outputFileName));

    final generatedFile = LocalizationPath(outputPath.path);
    if (!generatedFile.file.existsSync()) {
      generatedFile.file.createSync(recursive: true);
    }
    generatedFile.file.writeAsBytesSync(response.bodyBytes);
    final csvParser = CSVParser(response.body);
    buffer.writeln(csvParser.getSupportedLocales());
    buffer.writeln();
    for (String locale in csvParser.singleSupportedLocales()) {
      buffer.writeln(locale);
    }
    buffer.writeln(csvParser.getLocaleKeys(preservedKeywords));
  } else {
    throw InvalidSettingsException(
        'http reasonPhrase: ${response.reasonPhrase}');
  }
  buffer.writeln('}');
  return formatter.format(buffer.toString());
}

class CSVParser {
  final String fieldDelimiter;
  final String strings;
  final List<List<dynamic>> lines;

  CSVParser(this.strings, {this.fieldDelimiter = ','})
      : lines = const CsvToListConverter()
            .convert(strings, fieldDelimiter: fieldDelimiter);

  List<String> singleSupportedLocales() =>
      lines.first.sublist(1, lines.first.length).map((e) {
        final languages = e.toString().split('_');
        return "static const Locale locale${capitalize(languages[0])}${capitalize(languages[1].toLowerCase())} = Locale('${languages[0]}', '${languages[1]}');";
      }).toList();

  String getSupportedLocales() {
    final locales = lines.first.sublist(1, lines.first.length).map((e) {
      final languages = e.toString().split('_');
      return "Locale('${languages[0]}', '${languages[1]}')";
    }).toList();
    return 'static const List<Locale> supportedLocales = [\n${locales.join(',\n')}\n];';
  }

  String getLocaleKeys(List<String> preservedKeywords) {
    final oldKeys =
        lines.getRange(1, lines.length).map((e) => e.first.toString()).toList();
    final keys = <String>[];
    final strBuilder = StringBuffer();
    for (var element in oldKeys) {
      reNewKeys(preservedKeywords, keys, element);
    }
    keys.sort();
    for (int idx = 0; idx < keys.length; idx++) {
      final group1 = keys[idx].split(RegExp(r"[._]"));
      if (idx == 0) {
        groupKey(strBuilder, group1, keys[idx]);
        continue;
      }
      final group2 = keys[idx - 1].split(RegExp(r"[._]"));
      if (group1[0] != group2[0]) {
        strBuilder.writeln('\n   /// ${group1[0]}');
      }
      strBuilder.writeln(
          'static const String ${joinKey(group1)} = \'${keys[idx]}\';');
    }
    return strBuilder.toString();
  }

  void groupKey(StringBuffer strBuilder, List<String> group, String key) {
    strBuilder.writeln('\n   /// ${group[0]}');
    strBuilder.writeln('static const String ${joinKey(group)} = \'$key\';');
  }

  void reNewKeys(
      List<String> preservedKeywords, List<String> newKeys, String key) {
    final keys = key.split('.');
    for (int index = 0; index < keys.length; index++) {
      if (index == 0) {
        addNewKey(newKeys, keys[index]);
        continue;
      }
      if (index == keys.length - 1 && preservedKeywords.contains(keys[index])) {
        continue;
      }
      addNewKey(newKeys, keys.sublist(0, index + 1).join('.'));
    }
  }

  void addNewKey(List<String> newKeys, String key) {
    if (!newKeys.contains(key)) {
      newKeys.add(key);
    }
  }

  String capitalize(String str) => '${str[0].toUpperCase()}${str.substring(1)}';

  String normalize(String str) => '${str[0].toLowerCase()}${str.substring(1)}';

  String joinKey(List<String> keys) =>
      normalize(keys.map((e) => capitalize(e)).toList().join());
}
