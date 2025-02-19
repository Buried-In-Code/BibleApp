import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/translation.dart';
import '../settings/provider.dart';
import '../utils.dart';

class BibleTab extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const BibleTab({super.key, required this.navigatorKey});

  @override
  _BibleTabState createState() => _BibleTabState();
}

class _BibleTabState extends State<BibleTab> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        switch (settings.name) {
          case '/chapterSelector':
            return MaterialPageRoute(
              builder: (_) => ChapterSelector(
                initialBook: args['book'],
              ),
            );
          case '/versesScreen':
            return MaterialPageRoute(
              builder: (_) => VersesScreen(
                initialBook: args['book'],
                initialChapter: args['chapter'],
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => const BookSelector());
        }
      },
    );
  }
}

class BookSelector extends StatelessWidget {
  const BookSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
              '[${provider.translation.acronym}] ${provider.translation.name}'),
          automaticallyImplyLeading: false),
      body: GridView.builder(
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
            onPressed: () async {
              final loadedBook = await loadBook(provider.translation, book);
              Navigator.of(context, rootNavigator: false).pushNamed(
                '/chapterSelector',
                arguments: {
                  'book': loadedBook,
                },
              );
            },
            child: Text(book,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
          );
        },
      ),
    );
  }
}

class ChapterSelector extends StatefulWidget {
  final Book initialBook;

  const ChapterSelector({
    super.key,
    required this.initialBook,
  });

  @override
  _ChapterSelectorState createState() => _ChapterSelectorState();
}

class _ChapterSelectorState extends State<ChapterSelector> {
  late Translation _currentTranslation;
  late Book _currentBook;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    _currentTranslation = provider.translation;
    _currentBook = widget.initialBook;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    if (_currentTranslation != provider.translation) {
      _currentTranslation = provider.translation;
      _loadNewTranslation();
    }

    return Scaffold(
      appBar: AppBar(
          leading: BackButton(onPressed: () {
            Navigator.of(context).pushNamed('/bookSelector');
          }),
          title:
              Text('[${provider.translation.acronym}] ${_currentBook.name}')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _currentBook.chapters.length,
        itemBuilder: (context, index) {
          final chapter = _currentBook.chapters[index];

          return ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/versesScreen',
                arguments: {'book': _currentBook, 'chapter': chapter},
              );
            },
            child: Text('${chapter.chapter}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20)),
          );
        },
      ),
    );
  }

  Future<void> _loadNewTranslation() async {
    final newBook = await loadBook(_currentTranslation, _currentBook.name);
    setState(() {
      _currentBook = newBook;
    });
  }
}

class VersesScreen extends StatefulWidget {
  final Book initialBook;
  final Chapter initialChapter;

  const VersesScreen({
    super.key,
    required this.initialBook,
    required this.initialChapter,
  });

  @override
  _VersesScreenState createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  late Translation _currentTranslation;
  late Book _currentBook;
  late Chapter _currentChapter;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    _currentTranslation = provider.translation;
    _currentBook = widget.initialBook;
    _currentChapter = widget.initialChapter;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    if (_currentTranslation != provider.translation) {
      _currentTranslation = provider.translation;
      _loadNewTranslation();
    }

    return Scaffold(
      appBar: AppBar(
          leading: BackButton(onPressed: () {
            Navigator.of(context).pushNamed(
              '/chapterSelector',
              arguments: {'book': _currentBook},
            );
          }),
          title: Text(
              '[${provider.translation.acronym}] ${_currentBook.name} ${_currentChapter.chapter}')),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _changeChapterOrBook(true);
          } else if (details.primaryVelocity! > 0) {
            _changeChapterOrBook(false);
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

  Future<void> _loadNewTranslation() async {
    final newBook = await loadBook(_currentTranslation, _currentBook.name);
    setState(() {
      _currentBook = newBook;
      _currentChapter = newBook.chapters.firstWhere(
          (c) => c.chapter == _currentChapter.chapter,
          orElse: () => newBook.chapters.first);
    });
  }

  Future<void> _changeChapterOrBook(bool forward) async {
    final books = _currentTranslation.books;
    final currentBookIndex = books.indexWhere((b) => b == _currentBook.name);

    if (forward) {
      if (_currentChapter.chapter < _currentBook.chapters.length) {
        setState(() {
          _currentChapter = _currentBook.chapters[_currentChapter.chapter];
        });
      } else if (currentBookIndex < books.length - 1) {
        final nextBookName = books[currentBookIndex + 1];
        final nextBook = await loadBook(_currentTranslation, nextBookName);
        setState(() {
          _currentBook = nextBook;
          _currentChapter = nextBook.chapters.first;
        });
      }
    } else {
      if (_currentChapter.chapter > 1) {
        setState(() {
          _currentChapter = _currentBook.chapters[_currentChapter.chapter - 2];
        });
      } else if (currentBookIndex > 0) {
        final prevBookName = books[currentBookIndex - 1];
        final prevBook = await loadBook(_currentTranslation, prevBookName);
        setState(() {
          _currentBook = prevBook;
          _currentChapter = prevBook.chapters.last;
        });
      }
    }
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
