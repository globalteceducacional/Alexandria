import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/app_user.dart';
import '../models/author.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../models/home_data.dart';
import '../models/home_section.dart';

/// Cliente do leitor: espelho PHP no Kotlin (`user_*.php` + `api.php`).
/// Sem JWT — o backend identifica o leitor por `user_id` / e-mail.
class EbookApiClient {
  EbookApiClient({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  final http.Client _client;

  String? _userId;
  int? _acervoId;

  void setReaderContext({String? userId, int? acervoId}) {
    _userId = userId;
    _acervoId = acervoId;
  }

  /// Compatível com chamadas antigas; o leitor não usa JWT.
  void setSession({String? accessToken, int? schoolId}) {
    _acervoId = schoolId ?? _acervoId;
  }

  void clearSession() {
    _userId = null;
    _acervoId = null;
  }

  Map<String, String> _readerQuery([Map<String, String>? extra]) {
    final query = <String, String>{...?extra};
    final userId = _userId;
    if (userId != null && userId.isNotEmpty) {
      query.putIfAbsent('user_id', () => userId);
    }
    final acervoId = _acervoId;
    if (acervoId != null) {
      query.putIfAbsent('acervo_id', () => acervoId.toString());
    }
    return query;
  }

  Uri _siteUri(String url, [Map<String, String>? query]) {
    return Uri.parse(url).replace(
      queryParameters: query == null || query.isEmpty ? null : query,
    );
  }

  Uri _apiUri(String methodName, [Map<String, String>? extra]) {
    return _siteUri(AppConfig.apiBaseUrl, _readerQuery({
      'method_name': methodName,
      ...?extra,
    }));
  }

  Map<String, String> _headers({bool form = false, bool jsonBody = false}) {
    return <String, String>{
      'accept': '*/*',
      if (form) 'Content-Type': 'application/x-www-form-urlencoded',
      if (jsonBody) 'Content-Type': 'application/json',
    };
  }

  bool _looksLikeHtml(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('text/html')) return true;
    final start = response.body.trimLeft();
    return start.startsWith('<!DOCTYPE') ||
        start.startsWith('<!doctype') ||
        start.startsWith('<html');
  }

  Future<dynamic> _decode(http.Response response, Uri uri) async {
    debugPrint('[API] ${response.request?.method ?? '?'} $uri → ${response.statusCode}');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('[API] erro HTTP ${response.statusCode}: ${response.body}');
      throw Exception('HTTP ${response.statusCode} → ${uri.path}');
    }
    if (_looksLikeHtml(response)) {
      throw Exception(
        'O servidor devolveu HTML em vez da API do leitor '
        '(${uri.path}). Confirme o proxy nginx das rotas .php.',
      );
    }
    if (response.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  dynamic _unwrapEnvelope(dynamic decoded) {
    if (decoded is! Map) return decoded;
    if (decoded.containsKey('EBOOK_APP')) return decoded['EBOOK_APP'];
    if (decoded.containsKey('Galileu')) return decoded['Galileu'];
    return decoded;
  }

  Map<String, dynamic>? _firstMap(dynamic unwrapped) {
    if (unwrapped is List && unwrapped.isNotEmpty && unwrapped.first is Map) {
      return Map<String, dynamic>.from(unwrapped.first as Map);
    }
    if (unwrapped is Map<String, dynamic>) return unwrapped;
    if (unwrapped is Map) return Map<String, dynamic>.from(unwrapped);
    return null;
  }

  List<Map<String, dynamic>> _asMapList(dynamic unwrapped) {
    if (unwrapped is List) {
      return unwrapped
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  bool _isSuccess(Map<String, dynamic>? item) {
    if (item == null) return false;
    final raw = item['success'] ?? item['sucess'] ?? '';
    return '$raw' == '1';
  }

  Future<dynamic> _getApi(String methodName, [Map<String, String>? extra]) async {
    final uri = _apiUri(methodName, extra);
    final response = await _client.get(uri, headers: _headers());
    return _unwrapEnvelope(await _decode(response, uri));
  }

  Future<dynamic> _postForm(Uri uri, Map<String, String> fields) async {
    final response = await _client.post(
      uri,
      headers: _headers(form: true),
      body: fields,
    );
    return _unwrapEnvelope(await _decode(response, uri));
  }

  // ─── autenticação ─────────────────────────────────────────────────────────

  /// Login de leitor (`POST user_login_api.php`, form, sem JWT).
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String type = 'Normal',
    String authId = '',
  }) async {
    final uri = _siteUri(AppConfig.loginUrl);
    final decoded = await _postForm(uri, {
      'email': email.trim(),
      'password': password,
      'type': type,
      'auth_id': authId,
    });

    final item = _firstMap(decoded);
    if (item == null) {
      return {'success': '0', 'MSG': 'Resposta inválida do servidor.'};
    }
    if (!_isSuccess(item)) {
      return {
        'success': '0',
        'MSG': item['MSG']?.toString() ??
            item['msg']?.toString() ??
            'Credenciais inválidas.',
      };
    }

    final userId = '${item['user_id'] ?? item['id'] ?? ''}'.trim();
    final acervoId = int.tryParse(
      '${item['acervo_id'] ?? item['acervoId'] ?? item['school_id'] ?? ''}',
    );
    if (userId.isNotEmpty) {
      setReaderContext(userId: userId, acervoId: acervoId);
    }

    return {
      'success': '1',
      'user_id': item['user_id'] ?? item['id'] ?? 0,
      'name': item['name']?.toString() ?? email,
      'email': item['email']?.toString() ?? email,
      'phone': item['phone']?.toString() ?? '',
      'user_image': item['user_image']?.toString() ?? '',
      'auth_id': item['auth_id']?.toString() ?? authId,
      'acervo_id': acervoId,
      'MSG': item['MSG']?.toString() ?? item['msg']?.toString() ?? '',
    };
  }

  Future<AppUser?> fetchUserProfile(String userId) async {
    try {
      final uri = _siteUri(AppConfig.profileUrl, {'id': userId});
      final response = await _client.get(uri, headers: _headers());
      final item = _firstMap(
        _unwrapEnvelope(await _decode(response, uri)),
      );
      if (item == null || !_isSuccess(item)) return null;
      return AppUser.fromJson(item);
    } catch (e) {
      debugPrint('[API] fetchUserProfile: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required AppUser currentUser,
    required String name,
    String phone = '',
    String newPassword = '',
    String? localImagePath,
  }) async {
    try {
      final uri = _siteUri(AppConfig.profileUpdateUrl);
      final request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = currentUser.id.toString();
      request.fields['name'] = name;
      request.fields['email'] = currentUser.email;
      request.fields['phone'] = phone;
      if (newPassword.isNotEmpty) {
        request.fields['password'] = newPassword;
      }
      final imagePath = localImagePath;
      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.startsWith('http')) {
        request.files.add(
          await http.MultipartFile.fromPath('user_image', imagePath),
        );
      }

      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);
      final item = _firstMap(
        _unwrapEnvelope(await _decode(response, uri)),
      );
      return _isSuccess(item);
    } catch (e) {
      debugPrint('[API] updateUserProfile: $e');
      return false;
    }
  }

  // ─── catálogo ─────────────────────────────────────────────────────────────

  Future<HomeData> fetchHome({int? acervoId}) async {
    if (acervoId != null) _acervoId = acervoId;
    final decoded = await _getApi('home');
    if (decoded is Map<String, dynamic>) {
      return HomeData.fromJson(decoded);
    }
    if (decoded is Map) {
      return HomeData.fromJson(Map<String, dynamic>.from(decoded));
    }
    return HomeData(
      featuredBooks: const [],
      latestBooks: const [],
      popularBooks: const [],
    );
  }

  Future<List<Book>> fetchLatestBooks({int? acervoId}) async {
    if (acervoId != null) _acervoId = acervoId;
    return _asMapList(await _getApi('latest')).map(Book.fromJson).toList();
  }

  Future<List<Book>> fetchAllBooks({int? acervoId}) async {
    if (acervoId != null) _acervoId = acervoId;
    return _asMapList(await _getApi('allbook'))
        .map(Book.fromJson)
        .where((b) => b.id.isNotEmpty)
        .toList();
  }

  Future<Book?> fetchBookDetail(String bookId, {int? userId}) async {
    final extra = <String, String>{
      'book_id': bookId,
      if (userId != null) 'user_id': userId.toString(),
    };
    final rows = _asMapList(await _getApi('book_id', extra));
    if (rows.isEmpty) return null;
    return Book.fromJson(rows.first);
  }

  Future<List<Book>> fetchBooksByCategory(String catId, {int? acervoId}) async {
    if (acervoId != null) _acervoId = acervoId;
    return _asMapList(await _getApi('cat_id', {'cat_id': catId}))
        .map(Book.fromJson)
        .toList();
  }

  Future<List<Book>> searchBooks(String text, {int? acervoId}) async {
    final q = text.trim();
    if (q.isEmpty) return [];
    if (acervoId != null) _acervoId = acervoId;
    return _asMapList(await _getApi('search_text', {'search_text': q}))
        .map(Book.fromJson)
        .toList();
  }

  Future<List<Category>> fetchCategories({int? acervoId}) async {
    if (acervoId != null) _acervoId = acervoId;
    return _asMapList(await _getApi('cat_list')).map(Category.fromJson).toList();
  }

  Future<List<Author>> fetchAuthors({int? acervoId}) async {
    if (acervoId != null) _acervoId = acervoId;
    return _asMapList(await _getApi('author_list')).map(Author.fromJson).toList();
  }

  Future<List<Book>> fetchBooksByAuthor(
    String authorId, {
    int? acervoId,
  }) async {
    if (acervoId != null) _acervoId = acervoId;
    return _asMapList(await _getApi('author_id', {'author_id': authorId}))
        .map(Book.fromJson)
        .toList();
  }

  Future<List<HomeSection>> fetchHomeSections({int? acervoId}) async {
    if (acervoId != null) _acervoId = acervoId;
    return _asMapList(await _getApi('home_section'))
        .map(HomeSection.fromJson)
        .toList();
  }

  Future<List<Book>> fetchHomeSectionBooks(
    String sectionId, {
    int page = 1,
    int? acervoId,
  }) async {
    if (acervoId != null) _acervoId = acervoId;
    return _asMapList(
      await _getApi('home_section_id', {
        'homesection_id': sectionId,
        'page': page.toString(),
      }),
    ).map(Book.fromJson).toList();
  }

  Future<List<HomeSection>> fetchHomeSectionsWithBooks({int? acervoId}) async {
    final sections = await fetchHomeSections(acervoId: acervoId);
    if (sections.isEmpty) return sections;

    final books = await fetchAllBooks(acervoId: acervoId);
    final byId = {for (final b in books) b.id: b};

    return sections.map((section) {
      final sectionBooks = section.bookIds
          .map((id) => byId[id])
          .whereType<Book>()
          .toList();
      return section.copyWith(books: sectionBooks);
    }).toList();
  }

  // ─── avaliação / leitura / comentários ────────────────────────────────────

  Future<bool> submitRating(String bookId, String userId, int rate) async {
    final item = _firstMap(
      await _getApi('submit_rating', {
        'user_id': userId,
        'book_id': bookId,
        'rate': rate.toString(),
      }),
    );
    return _isSuccess(item);
  }

  Future<int?> fetchUserRating(String bookId, String userId) async {
    final item = _firstMap(
      await _getApi('rating_check', {
        'user_id': userId,
        'book_id': bookId,
      }),
    );
    if (item == null) return null;
    if (!_isSuccess(item)) return null;
    return int.tryParse('${item['rate'] ?? ''}');
  }

  Future<void> saveContinueReading(
    String userId,
    String bookId, {
    int? currentPage,
    int? totalPages,
  }) async {
    await _getApi('continue_reading', {
      'con_user_id': userId,
      'con_book_id': bookId,
      if (currentPage != null) 'current_page': currentPage.toString(),
      if (totalPages != null) 'total_pages': totalPages.toString(),
    });
  }

  Future<List<Book>> fetchContinueReading(String userId) async {
    return _asMapList(
      await _getApi('con_reding_book', {'con_read_user_id': userId}),
    ).map(Book.fromJson).toList();
  }

  Future<bool> addComment(String bookId, String userId, String text) async {
    final item = _firstMap(
      await _getApi('add_comment', {
        'user_id': userId,
        'book_id': bookId,
        'comment_text': text,
      }),
    );
    return _isSuccess(item);
  }

  // ─── favoritos / wishlist ─────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchFavouriteListRows(
    String userId,
  ) async {
    final rows = _asMapList(await _getApi('favourite_list', {'user_id': userId}));
    return rows.map((row) {
      final id = '${row['book_id'] ?? row['bookid'] ?? row['id'] ?? ''}';
      return {
        ...row,
        'bookid': id,
        'id': id,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchFavouriteListRowsResolved(
    String userId, {
    int? limitRows,
  }) async {
    var raw = await fetchFavouriteListRows(userId);
    if (limitRows != null && raw.length > limitRows) {
      raw = raw.sublist(0, limitRows);
    }
    return raw;
  }

  Future<Set<String>> fetchFavouriteIds(String userId) async {
    final rows = await fetchFavouriteListRows(userId);
    return rows
        .map((r) => (r['bookid'] ?? r['book_id'] ?? r['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<bool> toggleFavourite(String userId, String bookId) async {
    final item = _firstMap(
      await _getApi('toggle_favourite', {
        'user_id': userId,
        'book_id': bookId,
      }),
    );
    return '${item?['is_favourite'] ?? ''}' == '1';
  }

  Future<Set<String>> fetchWishlistIds(String userId) async {
    final rows = _asMapList(await _getApi('wishlist_list', {'user_id': userId}));
    return rows
        .map((r) => '${r['book_id'] ?? r['id'] ?? ''}')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<bool> toggleWishlist(String userId, String bookId) async {
    final item = _firstMap(
      await _getApi('toggle_wishlist', {
        'user_id': userId,
        'book_id': bookId,
      }),
    );
    return '${item?['in_wishlist'] ?? ''}' == '1';
  }

  Future<List<Map<String, dynamic>>> fetchBookPageState(
    String userId,
    String bookId,
  ) async {
    return _asMapList(
      await _getApi('book_page_state_list', {
        'user_id': userId,
        'book_id': bookId,
      }),
    );
  }

  Future<void> saveBookPageState({
    required String userId,
    required String bookId,
    required int page,
    required bool isBookmark,
    String? note,
  }) async {
    await _getApi('book_page_state_save', {
      'user_id': userId,
      'book_id': bookId,
      'page': page.toString(),
      'is_bookmark': isBookmark ? '1' : '0',
      if (note != null) 'note': note,
    });
  }

  Future<String> fetchPrivacyPolicyHtml() async {
    try {
      final uri = _siteUri(AppConfig.privacyPolicyUrl);
      final response = await _client.get(uri, headers: _headers());
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.body.trim().isNotEmpty &&
          !response.body.contains('<div id="root"')) {
        return response.body;
      }
    } catch (e) {
      debugPrint('[API] fetchPrivacyPolicyHtml: $e');
    }
    return '<p>Política de privacidade ainda não publicada neste ambiente.</p>';
  }
}
