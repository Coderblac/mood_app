import 'dart:convert';
import 'package:mood_app/models/mood_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodStorageService {
  static const String _key = 'mood_entries';

  Future<List<MoodEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) {
      try {
        return MoodEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<MoodEntry>().toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveEntry(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    existing.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, existing);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}