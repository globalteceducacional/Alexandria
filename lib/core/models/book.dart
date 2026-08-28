import '../config/app_config.dart';
import '../utils/html_decode.dart';
import 'comment.dart';

class Book {
  Book({
    required this.id,
    required this.categoryIds,
    required this.authorId,
    required this.title,
    required this.coverImage,
    required this.fileType,
    required this.fileUrl,
    required this.description,
    required this.totalRate,
    required this.rateAvg,
    required this.views,
    required this.categoryName,
    required this.categoryImage,
    required this.categoryImageThumb,
    required this.authorName,
    required this.authorImage,
    required this.authorDescription,
    this.relatedBooks = const [],
    this.comments = const [],
    this.currentPage,
    this.totalPages,
    this.featured = false,
  });

  final String id;
  final List<String> categoryIds;
  final String authorId;
  final String title;
  final String coverImage;
  final String fileType;
  final String fileUrl;
  final String description;
  final int totalRate;
  final double rateAvg;
  final int views;
  final String categoryName;
  final String categoryImage;
  final String categoryImageThumb;
  final String authorName;
  final String authorImage;
  final String authorDescription;
  final List<Book> relatedBooks;
  final List<Comment> comments;
  final int? currentPage;
  final int? totalPages;
  final bool featured;

  factory Book.fromJson(Map<String, dynamic> json) {
    List<String> parseCategoryIds(dynamic value) {
      if (value is List) return value.map((e) => '$e').toList();
      if (value is String) {
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return <String>[];
    }

    List<Book> parseRelated(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map<String, dynamic>>()
            .map(Book.fromJson)
            .toList();
      }
      return <Book>[];
    }

    List<Comment> parseComments(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map<String, dynamic>>()
            .map(Comment.fromJson)
            .toList();
      }
      return <Comment>[];
    }

    String d(dynamic v) => decodeHtmlEntities(v?.toString() ?? '');

    int? parseIntNullable(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }

    final categoryIds = parseCategoryIds(
      json['categoryIds'] ?? json['cat_id'] ?? json['categoryId'],
    );

    return Book(
      id: '${json['id'] ?? ''}',
      categoryIds: categoryIds,
      authorId: '${json['authorId'] ?? json['aid'] ?? json['author_id'] ?? ''}',
      title: d(json['title'] ?? json['book_title']),
      coverImage: d(
        json['bookCoverImage'] ??
            json['book_cover_img'] ??
            json['book_cover'] ??
            '',
      ),
      fileType: (json['fileType'] ?? json['book_file_type'])?.toString() ?? '',
      fileUrl: d(json['fileUrl'] ?? json['book_file_url'] ?? ''),
      description: d(json['description'] ?? json['book_description'] ?? ''),
      totalRate: int.tryParse('${json['totalRate'] ?? json['total_rate']}') ?? 0,
      rateAvg: double.tryParse('${json['rateAvg'] ?? json['rate_avg']}') ?? 0,
      views: int.tryParse('${json['views'] ?? json['book_views']}') ?? 0,
      categoryName: d(json['categoryName'] ?? json['category_name'] ?? ''),
      categoryImage: d(json['categoryImage'] ?? json['category_image'] ?? ''),
      categoryImageThumb: d(
        json['categoryImageThumb'] ?? json['category_image_thumb'] ?? '',
      ),
      authorName: d(json['authorName'] ?? json['author_name'] ?? ''),
      authorImage: d(json['authorImage'] ?? json['author_image'] ?? ''),
      authorDescription: d(
        json['authorDescription'] ?? json['author_description'] ?? '',
      ),
      relatedBooks: parseRelated(json['related_books'] ?? json['relatedBooks']),
      comments: parseComments(json['user_comments'] ?? json['comments']),
      currentPage: parseIntNullable(json['current_page'] ?? json['currentPage']),
      totalPages: parseIntNullable(json['total_pages'] ?? json['totalPages']),
      featured: json['featured'] == true ||
          json['featured'] == 1 ||
          '${json['featured']}' == '1',
    );
  }

  String get coverImageUrl {
    // Admin grava o filename em images/; thumbs/ muitas vezes não existe.
    return AppConfig.resolveMediaUrl(coverImage, folder: 'images');
  }

  String get authorImageUrl {
    return AppConfig.resolveMediaUrl(authorImage, folder: 'images');
  }

  /// PDF/EPUB absoluto. Sem isto, `Uri.parse('123_livro.pdf')` não baixa o ficheiro.
  String get resolvedFileUrl {
    return AppConfig.resolveMediaUrl(fileUrl, folder: 'uploads');
  }

  /// Prévia mínima para listas de favoritos (sem pedir detalhe completo).
  factory Book.favouritePreview(Map<String, dynamic> row) {
    final id = (row['bookid'] ?? row['id'] ?? '').toString();
    final cover = (row['image'] ?? '').toString();
    return Book(
      id: id,
      categoryIds: const [],
      authorId: '',
      title: (row['title'] ?? '').toString(),
      coverImage: cover,
      fileType: '',
      fileUrl: '',
      description: '',
      totalRate: 0,
      rateAvg: 0,
      views: 0,
      categoryName: '',
      categoryImage: '',
      categoryImageThumb: '',
      authorName: (row['authorName'] ?? '').toString(),
      authorImage: '',
      authorDescription: '',
    );
  }
}
