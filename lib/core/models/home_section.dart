import 'book.dart';

class HomeSection {
  HomeSection({
    required this.id,
    required this.title,
    required this.bookIds,
    required this.books,
  });

  final String id;
  final String title;
  final List<String> bookIds;
  final List<Book> books;

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    List<String> parseIds(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => '$e').where((e) => e.isNotEmpty).toList();
      }
      if (raw is String) {
        if (raw.trim().isEmpty) return <String>[];
        return raw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return <String>[];
    }

    return HomeSection(
      id: '${json['id'] ?? ''}',
      title: (json['title'] ?? json['section_title'] ?? '').toString(),
      bookIds: parseIds(
        json['bookIds'] ?? json['song_list'] ?? json['section_books'],
      ),
      books: const <Book>[],
    );
  }

  HomeSection copyWith({
    List<Book>? books,
  }) {
    return HomeSection(
      id: id,
      title: title,
      bookIds: bookIds,
      books: books ?? this.books,
    );
  }
}
