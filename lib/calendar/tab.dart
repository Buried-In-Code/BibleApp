import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bible.dart';
import '../models/plan.dart';
import '../settings/provider.dart';
import '../utils.dart';

class CalendarTab extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Function(int) onTabSelected;

  const CalendarTab({
    super.key,
    required this.navigatorKey,
    required this.onTabSelected,
  });

  @override
  _CalendarTabState createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime selectedDate = DateTime.now();

  Future<void> _changeDate(int amount) async {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: amount));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text('Daily Readings')),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _changeDate(1);
          } else if (details.primaryVelocity! > 0) {
            _changeDate(-1);
          }
        },
        child: FutureBuilder<Plan>(
          future: getPlan(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading readings'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No readings found'));
            }

            final plan = snapshot.data!;
            final entry = plan.entries.cast<Entry?>().firstWhere(
              (x) =>
                  x!.month == selectedDate.month && x.day == selectedDate.day,
              orElse: () => null,
            );

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left),
                            onPressed: () => _changeDate(-1),
                          ),
                          Text(
                            formatDate(selectedDate),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right),
                            onPressed: () => _changeDate(1),
                          ),
                        ],
                      ),
                      if (!isSameDay(selectedDate, today))
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedDate = today;
                              });
                            },
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      entry == null
                          ? Center(
                            child: Text(
                              'No readings found for today',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _buildSection(
                                'First Portion',
                                provider.translation,
                                entry.firstPortion,
                              ),
                              _buildSection(
                                'Second Portion',
                                provider.translation,
                                entry.secondPortion,
                              ),
                              _buildSection(
                                'Third Portion',
                                provider.translation,
                                entry.thirdPortion,
                              ),
                            ],
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildSection(
    String title,
    String translation,
    List<Reading> readings,
  ) {
    if (readings.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Column(
            children:
                readings.map((reading) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final book = await loadBook(
                            translation,
                            reading.book,
                          );
                          widget.navigatorKey.currentState?.pushNamed(
                            '/versesScreen',
                            arguments: {
                              'book': book,
                              'chapter': book.chapters[reading.chapter - 1],
                            },
                          );
                          widget.onTabSelected(1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '${reading.book} ${reading.chapter}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
