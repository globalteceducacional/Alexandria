import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/api/ebook_api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_view_model.dart';
import 'features/home/home_view_model.dart';
import 'features/favorites/favorite_view_model.dart';
import 'features/wishlist/wishlist_view_model.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Falha crítica: exige .env configurado.
    throw Exception(
      'Arquivo .env não encontrado ou inválido. '
      'Copie .env.example para .env e preencha as variáveis do ambiente.',
    );
  }

  runApp(const AlexandriaApp());
}

/// No Windows/desktop o arrasto com mouse passa a rolar listas (incl. horizontais).
class AlexandriaScrollBehavior extends MaterialScrollBehavior {
  const AlexandriaScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class AlexandriaApp extends StatelessWidget {
  const AlexandriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = EbookApiClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(apiClient)),
        ChangeNotifierProvider(create: (_) => HomeViewModel(apiClient)),
        ChangeNotifierProvider(create: (_) => FavoriteViewModel(apiClient)),
        ChangeNotifierProvider(create: (_) => WishlistViewModel(apiClient)),
      ],
      child: MaterialApp(
        title: 'Alexandria',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const AlexandriaScrollBehavior(),
        theme: buildAppTheme(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerate,
      ),
    );
  }
}
