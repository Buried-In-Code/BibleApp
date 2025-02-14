import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'models/translation.dart';

String capitalize(String value) =>
    value[0].toUpperCase() + value.substring(1).toLowerCase();

Future<List<Translation>> listTranslations() async {
  final manifestStr = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifest = json.decode(manifestStr);

  final translationFiles = manifest.keys
      .where((key) =>
          key.startsWith('assets/') && key.endsWith('translation.json'))
      .toList();
  return Future.wait(translationFiles.map((entry) async {
    final String contents = await rootBundle.loadString(entry);
    final Map<String, dynamic> data = json.decode(contents);
    return Translation.fromJson(data);
  }));
}

Future<Translation> getTranslation(String acronym) async {
  final String contents =
      await rootBundle.loadString('assets/$acronym/translation.json');
  final Map<String, dynamic> data = json.decode(contents);
  return Translation.fromJson(data);
}

Future<Book> loadBook(Translation translation, String book) async {
  final String contents =
      await rootBundle.loadString('assets/${translation.acronym}/$book.json');
  final Map<String, dynamic> data = json.decode(contents);
  return Book.fromJson(data);
}
