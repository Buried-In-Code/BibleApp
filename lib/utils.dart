import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'models/bible.dart';
import 'models/plan.dart';

String capitalize(String value) =>
    value[0].toUpperCase() + value.substring(1).toLowerCase();

Future<Book> loadBook(String translation, String book) async {
  final String contents = await rootBundle.loadString(
    'assets/$translation/$book.json',
  );
  final Map<String, dynamic> data = json.decode(contents);
  return Book.fromJson(data);
}

Future<Plan> loadPlan() async {
  final String contents = await rootBundle.loadString(
    'assets/reading-plan.json',
  );
  final Map<String, dynamic> data = json.decode(contents);
  return Plan.fromJson(data);
}

String formatDate(DateTime inputDate) {
  String daySuffix = getDaySuffix(inputDate.day);
  return DateFormat("EEE, d'$daySuffix' MMM yyyy").format(inputDate);
}

String getDaySuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

class Constants {
  static const Map<String, String> TRANSLATIONS = {
    'BBE': 'Bible in Basic English',
    'ESV': 'English Standard Version',
    'KJV': 'King James Version',
    'NIV': 'New International Version',
    'YLT': 'Young\'s Literal Translation',
  };
  static const List<String> BOOKS = [
    'Genesis',
    'Exodus',
    'Leviticus',
    'Numbers',
    'Deuteronomy',
    'Joshua',
    'Judges',
    'Ruth',
    'I Samuel',
    'II Samuel',
    'I Kings',
    'II Kings',
    'I Chronicles',
    'II Chronicles',
    'Ezra',
    'Nehemiah',
    'Esther',
    'Job',
    'Psalms',
    'Proverbs',
    'Ecclesiastes',
    'Song of Solomon',
    'Isaiah',
    'Jeremiah',
    'Lamentations',
    'Ezekiel',
    'Daniel',
    'Hosea',
    'Joel',
    'Amos',
    'Obadiah',
    'Jonah',
    'Micah',
    'Nahum',
    'Habakkuk',
    'Zephaniah',
    'Haggai',
    'Zechariah',
    'Malachi',
    'Matthew',
    'Mark',
    'Luke',
    'John',
    'Acts',
    'Romans',
    'I Corinthians',
    'II Corinthians',
    'Galatians',
    'Ephesians',
    'Philippians',
    'Colossians',
    'I Thessalonians',
    'II Thessalonians',
    'I Timothy',
    'II Timothy',
    'Titus',
    'Philemon',
    'Hebrews',
    'James',
    'I Peter',
    'II Peter',
    'I John',
    'II John',
    'III John',
    'Jude',
    'Revelation',
  ];
}
