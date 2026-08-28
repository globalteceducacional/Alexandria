import 'package:alexandria/core/models/author.dart';
import 'package:alexandria/core/models/book.dart';
import 'package:alexandria/core/models/category.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: '''
EBOOK_SITE_BASE_URL=https://admin.alenxandriaglobaltec.com/
''');
  });

  test('Book.fromJson lê contrato Kotlin e campos PHP do leitor', () {
    final book = Book.fromJson({
      'id': 42,
      'title': 'Dom Casmurro',
      'authorId': 7,
      'authorName': 'Machado',
      'bookCoverImage': 'capa.jpg',
      'fileType': 'pdf',
      'fileUrl': '42_dom.pdf',
      'status': '1',
      'categoryIds': [3, 5],
      'featured': true,
    });

    expect(book.id, '42');
    expect(book.authorId, '7');
    expect(book.categoryIds, ['3', '5']);
    expect(book.featured, isTrue);
    expect(
      book.coverImageUrl,
      'https://admin.alenxandriaglobaltec.com/legacy/assets/images/capa.jpg',
    );
    expect(
      book.resolvedFileUrl,
      'https://admin.alenxandriaglobaltec.com/legacy/assets/uploads/42_dom.pdf',
    );
  });

  test('Book.fromJson também aceita campos PHP legados', () {
    final book = Book.fromJson({
      'id': '9',
      'book_title': 'Memórias',
      'aid': '1',
      'book_cover_img': 'm.jpg',
      'book_file_url': 'https://cdn.example/m.pdf',
      'cat_id': '2,4',
    });

    expect(book.title, 'Memórias');
    expect(book.authorId, '1');
    expect(book.categoryIds, ['2', '4']);
    expect(book.resolvedFileUrl, 'https://cdn.example/m.pdf');
  });

  test('Author e Category usam /legacy/assets/images/', () {
    final author = Author.fromJson({'id': 1, 'name': 'A', 'image': 'a.png'});
    final category = Category.fromJson({'id': 2, 'name': 'C', 'image': 'c.png'});

    expect(
      author.imageUrl,
      'https://admin.alenxandriaglobaltec.com/legacy/assets/images/a.png',
    );
    expect(
      category.imageUrl,
      'https://admin.alenxandriaglobaltec.com/legacy/assets/images/c.png',
    );
    expect(category.imageThumbUrl, category.imageUrl);
  });
}
