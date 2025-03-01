class Book {
  final String name;
  final List<Chapter> chapters;

  Book({required this.name, required this.chapters});

  factory Book.fromJson(Map<String, dynamic> data) {
    return Book(
      name: data['name'],
      chapters:
          (data['chapters'] as List)
              .map((chapter) => Chapter.fromJson(chapter))
              .toList(),
    );
  }
}

class Chapter {
  final int value;
  final List<Verse> verses;

  Chapter({required this.chapter, required this.verses});

  factory Chapter.fromJson(Map<String, dynamic> data) {
    return Chapter(
      value: data['chapter'],
      verses:
          (data['verses'] as List)
              .map((verse) => Verse.fromJson(verse))
              .toList(),
    );
  }
}

class Verse {
  final int value;
  final String text;

  Verse({required this.verse, required this.text});

  factory Verse.fromJson(Map<String, dynamic> data) {
    return Verse(value: data['verse'], text: data['text']);
  }
}
