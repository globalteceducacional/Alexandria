import 'package:flutter/foundation.dart';

import '../../core/api/ebook_api_client.dart';
import '../../core/services/favorite_service.dart';
import '../../core/storage/favorites_notifier.dart';

class FavoriteViewModel extends ChangeNotifier {
  FavoriteViewModel(this._api);

  final EbookApiClient _api;
  final Map<String, Set<String>> _favoritesByUser = <String, Set<String>>{};
  final Map<String, List<String>> _favoriteOrderByUser = <String, List<String>>{};
  final Set<String> _loadedUsers = <String>{};

  Set<String> idsForUser(String userId) {
    return _favoritesByUser[userId] ?? <String>{};
  }

  List<String> orderedIdsForUser(String userId) {
    return List<String>.from(_favoriteOrderByUser[userId] ?? const []);
  }

  Future<void> ensureLoaded(String userId) async {
    if (userId.isEmpty || _loadedUsers.contains(userId)) return;
    try {
      final rows = await _api.fetchFavouriteListRows(userId);
      final ordered = rows
          .map((r) => (r['bookid'] ?? r['book_id'] ?? r['id'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toList();
      _favoriteOrderByUser[userId] = ordered;
      _favoritesByUser[userId] = ordered.toSet();
      _loadedUsers.add(userId);
      await FavoriteService.setIdsForUser(userId, ordered.toSet());
      notifyListeners();
    } catch (_) {
      final ids = await FavoriteService.getIdsForUser(userId);
      _favoritesByUser[userId] = ids;
      _favoriteOrderByUser[userId] = ids.toList();
      _loadedUsers.add(userId);
      notifyListeners();
    }
  }

  bool isFavorite(String userId, String bookId) {
    final set = _favoritesByUser[userId];
    if (set == null) return false;
    return set.contains(bookId);
  }

  Future<void> toggleFavorite(String userId, String bookId) async {
    if (userId.isEmpty || bookId.isEmpty) return;
    final current = _favoritesByUser[userId] ?? <String>{};
    final willFavourite = !current.contains(bookId);

    final updated = Set<String>.from(current);
    final ordered = List<String>.from(_favoriteOrderByUser[userId] ?? []);
    if (willFavourite) {
      updated.add(bookId);
      ordered.remove(bookId);
      ordered.insert(0, bookId);
    } else {
      updated.remove(bookId);
      ordered.remove(bookId);
    }
    _favoritesByUser[userId] = updated;
    _favoriteOrderByUser[userId] = ordered;
    _loadedUsers.add(userId);
    notifyListeners();

    try {
      final result = await _api.toggleFavourite(userId, bookId);
      if (result) {
        if (!updated.contains(bookId)) {
          updated.add(bookId);
          ordered.remove(bookId);
          ordered.insert(0, bookId);
        }
      } else {
        updated.remove(bookId);
        ordered.remove(bookId);
      }
      _favoritesByUser[userId] = updated;
      _favoriteOrderByUser[userId] = ordered;
      await FavoriteService.setIdsForUser(userId, updated);
      notifyListeners();
      FavoritesNotifier.instance.notifyFavoritesChanged();
    } catch (e) {
      debugPrint('[Favorites] toggle: fallback local — $e');
      await FavoriteService.setIdsForUser(userId, updated);
      FavoritesNotifier.instance.notifyFavoritesChanged();
    }
  }

  /// Recarrega favoritos do servidor (ex.: após abrir o perfil).
  Future<void> refresh(String userId) async {
    if (userId.isEmpty) return;
    _loadedUsers.remove(userId);
    await ensureLoaded(userId);
    FavoritesNotifier.instance.notifyFavoritesChanged();
  }
}
