import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/layout/app_content_layout.dart';
import '../../core/api/ebook_api_client.dart';
import '../../core/models/book.dart';
import '../../core/storage/favorites_notifier.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/auth_view_model.dart';
import '../../features/favorites/favorite_view_model.dart';
import '../../features/home/home_view_model.dart';
import '../../features/wishlist/wishlist_view_model.dart';
import '../../routes/app_routes.dart';
import 'profile_books_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _openProfileSettings(BuildContext context) async {
    final auth = context.read<AuthViewModel>();
    final user = auth.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para configurar o perfil.')),
      );
      return;
    }

    final email = user.email.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'E-mail do perfil indisponível. Tente sair e entrar novamente.',
          ),
        ),
      );
      return;
    }

    final api = context.read<HomeViewModel>().api;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SettingsPasswordDialog(
        email: email,
        apiClient: api,
      ),
    );
    if (!context.mounted || confirmed != true) return;

    final saved = await Navigator.of(context).pushNamed(AppRoutes.editProfile);
    if (saved == true && context.mounted) {
      await context.read<FavoriteViewModel>().refresh(user.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : AppConstrainedContent(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  _ProfileHeader(
                    name: user.name,
                    imageUrl: user.userImage,
                    onSettings: () => _openProfileSettings(context),
                  ),
                  _FavoriteBooksSection(userId: user.id.toString()),
                  _WishlistSection(userId: user.id.toString()),
                ],
              ),
            ),
    );
  }
}

// ─── Cabeçalho do perfil ──────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.imageUrl,
    required this.onSettings,
  });
  final String name;
  final String imageUrl;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primaryDark.withAlpha(25),
            backgroundImage: _resolveImage(imageUrl),
            child: _resolveImage(imageUrl) == null
                ? Icon(
                    Icons.person_rounded,
                    size: 38,
                    color: AppColors.primaryDark.withAlpha(120),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Leitor',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Leitor Assíduo',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Configurar perfil',
            child: Material(
              color: AppColors.accent.withAlpha(35),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onSettings,
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.settings_rounded,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

ImageProvider? _resolveImage(String imageUrl) {
  if (imageUrl.isEmpty) return null;
  if (imageUrl.startsWith('http')) {
    return CachedNetworkImageProvider(imageUrl);
  }
  final file = File(imageUrl);
  if (file.existsSync()) {
    return FileImage(file);
  }
  return null;
}

// ─── Seção de livros no perfil ────────────────────────────────────────────────

class _ProfileBookSection extends StatelessWidget {
  const _ProfileBookSection({
    required this.title,
    required this.books,
    this.onTapHeader,
  });

  final String title;
  final List<Book> books;
  final VoidCallback? onTapHeader;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTapHeader,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...books.map((book) => _ProfileBookTile(book: book)),
        ],
      ),
    );
  }
}

class _FavoriteBooksSection extends StatefulWidget {
  const _FavoriteBooksSection({required this.userId});

  final String userId;

  @override
  State<_FavoriteBooksSection> createState() => _FavoriteBooksSectionState();
}

class _FavoriteBooksSectionState extends State<_FavoriteBooksSection> {
  List<Book> _books = <Book>[];
  bool _loading = true;
  late final VoidCallback _onFavoritesChanged;

  @override
  void initState() {
    super.initState();
    _onFavoritesChanged = () => unawaited(_loadFavorites());
    FavoritesNotifier.instance.addListener(_onFavoritesChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadFavorites());
    });
  }

  @override
  void dispose() {
    FavoritesNotifier.instance.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    if (widget.userId.isEmpty) {
      if (mounted) {
        setState(() {
          _books = <Book>[];
          _loading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _loading = true);

    try {
      final api = context.read<HomeViewModel>().api;
      final rows = await api.fetchFavouriteListRowsResolved(widget.userId);
      final books = rows.map(Book.favouritePreview).toList();
      if (!mounted) return;
      setState(() {
        _books = books;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _books = <Book>[];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (_books.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meus Favoritos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Você ainda não favoritou nenhum livro.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      );
    }

    return _ProfileBookSection(
      title: 'Meus Favoritos',
      books: _books,
      onTapHeader: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProfileBooksListScreen(
              title: 'Meus Favoritos',
              books: _books,
            ),
          ),
        );
      },
    );
  }
}

class _WishlistSection extends StatefulWidget {
  const _WishlistSection({required this.userId});

  final String userId;

  @override
  State<_WishlistSection> createState() => _WishlistSectionState();
}

class _WishlistSectionState extends State<_WishlistSection> {
  List<Book> _books = <Book>[];
  Set<String> _lastIds = <String>{};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sync();
    });
  }

  void _sync() {
    if (widget.userId.isEmpty) return;
    final wishVm = context.read<WishlistViewModel>();
    wishVm.ensureLoaded(widget.userId);
    final ids = wishVm.idsForUser(widget.userId);
    if (!_setsEqual(ids, _lastIds)) {
      _lastIds = Set<String>.from(ids);
      _fetchBooks(ids);
    }
  }

  bool _setsEqual(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  Future<void> _fetchBooks(Set<String> ids) async {
    if (ids.isEmpty) {
      if (mounted) {
        setState(() {
          _books = <Book>[];
          _loading = false;
        });
      }
      return;
    }

    if (mounted && !_loading) {
      setState(() => _loading = true);
    }

    final api = context.read<HomeViewModel>().api;
    final books = <Book>[];
    for (final id in ids) {
      try {
        final book = await api.fetchBookDetail(id);
        if (book != null) books.add(book);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _books = books;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishVm = context.watch<WishlistViewModel>();
    final ids = wishVm.idsForUser(widget.userId);

    if (!_setsEqual(ids, _lastIds)) {
      _lastIds = Set<String>.from(ids);
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchBooks(ids);
      });
    }

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (_books.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ler Depois',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione livros à lista Ler Depois para ver aqui.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      );
    }

    return _ProfileBookSection(
      title: 'Ler Depois',
      books: _books,
      onTapHeader: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProfileBooksListScreen(
              title: 'Ler Depois',
              books: _books,
            ),
          ),
        );
      },
    );
  }
}

class _ProfileBookTile extends StatelessWidget {
  const _ProfileBookTile({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.bookDetail,
        arguments: book,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 85,
                child: CachedNetworkImage(
                  imageUrl: book.coverImageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.primaryDark.withAlpha(20),
                    child: const Icon(
                      Icons.book,
                      size: 24,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.authorName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.authorName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPasswordDialog extends StatefulWidget {
  const _SettingsPasswordDialog({
    required this.email,
    required this.apiClient,
  });

  final String email;
  final EbookApiClient apiClient;

  @override
  State<_SettingsPasswordDialog> createState() =>
      _SettingsPasswordDialogState();
}

class _SettingsPasswordDialogState extends State<_SettingsPasswordDialog> {
  final _passCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passCtrl.text;
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres.'),
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final result = await widget.apiClient.login(
        email: widget.email.trim(),
        password: password,
      );
      if (!mounted) return;
      if ((result['success'] ?? '0') == '1') {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['MSG']?.toString() ?? 'Senha incorreta.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível verificar a senha.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar acesso'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Confirme sua senha para abrir as configurações do perfil.',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!_busy) unawaited(_submit());
              },
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _busy ? null : () => unawaited(_submit()),
          child: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Continuar'),
        ),
      ],
    );
  }
}
