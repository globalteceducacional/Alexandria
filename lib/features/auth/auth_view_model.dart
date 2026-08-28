import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/ebook_api_client.dart';
import '../../core/models/app_user.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._api);

  final EbookApiClient _api;

  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session_user');
    if (raw != null) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _user = AppUser.fromJson(json);
        if (_user == null || _user!.id <= 0) {
          debugPrint('[Auth] tryRestoreSession: sessão sem user_id — limpando');
          await prefs.remove('session_user');
          _user = null;
          return;
        }
        _api.setReaderContext(
          userId: _user!.id.toString(),
          acervoId: _user!.acervoId,
        );
        debugPrint(
          '[Auth] tryRestoreSession: restaurado userId=${_user?.id} '
          'name=${_user?.name} acervoId=${_user?.acervoId}',
        );
        final profile = await _api.fetchUserProfile(_user!.id.toString());
        if (profile == null) {
          debugPrint(
            '[Auth] tryRestoreSession: perfil indisponível — mantém sessão local',
          );
          notifyListeners();
          return;
        }
        _user = _user!.copyWith(
          name: profile.name,
          phone: profile.phone,
          userImage: profile.userImage,
          acervoId: profile.acervoId ?? _user!.acervoId,
        );
        _api.setReaderContext(
          userId: _user!.id.toString(),
          acervoId: _user!.acervoId,
        );
        await _persistSession();
        notifyListeners();
      } catch (e) {
        debugPrint('[Auth] tryRestoreSession falhou: $e');
        await prefs.remove('session_user');
        _api.clearSession();
        _user = null;
      }
    } else {
      debugPrint('[Auth] tryRestoreSession: sem session_user salvo');
    }
  }

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.login(email: username, password: password);
      if ((result['success'] ?? '0') == '1') {
        _user = AppUser.fromJson(result);
        _api.setReaderContext(
          userId: _user!.id.toString(),
          acervoId: _user!.acervoId,
        );
        await _persistSession();
        return true;
      }
      _error = result['MSG']?.toString() ?? 'Credenciais inválidas.';
      return false;
    } catch (e) {
      _error = 'Erro de conexão. Verifique o servidor.';
      debugPrint('Erro no login: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _api.clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user');
    notifyListeners();
  }

  Future<void> _persistSession() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final json = _user!.toJson();
    debugPrint(
      '[Auth] _persistSession: salvando userId=${_user!.id} '
      'name=${_user!.name} acervoId=${_user!.acervoId}',
    );
    await prefs.setString('session_user', jsonEncode(json));
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? userImage,
    String newPassword = '',
  }) async {
    final current = _user;
    if (current == null) return;
    final newName = (name ?? current.name).trim();
    final newPhone = (phone ?? current.phone).trim();
    final newImage = userImage?.trim();
    debugPrint(
      '[Auth] updateProfile: antes userId=${current.id} '
      'name=${current.name} phone=${current.phone} image=${current.userImage}',
    );
    _user = current.copyWith(
      name: newName.isEmpty ? null : newName,
      phone: newPhone,
      userImage: newImage ?? current.userImage,
    );
    await _persistSession();
    notifyListeners();

    try {
      final ok = await _api.updateUserProfile(
        currentUser: current,
        name: newName,
        phone: newPhone,
        newPassword: newPassword,
        localImagePath: newImage,
      );
      if (!ok) {
        debugPrint(
          '[Auth] updateProfile: backend sem endpoint — mantendo local',
        );
        return;
      }
      final serverUser = await _api.fetchUserProfile(current.id.toString());
      if (serverUser == null) return;
      _user = AppUser(
        id: current.id,
        name: serverUser.name,
        email: current.email,
        phone: serverUser.phone,
        userImage: serverUser.userImage,
        authId: current.authId,
        acervoId: serverUser.acervoId ?? current.acervoId,
        accessToken: current.accessToken,
      );
      await _persistSession();
      notifyListeners();
    } catch (e) {
      debugPrint('[Auth] updateProfile: erro ao atualizar no backend: $e');
    }
  }
}
