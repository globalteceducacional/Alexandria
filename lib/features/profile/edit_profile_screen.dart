import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../core/layout/app_content_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_view_model.dart';
import '../settings/settings_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passCtrl;
  late final TextEditingController _passConfirmCtrl;
  bool _saving = false;
  bool _pickingImage = false;

  String? _localImagePath;
  String _currentImageUrl = '';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _passCtrl = TextEditingController();
    _passConfirmCtrl = TextEditingController();
    _currentImageUrl = user?.userImage ?? '';

    if (_currentImageUrl.isNotEmpty && !_currentImageUrl.startsWith('http')) {
      _localImagePath = _currentImageUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage() async {
    if (_pickingImage) return;

    _pickingImage = true;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Enquadrar foto',
            toolbarColor: AppColors.primaryDark,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.accent,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Enquadrar foto',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (cropped == null || !mounted) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${appDir.path}/$fileName';
      await File(cropped.path).copy(savedPath);

      if (!mounted) return;
      setState(() {
        _localImagePath = savedPath;
      });
    } catch (e) {
      debugPrint('[EditProfile] erro em _pickAndCropImage: $e');
    } finally {
      _pickingImage = false;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final pass = _passCtrl.text.trim();
    if (pass.isNotEmpty && pass != _passConfirmCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    setState(() => _saving = true);

    final auth = context.read<AuthViewModel>();
    final imagePath = _localImagePath ?? _currentImageUrl;

    await auth.updateProfile(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      userImage: imagePath,
      newPassword: pass,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  Future<void> _logout() async {
    final auth = context.read<AuthViewModel>();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configurar perfil'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: AppConstrainedContent(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _buildAvatarPicker()),
              const SizedBox(height: 28),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Informe seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: context.read<AuthViewModel>().user?.email ?? '',
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone (opcional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Alterar senha (opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passConfirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nova senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Salvar alterações',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8C8C8),
                    foregroundColor: AppColors.textDark,
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sair da conta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Políticas de uso'),
                subtitle: const Text('Termos e condições do app'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UsagePoliciesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    ImageProvider? imageProvider;

    if (_localImagePath != null && File(_localImagePath!).existsSync()) {
      imageProvider = FileImage(File(_localImagePath!));
    } else if (_currentImageUrl.startsWith('http')) {
      imageProvider = CachedNetworkImageProvider(_currentImageUrl);
    }

    return GestureDetector(
      onTap: _pickAndCropImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.primaryDark.withAlpha(25),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Icon(
                    Icons.person_rounded,
                    size: 56,
                    color: AppColors.primaryDark.withAlpha(120),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
