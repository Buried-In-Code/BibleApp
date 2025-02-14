import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/translation.dart';
import '../settings/provider.dart';
import '../utils.dart';

class BookSelector extends StatefulWidget {
  const BookSelector({super.key});

  @override
  _BookSelectorState createState() => _BookSelectorState();
}

class _BookSelectorState extends State<BookSelector> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('${provider.translation.name} - Select Book')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: provider.translation.books.length,
          itemBuilder: (context, index) {
            final book = provider.translation.books[index];

            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FutureBuilder<Book>(
                      future: loadBook(provider.translation, book),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError || snapshot.data == null) {
                          print(snapshot);
                          return Scaffold(
                            body: Center(
                              child: Text(
                                  "Failed to load book: ${snapshot.error ?? 'Unexpected null data'}"),
                            ),
                          );
                        } else {
                          return ChapterSelector(
                              translation: provider.translation, book: snapshot.data!);
                        }
                      },
                    ),
                  ),
                );
              },
              child: Text(
                book,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ChapterSelector extends StatelessWidget {
  final Translation translation;
  final Book book;

  const ChapterSelector(
      {Key? key, required this.translation, required this.book})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('${book.name} - Select Chapter')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: book.chapters.length,
          itemBuilder: (context, index) {
            final chapter = book.chapters[index];

            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterScreen(
                        translation: translation, book: book, chapter: chapter),
                  ),
                );
              },
              child: Text('${chapter.chapter}',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
            );
          },
        ),
      ),
    );
  }
}

class ChapterScreen extends StatelessWidget {
  final Translation translation;
  final Book book;
  final Chapter chapter;

  const ChapterScreen(
      {Key? key,
      required this.translation,
      required this.book,
      required this.chapter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('${book.name} Chapter ${chapter.chapter}')),
      body: Builder(
        builder: (context) {
          int maxVerseDigits = chapter.verses.length.toString().length;
          double numberColumnWidth = maxVerseDigits * 10.0;

          return ListView.builder(
            itemCount: chapter.verses.length,
            itemBuilder: (context, index) {
              final verse = chapter.verses[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: numberColumnWidth,
                      child: Text(
                        "${verse.verse}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        verse.text,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
