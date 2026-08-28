import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {
  WishlistService._();

  static String _keyForUser(String userId) => 'wishlist_$userId';

  static Future<Set<String>> _loadForUser(String userId) async {
    if (userId.isEmpty) return <String>{};
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> _saveForUser(String userId, Set<String> ids) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForUser(userId), jsonEncode(ids.toList()));
  }

  static Future<Set<String>> getIdsForUser(String userId) {
    return _loadForUser(userId);
  }

  static Future<void> setIdsForUser(String userId, Set<String> ids) async {
    await _saveForUser(userId, ids);
  }

  static Future<bool> toggle(String userId, String bookId) async {
    if (userId.isEmpty || bookId.isEmpty) return false;
    final set = await _loadForUser(userId);
    if (set.contains(bookId)) {
      set.remove(bookId);
    } else {
      set.add(bookId);
    }
    await _saveForUser(userId, set);
    return set.contains(bookId);
  }
}

