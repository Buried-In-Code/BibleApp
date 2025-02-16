import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/provider.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  _CalendarTabState createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Daily Readings')),
      body: Center(child: Text('Daily Readings')),
    );
  }
}
