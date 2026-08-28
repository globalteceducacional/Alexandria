import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/layout/app_content_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/html_decode.dart';
import '../home/home_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AppColors.primaryDark,
      ),
      backgroundColor: AppColors.background,
      body: AppConstrainedContent(
        child: ListView(
          children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Políticas de uso'),
            subtitle: const Text('Veja termos e condições de uso do app.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UsagePoliciesScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          // Espaço reservado para futuras opções (tema, idioma, leitura, etc.)
          ],
        ),
      ),
    );
  }
}

class UsagePoliciesScreen extends StatefulWidget {
  const UsagePoliciesScreen({super.key});

  @override
  State<UsagePoliciesScreen> createState() => _UsagePoliciesScreenState();
}

class _UsagePoliciesScreenState extends State<UsagePoliciesScreen> {
  bool _loading = true;
  String? _error;
  String _content = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = context.read<HomeViewModel>().api;
      final html = await api.fetchPrivacyPolicyHtml();
      setState(() {
        _content = cleanHtmlText(html);
        _loading = false;
      });
    } catch (e) {
      debugPrint('[Settings] erro ao carregar políticas: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível carregar as políticas de uso.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Políticas de uso'),
        backgroundColor: AppColors.primaryDark,
      ),
      backgroundColor: AppColors.background,
      body: AppConstrainedContent(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMedium),
        ),
      );
    }
    if (_content.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma política de uso cadastrada.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMedium),
        ),
      );
    }
    return SingleChildScrollView(
      child: Text(
        _content,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: AppColors.textMedium,
        ),
      ),
    );
  }
}

