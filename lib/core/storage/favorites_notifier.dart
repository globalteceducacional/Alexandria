import 'package:flutter/foundation.dart';

/// Dispara atualização da prévia de favoritos no perfil após toggle.
class FavoritesNotifier extends ChangeNotifier {
  FavoritesNotifier._();

  static final FavoritesNotifier instance = FavoritesNotifier._();

  void notifyFavoritesChanged() => notifyListeners();
}
