import 'package:flutter/foundation.dart';

import '../../core/api/ebook_api_client.dart';
import '../../core/models/book.dart';

class BookDetailViewModel extends ChangeNotifier {
  BookDetailViewModel(this._api, {required this.userId});

  final EbookApiClient _api;
  final String userId;

  Book? _book;

  Book? get book => _book;

  Future<void> load(String bookId) async {
    try {
      _book = await _api.fetchBookDetail(
        bookId,
        userId: userId.isNotEmpty ? int.tryParse(userId) : null,
      );
      notifyListeners();
    } catch (e, s) {
      debugPrint('BookDetailViewModel.load: $e\n$s');
    }
  }

  Future<void> saveContinueReading(String userId, String bookId) async {
    try {
      await _api.saveContinueReading(userId, bookId);
    } catch (e) {
      debugPrint('Erro ao salvar leitura contínua: $e');
    }
  }
}
