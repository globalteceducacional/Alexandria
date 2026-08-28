import 'dart:convert';

import 'package:alexandria/core/api/ebook_api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: '''
EBOOK_SITE_BASE_URL=https://admin.alenxandriaglobaltec.com/
''');
  });

  test('login POST em user_login_api.php com form e envelope EBOOK_APP',
      () async {
    late http.BaseRequest seen;
    final client = EbookApiClient(
      httpClient: MockClient((request) async {
        seen = request;
        return http.Response(
          jsonEncode({
            'EBOOK_APP': [
              {
                'success': '1',
                'user_id': 42,
                'name': 'Ana',
                'email': 'ana@escola.com',
                'phone': '1199999',
                'user_image': '',
                'acervo_id': 3,
                'MSG': 'Login efetuado',
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result = await client.login(
      email: 'ana@escola.com',
      password: 'secret',
    );

    expect(seen.method, 'POST');
    expect(
      seen.url.toString(),
      'https://admin.alenxandriaglobaltec.com/user_login_api.php',
    );
    final posted = seen;
    if (posted is! http.Request) {
      fail('esperava http.Request com body form-urlencoded');
    }
    expect(posted.bodyFields['email'], 'ana@escola.com');
    expect(posted.bodyFields['password'], 'secret');
    expect(posted.bodyFields['type'], 'Normal');
    expect(seen.url.query, isNot(contains('password')));
    expect(result['success'], '1');
    expect(result['user_id'], 42);
    expect(result['acervo_id'], 3);
  });

  test('login falho devolve MSG do envelope sem JWT', () async {
    final client = EbookApiClient(
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'EBOOK_APP': [
              {'success': '0', 'MSG': 'Senha inválida'},
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result = await client.login(email: 'a@b.com', password: 'x');
    expect(result['success'], '0');
    expect(result['MSG'], 'Senha inválida');
    expect(result.containsKey('accessToken'), isFalse);
  });

  test('catálogo usa api.php?method_name e user_id/acervo_id', () async {
    final seen = <String>[];
    final client = EbookApiClient(
      httpClient: MockClient((request) async {
        seen.add('${request.method} ${request.url}');
        final method = request.url.queryParameters['method_name'];
        if (method == 'home') {
          return http.Response(
            jsonEncode({
              'EBOOK_APP': {
                'featured_books': [],
                'latest_books': [],
                'popular_books': [],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({'EBOOK_APP': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    )..setReaderContext(userId: '42', acervoId: 3);

    await client.fetchHome();
    await client.fetchCategories();
    await client.fetchAuthors();
    await client.fetchAllBooks();

    expect(seen[0], contains('/api.php?'));
    expect(seen[0], contains('method_name=home'));
    expect(seen[0], contains('user_id=42'));
    expect(seen[0], contains('acervo_id=3'));
    expect(seen[1], contains('method_name=cat_list'));
    expect(seen[2], contains('method_name=author_list'));
    expect(seen[3], contains('method_name=allbook'));
    for (final url in seen) {
      expect(url.contains('/api/v1/'), isFalse);
    }
  });

  test('HTML do SPA (nginx sem proxy) vira erro explícito', () async {
    final client = EbookApiClient(
      httpClient: MockClient((request) async {
        return http.Response(
          '<!DOCTYPE html><html><div id="root"></div></html>',
          200,
          headers: {'content-type': 'text/html'},
        );
      }),
    );

    expect(
      () => client.login(email: 'a@b.com', password: 'x'),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('HTML'),
        ),
      ),
    );
  });

  test('cliente não chama login admin /api/v1/auth/login', () async {
    final seen = <Uri>[];
    final client = EbookApiClient(
      httpClient: MockClient((request) async {
        seen.add(request.url);
        return http.Response(
          jsonEncode({
            'EBOOK_APP': [
              {'success': '1', 'user_id': 1, 'email': 'a@b.com', 'name': 'A'},
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await client.login(email: 'a@b.com', password: 'x');
    expect(seen, isNotEmpty);
    for (final uri in seen) {
      expect(uri.path, isNot(contains('/api/v1/')));
      expect(uri.path.endsWith('.php'), isTrue);
    }
  });
}
