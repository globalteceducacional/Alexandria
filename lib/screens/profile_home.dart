import 'package:elearn/consttants.dart';
import 'package:elearn/databasefavourite/db.dart';
import 'package:elearn/model/Profile.dart';
import 'package:elearn/screens/bottom_navigation.dart';
import 'package:elearn/screens/setting.dart';
import 'package:elearn/screens/setting/favourite.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:elearn/widgets/safe_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileHome extends StatefulWidget {
  const ProfileHome({super.key});

  @override
  State<ProfileHome> createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    if (userId != null) {
      HttpService().getUserProfile().then((value) {
        if (mounted) setState(() => _profile = value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildUserCard()),
          SliverToBoxAdapter(child: _buildCurrentlyReading()),
          SliverToBoxAdapter(child: _buildWantToRead()),
          SliverToBoxAdapter(child: _buildSettingsButton()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return const SliverAppBar(
      backgroundColor: kNavy,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Perfil',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Gilroy-Bold',
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildUserCard() {
    final name = _profile?.ebookApp.isNotEmpty == true
        ? _profile!.ebookApp[0].name
        : (userId != null ? 'Leitor' : 'Visitante');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDF5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kNavy.withAlpha(30),
                    width: 2,
                  ),
                ),
                child:                   const Icon(
                    Icons.person_outline,
                  size: 36,
                  color: kNavy,
                ),
              ),
              if (userId != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 14,
                      color: kAmber,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    fontSize: 18,
                    color: kNavy,
                  ),
                ),
                const SizedBox(height: 4),
                if (userId != null)
                  const Text(
                    'Leitor Assíduo',
                    style: TextStyle(
                      fontFamily: 'Gilroy-SemiBold',
                      fontSize: 13,
                      color: kAmber,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentlyReading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Lendo Agora',
          onSeeAll: null,
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.retrieveDownLoad(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _emptyCard('Nenhum livro sendo lido no momento');
            }
            final books = snapshot.data!.take(3).toList();
            return Column(
              children: books.map((b) => _ReadingProgressCard(book: b)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWantToRead() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Quero Ler',
          onSeeAll: () => Get.to(() => const ReadTodoScreen()),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.retrieveTodos(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _emptyCard('Nenhum livro na lista de desejos');
            }
            final books = snapshot.data!.take(3).toList();
            return Column(
              children: books.map((b) => _WantToReadCard(book: b)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Get.to(() => const Setting()),
          style: ElevatedButton.styleFrom(
            backgroundColor: kNavy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
          ),
          child: const Text(
            'Configurações',
            style: TextStyle(
              fontFamily: 'Gilroy-Bold',
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFCCCCCC), size: 20),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF999999),
                fontFamily: 'Gilroy-SemiBold',
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reading Progress Card ────────────────────────────────────────────────────

class _ReadingProgressCard extends StatelessWidget {
  final Map<String, dynamic> book;
  const _ReadingProgressCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final title = book['title'] as String? ?? 'Livro';
    final image = book['image'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SafeBookCoverWidget(
              imageUrl: image,
              width: 56,
              height: 76,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    fontSize: 14,
                    color: kNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.4,
                        backgroundColor: const Color(0xFFE8E8E8),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(kAmber),
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '40%',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Gilroy-SemiBold',
                        color: kAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Want To Read Card ────────────────────────────────────────────────────────

class _WantToReadCard extends StatelessWidget {
  final Map<String, dynamic> book;
  const _WantToReadCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final title = book['title'] as String? ?? 'Livro';
    final image = book['image'] as String? ?? '';
    final rating = double.tryParse(book['rating']?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SafeBookCoverWidget(
              imageUrl: image,
              width: 56,
              height: 76,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Bold',
                    fontSize: 14,
                    color: kNavy,
                  ),
                ),
                const SizedBox(height: 6),
                _StarRating(value: rating),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Star Rating ──────────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final double value;
  const _StarRating({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < value.floor();
        final half = !filled && i < value;
        return Icon(
          half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
          color: kAmber,
          size: 16,
        );
      }),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontFamily: 'Gilroy-Bold',
              color: kNavy,
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Icon(
                Icons.chevron_right,
                color: kNavy,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}
