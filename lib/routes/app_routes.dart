import 'package:flutter/material.dart';

import '../core/models/author.dart';
import '../core/models/book.dart';
import '../core/models/category.dart';
import '../core/models/home_section.dart';
import '../features/auth/login_screen.dart';
import '../features/author/author_detail_screen.dart';
import '../features/book_detail/book_detail_screen.dart';
import '../features/category/category_books_screen.dart';
import '../features/home/home_section_books_screen.dart';
import '../features/home/main_scaffold.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/reader/book_reader_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const main = '/main';
  static const bookDetail = '/book-detail';
  static const categoryBooks = '/category-books';
  static const authorDetail = '/author-detail';
  static const bookReader = '/book-reader';
  static const homeSectionBooks = '/home-section-books';
  static const editProfile = '/edit-profile';
  static const settingsScreen = '/settings';

  static Route<dynamic>? onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen());
      case login:
        return _fade(const LoginScreen());
      case main:
        return _fade(const MainScaffold());
      case bookDetail:
        final book = settings.arguments as Book;
        return MaterialPageRoute(
          builder: (_) => BookDetailScreen(book: book),
        );
      case categoryBooks:
        final category = settings.arguments as Category;
        return MaterialPageRoute(
          builder: (_) => CategoryBooksScreen(category: category),
        );
      case homeSectionBooks:
        final section = settings.arguments as HomeSection;
        return MaterialPageRoute(
          builder: (_) => HomeSectionBooksScreen(section: section),
        );
      case authorDetail:
        final author = settings.arguments as Author;
        return MaterialPageRoute(
          builder: (_) => AuthorDetailScreen(author: author),
        );
      case bookReader:
        final book = settings.arguments as Book;
        return MaterialPageRoute(
          builder: (_) => BookReaderScreen(book: book),
        );
      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        );
      case settingsScreen:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      default:
        return _fade(const SplashScreen());
    }
  }

  static PageRoute<T> _fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
