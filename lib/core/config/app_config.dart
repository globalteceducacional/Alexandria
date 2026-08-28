import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String _env(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('Variável de ambiente "$key" não definida no .env');
    }
    return value;
  }

  /// Host do painel Kotlin (ex.: https://admin.alenxandriaglobaltec.com/).
  static String get siteBaseUrl {
    final raw = _env('EBOOK_SITE_BASE_URL');
    return raw.endsWith('/') ? raw : '$raw/';
  }

  /// Endpoint do catálogo leitor. Padrão: `{site}api.php`.
  static String get apiBaseUrl {
    final override = dotenv.env['EBOOK_API_BASE_URL'];
    if (override != null && override.isNotEmpty) {
      return override.endsWith('/')
          ? override.substring(0, override.length - 1)
          : override;
    }
    return '${siteBaseUrl}api.php';
  }

  static String get loginUrl => '${siteBaseUrl}user_login_api.php';

  static String get profileUrl => '${siteBaseUrl}user_profile_api.php';

  static String get profileUpdateUrl =>
      '${siteBaseUrl}user_profile_update_api.php';

  static String get privacyPolicyUrl => '${siteBaseUrl}privacyPolicy.php';

  /// Capas/imagens no host admin (legado).
  static String get imagesBaseUrl => '${siteBaseUrl}legacy/assets/images/';

  /// Miniaturas no host admin (legado).
  static String get thumbsBaseUrl => '${siteBaseUrl}legacy/assets/images/thumbs/';

  /// PDF/EPUB no host admin (legado).
  static String get uploadsBaseUrl => '${siteBaseUrl}legacy/assets/uploads/';

  /// Transforma filename relativo ou URL crua em URL absoluta no host do .env.
  ///
  /// O espelho PHP já costuma devolver URL absoluta; este helper cobre
  /// filenames crus e leftovers `localhost` do `LEGACY_PUBLIC_BASE_URL`.
  static String resolveMediaUrl(String raw, {required String folder}) {
    final value = raw.trim();
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      final uri = Uri.tryParse(value);
      if (uri != null && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
        final path = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
        return '$siteBaseUrl$path';
      }
      return value;
    }

    if (value.startsWith('/')) {
      return '$siteBaseUrl${value.substring(1)}';
    }

    if (value.contains('legacy/assets/')) {
      return '$siteBaseUrl$value';
    }

    return '${siteBaseUrl}legacy/assets/$folder/$value';
  }
}
