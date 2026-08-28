import 'package:shared_preferences/shared_preferences.dart';

/// Preferência de navegação no leitor: páginas laterais (livro) ou rolagem.
enum ReadingMode {
  /// Passagem lateral de páginas (como um livro físico).
  page,

  /// Rolagem vertical contínua.
  scroll,
}

class ReadingModeService {
  ReadingModeService._();

  static const _key = 'reader_reading_mode';

  /// Padrão: passagem de páginas (experiência de livro).
  static const ReadingMode defaultMode = ReadingMode.page;

  static Future<ReadingMode> get() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == ReadingMode.scroll.name) return ReadingMode.scroll;
    if (raw == ReadingMode.page.name) return ReadingMode.page;
    return defaultMode;
  }

  static Future<void> save(ReadingMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
