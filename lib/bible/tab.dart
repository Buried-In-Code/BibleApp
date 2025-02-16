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
                              translation: provider.translation,
                              book: snapshot.data!);
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
                        translation: translation,
                        initialBook: book,
                        initialChapter: chapter),
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

class ChapterScreen extends StatefulWidget {
  final Translation translation;
  final Book initialBook;
  final Chapter initialChapter;

  const ChapterScreen({
    Key? key,
    required this.translation,
    required this.initialBook,
    required this.initialChapter,
  }) : super(key: key);

  @override
  _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late Book _currentBook;
  late Chapter _currentChapter;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.initialBook;
    _currentChapter = widget.initialChapter;
  }

  Future<void> _changeChapterOrBook(bool forward) async {
    final books = widget.translation.books;
    final currentBookIndex = books.indexWhere((b) => b == _currentBook.name);

    if (forward) {
      if (_currentChapter.chapter < _currentBook.chapters.length) {
        // Move to the next chapter in the same book
        setState(() {
          _currentChapter = _currentBook.chapters[_currentChapter.chapter];
        });
      } else if (currentBookIndex < books.length - 1) {
        // Move to the next book
        final nextBookName = books[currentBookIndex + 1];
        final nextBook = await loadBook(widget.translation, nextBookName);
        setState(() {
          _currentBook = nextBook;
          _currentChapter = nextBook.chapters.first;
        });
      }
    } else {
      if (_currentChapter.chapter > 1) {
        // Move to the previous chapter in the same book
        setState(() {
          _currentChapter = _currentBook.chapters[_currentChapter.chapter - 2];
        });
      } else if (currentBookIndex > 0) {
        // Move to the previous book
        final prevBookName = books[currentBookIndex - 1];
        final prevBook = await loadBook(widget.translation, prevBookName);
        setState(() {
          _currentBook = prevBook;
          _currentChapter = prevBook.chapters.last;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text('${_currentBook.name} Chapter ${_currentChapter.chapter}')),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _changeChapterOrBook(true); // Swipe left → Next
          } else if (details.primaryVelocity! > 0) {
            _changeChapterOrBook(false); // Swipe right → Previous
          }
        },
        child: ListView.builder(
          itemCount: _currentChapter.verses.length,
          itemBuilder: (context, index) {
            final verse = _currentChapter.verses[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30.0,
                    child: Text(
                      "${verse.verse}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text.rich(
                      _formatVerse(verse.text.replaceAll('`', '\'')),
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  TextSpan _formatVerse(String text) {
    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'(<FI>.*?<Fi>)');
    final Iterable<RegExpMatch> matches = regExp.allMatches(text);
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      String italicText = text.substring(match.start + 4, match.end - 4);
      spans.add(TextSpan(
          text: italicText, style: TextStyle(fontStyle: FontStyle.italic)));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return TextSpan(children: spans);
  }
}
