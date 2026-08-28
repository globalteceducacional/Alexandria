import 'package:alexandria/core/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: '''
EBOOK_SITE_BASE_URL=https://admin.alenxandriaglobaltec.com/
''');
  });

  test('apiBaseUrl deriva api.php do host do .env', () {
    expect(
      AppConfig.apiBaseUrl,
      'https://admin.alenxandriaglobaltec.com/api.php',
    );
  });

  test('rotas dedicadas do leitor ficam no host admin', () {
    expect(
      AppConfig.loginUrl,
      'https://admin.alenxandriaglobaltec.com/user_login_api.php',
    );
    expect(
      AppConfig.profileUrl,
      'https://admin.alenxandriaglobaltec.com/user_profile_api.php',
    );
    expect(
      AppConfig.profileUpdateUrl,
      'https://admin.alenxandriaglobaltec.com/user_profile_update_api.php',
    );
  });

  test('pastas de media batem com o nginx /legacy/assets/', () {
    expect(
      AppConfig.imagesBaseUrl,
      'https://admin.alenxandriaglobaltec.com/legacy/assets/images/',
    );
    expect(
      AppConfig.uploadsBaseUrl,
      'https://admin.alenxandriaglobaltec.com/legacy/assets/uploads/',
    );
  });

  test('resolveMediaUrl prefixa filename relativo', () {
    expect(
      AppConfig.resolveMediaUrl('capa.jpg', folder: 'images'),
      'https://admin.alenxandriaglobaltec.com/legacy/assets/images/capa.jpg',
    );
  });

  test('resolveMediaUrl mantém URL https absoluta', () {
    const remote = 'https://admin.alenxandriaglobaltec.com/legacy/assets/images/capa.jpg';
    expect(AppConfig.resolveMediaUrl(remote, folder: 'images'), remote);
  });

  test('EBOOK_API_BASE_URL override remove barra final', () {
    dotenv.testLoad(fileInput: '''
EBOOK_SITE_BASE_URL=https://admin.alenxandriaglobaltec.com/
EBOOK_API_BASE_URL=https://admin.alenxandriaglobaltec.com/api.php/
''');
    expect(
      AppConfig.apiBaseUrl,
      'https://admin.alenxandriaglobaltec.com/api.php',
    );
    dotenv.testLoad(fileInput: '''
EBOOK_SITE_BASE_URL=https://admin.alenxandriaglobaltec.com/
''');
  });
}
