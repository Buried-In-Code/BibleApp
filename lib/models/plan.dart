class Plan {
  final String name;
  final List<Entry> entries;

  Plan({required this.name, required this.entries});

  factory Plan.fromJson(Map<String, dynamic> data) {
    return Plan(
      name: data['name'],
      entries: (data['entries'] as List).map((x) => Entry.fromJson(x)).toList(),
    );
  }
}

class Entry {
  final int month;
  final int day;
  final List<Reading> firstPortion;
  final List<Reading> secondPortion;
  final List<Reading> thirdPortion;

  Entry({
    required this.month,
    required this.day,
    required this.firstPortion,
    required this.secondPortion,
    required this.thirdPortion,
  });

  factory Entry.fromJson(Map<String, dynamic> data) {
    return Entry(
      month: data['month'],
      day: data['day'],
      firstPortion:
          (data['first'] as List).map((x) => Reading.fromJson(x)).toList(),
      secondPortion:
          (data['second'] as List).map((x) => Reading.fromJson(x)).toList(),
      thirdPortion:
          (data['third'] as List).map((x) => Reading.fromJson(x)).toList(),
    );
  }
}

class Reading {
  final String book;
  final int chapter;

  Reading({required this.book, required this.chapter});

  factory Reading.fromJson(Map<String, dynamic> data) {
    return Reading(book: data['book'], chapter: data['chapter']);
  }
}
