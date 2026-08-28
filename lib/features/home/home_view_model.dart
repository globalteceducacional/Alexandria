import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;

import '../../core/api/ebook_api_client.dart';
import '../../core/models/author.dart';
import '../../core/models/book.dart';
import '../../core/models/category.dart';
import '../../core/models/home_data.dart';
import '../../core/models/home_section.dart';
import '../../core/services/reading_progress_service.dart';
import '../../core/utils/html_decode.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._api);

  final EbookApiClient _api;

  EbookApiClient get api => _api;

  HomeData? _homeData;
  List<Category> _categories = [];
  List<Book> _searchResults = [];
  List<Author> _searchAuthorResults = [];
  List<HomeSection> _sections = [];
  List<Author> _authors = [];
  List<Book> _featuredRandomBooks = [];
  List<Book> _continueReadingBooks = [];
  List<Book> _searchBookIndex = [];
  int? _searchBookIndexAcervoId;
  Map<String, ReadingProgress> _readingProgressMap = {};
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  HomeData? get homeData => _homeData;
  List<Category> get categories => _categories;
  List<Book> get searchResults => _searchResults;
  List<Author> get searchAuthorResults => _searchAuthorResults;
  List<HomeSection> get sections => _sections;
  List<Author> get authors => _authors;
  List<Book> get featuredRandomBooks => _featuredRandomBooks;
  List<Book> get continueReadingBooks => _continueReadingBooks;
  Map<String, ReadingProgress> get readingProgressMap => _readingProgressMap;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  ReadingProgress? progressForBook(String bookId) =>
      _readingProgressMap[bookId];

  Future<void> loadHome({int? acervoId, String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    debugPrint(
      '[Home] loadHome acervoId=$acervoId userId=$userId',
    );
    try {
      final results = await Future.wait([
        _api.fetchHome(acervoId: acervoId),
        _api.fetchCategories(acervoId: acervoId),
        _api.fetchHomeSectionsWithBooks(acervoId: acervoId),
        _api.fetchAuthors(acervoId: acervoId),
      ]);
      _homeData = results[0] as HomeData;
      _categories = results[1] as List<Category>;
      _sections = results[2] as List<HomeSection>;
      _authors = results[3] as List<Author>;

      _featuredRandomBooks = _buildRandomFeaturedBooks();
      _readingProgressMap = await ReadingProgressService.getAll();
      debugPrint(
        '[Home] loadHome: carregou ${_readingProgressMap.length} '
        'entradas de progresso',
      );

      if (userId != null && userId.isNotEmpty) {
        try {
          _continueReadingBooks = await _api.fetchContinueReading(userId);
          debugPrint(
            '[Home] loadHome: continueReadingBooks='
            '${_continueReadingBooks.map((b) => b.id).join(',')}',
          );
          for (final b in _continueReadingBooks) {
            if (b.currentPage != null &&
                b.totalPages != null &&
                b.totalPages! > 0) {
              final progress = ReadingProgress(
                bookId: b.id,
                currentPage: b.currentPage!,
                totalPages: b.totalPages!,
              );
              _readingProgressMap[b.id] = progress;
              debugPrint(
                '[Home] loadHome: progresso remoto para bookId=${b.id} '
                'page=${b.currentPage}/${b.totalPages}',
              );
            }
          }
        } catch (e) {
          debugPrint('[Home] loadHome: erro em fetchContinueReading: $e');
          _continueReadingBooks = <Book>[];
        }
      }
    } catch (e, s) {
      _error = 'Falha ao carregar a biblioteca. Verifique sua conexão.';
      debugPrint('Erro HomeViewModel.loadHome: $e\n$s');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Book> _buildRandomFeaturedBooks() {
    final home = _homeData;
    if (home == null) return <Book>[];

    final pool = <Book>[
      ...home.featuredBooks,
      ...home.latestBooks,
      ...home.popularBooks,
    ];

    if (pool.isEmpty) return <Book>[];

    final Map<String, Book> uniqueById = <String, Book>{};
    for (final book in pool) {
      if (book.id.isEmpty) {
        continue;
      }
      uniqueById.putIfAbsent(book.id, () => book);
    }

    final allBooks = uniqueById.values.toList();
    if (allBooks.isEmpty) return <Book>[];

    allBooks.shuffle();
    final count = allBooks.length < 5 ? allBooks.length : 5;
    return allBooks.take(count).toList();
  }

  Future<void> search(String text, {int? acervoId}) async {
    final query = text.trim();
    if (query.isEmpty) {
      _searchResults = [];
      _searchAuthorResults = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    try {
      await _ensureSearchBookIndex(acervoId: acervoId);
      _searchResults = _rankBooks(_searchBookIndex, query);
      _searchAuthorResults = _rankAuthors(_authors, query);
    } catch (e) {
      _searchResults = [];
      _searchAuthorResults = [];
      debugPrint('Erro na pesquisa: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchAuthorResults = [];
    notifyListeners();
  }

  Future<void> _ensureSearchBookIndex({int? acervoId}) async {
    final hasSameContext = _searchBookIndexAcervoId == acervoId;
    if (hasSameContext && _searchBookIndex.isNotEmpty) {
      return;
    }

    try {
      final apiBooks = await _api.fetchAllBooks(acervoId: acervoId);
      if (apiBooks.isNotEmpty) {
        _searchBookIndex = _uniqueBooksById(apiBooks);
      } else {
        _searchBookIndex = _collectFallbackBooks();
      }
    } catch (e) {
      debugPrint('Erro ao montar índice de busca: $e');
      _searchBookIndex = _collectFallbackBooks();
    } finally {
      _searchBookIndexAcervoId = acervoId;
    }
  }

  List<Book> _collectFallbackBooks() {
    final pool = <Book>[
      ...?_homeData?.featuredBooks,
      ...?_homeData?.latestBooks,
      ...?_homeData?.popularBooks,
      for (final section in _sections) ...section.books,
      ..._continueReadingBooks,
    ];
    return _uniqueBooksById(pool);
  }

  List<Book> _uniqueBooksById(List<Book> books) {
    final map = <String, Book>{};
    for (final book in books) {
      if (book.id.isEmpty) {
        continue;
      }
      map.putIfAbsent(book.id, () => book);
    }
    return map.values.toList();
  }

  List<Book> _rankBooks(List<Book> source, String query) {
    final normalizedQuery = _normalizeSearchText(query);
    final scored = <_Scored<Book>>[];
    for (final book in source) {
      final title = _normalizeSearchText(book.title);
      final description = _normalizeSearchText(cleanHtmlText(book.description));
      final author = _normalizeSearchText(book.authorName);
      final score = _bookScore(
        title: title,
        description: description,
        author: author,
        query: normalizedQuery,
      );
      if (score < 100) {
        scored.add(_Scored(item: book, score: score));
      }
    }
    scored.sort((a, b) {
      final byScore = a.score.compareTo(b.score);
      if (byScore != 0) {
        return byScore;
      }
      return a.item.title.toLowerCase().compareTo(b.item.title.toLowerCase());
    });
    return scored.map((e) => e.item).toList();
  }

  List<Author> _rankAuthors(List<Author> source, String query) {
    final normalizedQuery = _normalizeSearchText(query);
    final scored = <_Scored<Author>>[];
    for (final author in source) {
      final name = _normalizeSearchText(author.name);
      final description = _normalizeSearchText(cleanHtmlText(author.description));
      final score = _authorScore(
        name: name,
        description: description,
        query: normalizedQuery,
      );
      if (score < 100) {
        scored.add(_Scored(item: author, score: score));
      }
    }
    scored.sort((a, b) {
      final byScore = a.score.compareTo(b.score);
      if (byScore != 0) {
        return byScore;
      }
      return a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase());
    });
    return scored.map((e) => e.item).toList();
  }

  int _bookScore({
    required String title,
    required String description,
    required String author,
    required String query,
  }) {
    if (title.startsWith(query)) return 0;
    if (title.contains(query)) return 1;
    if (description.startsWith(query)) return 2;
    if (description.contains(query)) return 3;
    if (author.startsWith(query)) return 4;
    if (author.contains(query)) return 5;
    return 100;
  }

  int _authorScore({
    required String name,
    required String description,
    required String query,
  }) {
    if (name.startsWith(query)) return 0;
    if (name.contains(query)) return 1;
    if (description.startsWith(query)) return 2;
    if (description.contains(query)) return 3;
    return 100;
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> refreshReadingProgress() async {
    _readingProgressMap = await ReadingProgressService.getAll();
    debugPrint(
      '[Home] refreshReadingProgress: agora temos '
      '${_readingProgressMap.length} entradas',
    );
    notifyListeners();
  }
}

class _Scored<T> {
  _Scored({required this.item, required this.score});
  final T item;
  final int score;
}
