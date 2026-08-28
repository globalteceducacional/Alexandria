import 'book.dart';

class HomeData {
  HomeData({
    required this.featuredBooks,
    required this.latestBooks,
    required this.popularBooks,
  });

  final List<Book> featuredBooks;
  final List<Book> latestBooks;
  final List<Book> popularBooks;

  factory HomeData.fromJson(Map<String, dynamic> json) {
    List<Book> parseList(String key) {
      final raw = json[key];
      if (raw is List) {
        return raw.whereType<Map<String, dynamic>>().map(Book.fromJson).toList();
      }
      return <Book>[];
    }

    return HomeData(
      featuredBooks: parseList('featured_books'),
      latestBooks: parseList('latest_books'),
      popularBooks: parseList('popular_books'),
    );
  }
}
