import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReadingProgress {
  const ReadingProgress({
    required this.bookId,
    required this.currentPage,
    required this.totalPages,
  });

  final String bookId;
  final int currentPage;
  final int totalPages;

  double get fraction =>
      totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0;

  int get percent => (fraction * 100).round();

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      bookId: json['bookId'] as String? ?? '',
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'currentPage': currentPage,
      'totalPages': totalPages,
    };
  }
}

class ReadingProgressService {
  ReadingProgressService._();

  static const _key = 'reading_progress';

  static Future<Map<String, ReadingProgress>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) =>
          MapEntry(k, ReadingProgress.fromJson(v as Map<String, dynamic>)));
    } catch (_) {
      return {};
    }
  }

  static Future<void> _saveAll(Map<String, ReadingProgress> all) async {
    final prefs = await SharedPreferences.getInstance();
    final map = all.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_key, jsonEncode(map));
  }

  static Future<void> save({
    required String bookId,
    required int currentPage,
    required int totalPages,
  }) async {
    final all = await _loadAll();
    all[bookId] = ReadingProgress(
      bookId: bookId,
      currentPage: currentPage,
      totalPages: totalPages,
    );
    await _saveAll(all);
  }

  static Future<ReadingProgress?> get(String bookId) async {
    final all = await _loadAll();
    return all[bookId];
  }

  static Future<Map<String, ReadingProgress>> getAll() async {
    return _loadAll();
  }
}
