import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider.dart';
import '../models/translation.dart';
import '../utils.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: provider.themeMode,
              onChanged: (newMode) {
                if (newMode != null) {
                  provider.setThemeMode(newMode);
                }
              },
              items: ThemeMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(capitalize(mode.toString().split('.').last)),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: Text('Translation'),
            trailing: DropdownButton<String>(
              value: provider.translation.acronym,
              onChanged: (newTranslation) {
                if (newTranslation != null) {
                  provider.setTranslation(newTranslation);
                }
              },
              items: SettingsConstants.translations.map((translation) {
                return DropdownMenuItem(
                  value: translation,
                  child: Text(translation),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
