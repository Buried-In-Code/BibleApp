import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'models/plan.dart';
import 'models/translation.dart';

String capitalize(String value) =>
    value[0].toUpperCase() + value.substring(1).toLowerCase();

Future<List<Translation>> listTranslations() async {
  final manifestStr = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifest = json.decode(manifestStr);

  final translationFiles = manifest.keys
      .where(
        (key) => key.startsWith('assets/') && key.endsWith('translation.json'),
      )
      .toList();
  return Future.wait(
    translationFiles.map((entry) async {
      final String contents = await rootBundle.loadString(entry);
      final Map<String, dynamic> data = json.decode(contents);
      return Translation.fromJson(data);
    }),
  );
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

Future<Plan> getPlan() async {
  final String contents =
      await rootBundle.loadString('assets/reading-plan.json');
  final Map<String, dynamic> data = json.decode(contents);
  return Plan.fromJson(data);
}

String formatDate(DateTime inputDate) {
  String daySuffix = getDaySuffix(inputDate.day);
  return DateFormat("EEE, d'$daySuffix' MMM yyyy").format(inputDate);
}

String getDaySuffix(int day) {
  if (day >= 11 && day <= 13) return "th";
  switch (day % 10) {
    case 1:
      return "st";
    case 2:
      return "nd";
    case 3:
      return "rd";
    default:
      return "th";
  }
}
