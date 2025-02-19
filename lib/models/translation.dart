class Translation {
  final String name;
  final String acronym;
  final List<String> books;

  Translation({required this.name, required this.acronym, required this.books});

  factory Translation.fromJson(Map<String, dynamic> data) {
    return Translation(
      name: data['name'],
      acronym: data['acronym'],
      books: List<String>.from(data['books']),
    );
  }
}

class Book {
  final String name;
  final List<Chapter> chapters;

  Book({required this.name, required this.chapters});

  factory Book.fromJson(Map<String, dynamic> data) {
    return Book(
      name: data['name'],
      chapters: (data['chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList(),
    );
  }
}

class Chapter {
  final int chapter;
  final List<Verse> verses;

  Chapter({required this.chapter, required this.verses});

  factory Chapter.fromJson(Map<String, dynamic> data) {
    return Chapter(
      chapter: data['chapter'],
      verses: (data['verses'] as List)
          .map((verse) => Verse.fromJson(verse))
          .toList(),
    );
  }
}

class Verse {
  final int verse;
  final String text;

  Verse({required this.verse, required this.text});

  factory Verse.fromJson(Map<String, dynamic> data) {
    return Verse(
      verse: data['verse'],
      text: data['text'],
    );
  }
}
