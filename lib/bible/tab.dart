import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../models/bible.dart';
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
              builder: (_) => ChapterSelector(initialBook: args['book']),
            );
          case '/versesScreen':
            return MaterialPageRoute(
              builder:
                  (_) => VersesScreen(
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
      appBar: AppBar(title: Text('Bible'), automaticallyImplyLeading: false),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: Constants.BOOKS.length,
        itemBuilder: (context, index) {
          final book = Constants.BOOKS[index];

          return ElevatedButton(
            onPressed: () async {
              final loadedBook = await loadBook(provider.translation, book);
              Navigator.of(
                context,
                rootNavigator: false,
              ).pushNamed('/chapterSelector', arguments: {'book': loadedBook});
            },
            child: Text(
              book,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          );
        },
      ),
    );
  }
}

class ChapterSelector extends StatefulWidget {
  final Book initialBook;

  const ChapterSelector({super.key, required this.initialBook});

  @override
  _ChapterSelectorState createState() => _ChapterSelectorState();
}

class _ChapterSelectorState extends State<ChapterSelector> {
  late String _translation;
  late Book _book;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    _translation = provider.translation;
    _book = widget.initialBook;
  }

  Future<void> _loadTranslation() async {
    final newBook = await loadBook(_translation, _book.name);
    setState(() {
      _book = newBook;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    if (_translation != provider.translation) {
      _translation = provider.translation;
      _loadTranslation();
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/bookSelector');
          },
        ),
        title: Text(_book.name),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _book.chapters.length,
        itemBuilder: (context, index) {
          final chapter = _book.chapters[index];

          return ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/versesScreen',
                arguments: {'book': _book, 'chapter': chapter},
              );
            },
            child: Text(
              '${chapter.value}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          );
        },
      ),
    );
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
  late String _translation;
  late Book _book;
  late Chapter _chapter;
  final FlutterTts _tts = FlutterTts();
  int _verseIndex = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    _translation = provider.translation;
    _book = widget.initialBook;
    _chapter = widget.initialChapter;

    _tts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _speak() async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _verseIndex = 0;
        _isPlaying = true;
      });

      _tts.setCompletionHandler(() {
        _playNextVerse();
      });
      await _tts.speak('${_book.name} Chapter ${_chapter.value}');
    }
  }

  void _playNextVerse() {
    if (!_isPlaying || _verseIndex >= _chapter.verses.length) {
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    final verse = _chapter.verses[_verseIndex];
    _tts.speak(
      verse.text
          .replaceAll('`', '\'')
          .replaceAll('<FI>', '')
          .replaceAll('<Fi>', ''),
    );
    _verseIndex++;
  }

  Future<void> _loadTranslation() async {
    await _tts.stop();
    final newBook = await loadBook(_translation, _book.name);
    setState(() {
      _book = newBook;
      _chapter = newBook.chapters.firstWhere(
        (c) => c.value == _chapter.value,
        orElse: () => newBook.chapters.first,
      );
    });
  }

  Future<void> _navigateForward() async {
    await _tts.stop();
    final bookIndex = Constants.BOOKS.indexWhere((b) => b == _book.name);

    if (_chapter.value < _book.chapters.length) {
      setState(() {
        _chapter = _book.chapters[_chapter.value];
      });
    } else if (bookIndex < Constants.BOOKS.length - 1) {
      final newBook = await loadBook(
        _translation,
        Constants.BOOKS[bookIndex + 1],
      );
      setState(() {
        _book = newBook;
        _chapter = newBook.chapters.first;
      });
    }
  }

  Future<void> _navigateBackward() async {
    await _tts.stop();
    final bookIndex = Constants.BOOKS.indexWhere((b) => b == _book.name);

    if (_chapter.value > 1) {
      setState(() {
        _chapter = _book.chapters[_chapter.value - 2];
      });
    } else if (bookIndex > 0) {
      final newBook = await loadBook(
        _translation,
        Constants.BOOKS[bookIndex - 1],
      );
      setState(() {
        _book = newBook;
        _chapter = newBook.chapters.last;
      });
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
      spans.add(
        TextSpan(
          text: italicText,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    if (_translation != provider.translation) {
      _translation = provider.translation;
      _loadTranslation();
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamed('/chapterSelector', arguments: {'book': _book});
          },
        ),
        title: Text('[$_translation] ${_book.name} ${_chapter.value}'),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _navigateForward();
          } else if (details.primaryVelocity! > 0) {
            _navigateBackward();
          }
        },
        child: ListView.builder(
          itemCount: _chapter.verses.length,
          itemBuilder: (context, index) {
            final verse = _chapter.verses[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30.0,
                    child: Text(
                      '${verse.value}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
      floatingActionButton:
          provider.ttsEnabled
              ? FloatingActionButton(
                onPressed: _speak,
                child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              )
              : null,
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
