import 'package:flutter/foundation.dart';

import '../../core/api/ebook_api_client.dart';
import '../../core/services/wishlist_service.dart';

class WishlistViewModel extends ChangeNotifier {
  WishlistViewModel(this._api);

  final EbookApiClient _api;

  final Map<String, Set<String>> _wishlistByUser = <String, Set<String>>{};
  final Set<String> _loadedUsers = <String>{};

  Set<String> idsForUser(String userId) {
    return _wishlistByUser[userId] ?? <String>{};
  }

  Future<void> ensureLoaded(String userId) async {
    if (userId.isEmpty || _loadedUsers.contains(userId)) return;
    try {
      final remoteIds = await _api.fetchWishlistIds(userId);
      _wishlistByUser[userId] = remoteIds;
      _loadedUsers.add(userId);
      await WishlistService.setIdsForUser(userId, remoteIds);
      notifyListeners();
    } catch (_) {
      final ids = await WishlistService.getIdsForUser(userId);
      _wishlistByUser[userId] = ids;
      _loadedUsers.add(userId);
      notifyListeners();
    }
  }

  bool isInWishlist(String userId, String bookId) {
    final set = _wishlistByUser[userId];
    if (set == null) return false;
    return set.contains(bookId);
  }

  Future<void> toggle(String userId, String bookId) async {
    if (userId.isEmpty || bookId.isEmpty) return;
    final current = _wishlistByUser[userId] ?? <String>{};
    final willAdd = !current.contains(bookId);

    final updated = Set<String>.from(current);
    if (willAdd) {
      updated.add(bookId);
    } else {
      updated.remove(bookId);
    }
    _wishlistByUser[userId] = updated;
    _loadedUsers.add(userId);
    notifyListeners();

    try {
      final isNowInServer = await _api.toggleWishlist(userId, bookId);
      if (isNowInServer) {
        updated.add(bookId);
      } else {
        updated.remove(bookId);
      }
      _wishlistByUser[userId] = updated;
      await WishlistService.setIdsForUser(userId, updated);
      notifyListeners();
    } catch (e) {
      debugPrint('[Wishlist] toggle: fallback local — $e');
      await WishlistService.setIdsForUser(userId, updated);
    }
  }

  /// Remove da lista Ler Depois se o livro estiver nela (ex.: leitura concluída).
  Future<void> removeIfPresent(String userId, String bookId) async {
    if (userId.isEmpty || bookId.isEmpty) return;
    await ensureLoaded(userId);
    if (!isInWishlist(userId, bookId)) return;
    await toggle(userId, bookId);
  }
}

