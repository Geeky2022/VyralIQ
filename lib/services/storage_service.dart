import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/generation_result.dart';

/// Local persistence for saved content (history).
class StorageService {
  static const _historyKey = 'vyraliq_history';
  static const _foldersKey = 'vyraliq_folders';
  static const _streakKey = 'vyraliq_streak';
  static const _lastActiveKey = 'vyraliq_last_active';

  // ---------------------------------------------------------------------------
  // History (saved generation results)
  // ---------------------------------------------------------------------------

  /// Saves a GenerationResult to history.
  Future<void> saveResult(GenerationResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    // Add with timestamp
    final entry = result.toJson();
    entry['savedAt'] = DateTime.now().toIso8601String();
    entry['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    history.add(jsonEncode(entry));

    await prefs.setStringList(
      _historyKey,
      history,
    );

    await _updateStreak(prefs);
  }

  /// Loads all saved history entries, newest first.
  Future<List<GenerationResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw.reversed.map((s) {
      final json = jsonDecode(s) as Map<String, dynamic>;
      return GenerationResult.fromJson(json);
    }).toList();
  }

  /// Returns raw entries with metadata (id, savedAt).
  Future<List<Map<String, dynamic>>> getHistoryRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw.reversed.map((s) {
      return jsonDecode(s) as Map<String, dynamic>;
    }).toList();
  }

  /// Deletes a single entry by its id.
  Future<void> deleteResult(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    raw.removeWhere((s) {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return j['id'] == id;
    });
    await prefs.setStringList(_historyKey, raw);
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Returns the total number of saved items.
  Future<int> getHistoryCount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw.length;
  }

  // ---------------------------------------------------------------------------
  // Folders
  // ---------------------------------------------------------------------------

  /// Gets all folder names.
  Future<List<String>> getFolders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_foldersKey) ?? [];
  }

  /// Creates a new folder.
  Future<void> createFolder(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final folders = await getFolders();
    if (!folders.contains(name)) {
      folders.add(name);
      await prefs.setStringList(_foldersKey, folders);
    }
  }

  /// Deletes a folder.
  Future<void> deleteFolder(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final folders = await getFolders();
    folders.remove(name);
    await prefs.setStringList(_foldersKey, folders);
  }

  // ---------------------------------------------------------------------------
  // Streak Tracking
  // ---------------------------------------------------------------------------

  Future<void> _updateStreak(SharedPreferences prefs) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActiveStr = prefs.getString(_lastActiveKey);
    int streak = prefs.getInt(_streakKey) ?? 0;

    if (lastActiveStr != null) {
      final lastActive = DateTime.parse(lastActiveStr);
      final lastDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 0) {
        // Already active today, no change
        return;
      } else if (diff == 1) {
        // Consecutive day
        streak += 1;
      } else {
        // Streak broken
        streak = 1;
      }
    } else {
      streak = 1;
    }

    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastActiveKey, today.toIso8601String());
  }

  /// Gets the current daily streak.
  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }
}
