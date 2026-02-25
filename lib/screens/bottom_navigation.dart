import 'package:elearn/screens/explore.dart';
import 'package:elearn/screens/home.dart';
import 'package:elearn/screens/profile_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const Color kNavy = Color(0xFF1A2744);
const Color kCream = Color(0xFFF5EDD9);
const Color kAmber = Color(0xFFC69C4F);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RxInt _page = 0.obs;

  final List<Widget> _pages = const [
    Home(),
    Explore(),
    _MultimidiaPlaceholder(),
    ProfileHome(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Obx(() => Scaffold(
          backgroundColor: kCream,
          body: IndexedStack(
            index: _page.value,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 12,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Obx(() => BottomNavigationBar(
                    currentIndex: _page.value,
                    onTap: (i) => _page.value = i,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.white,
                    selectedItemColor: kNavy,
                    unselectedItemColor: const Color(0xFFAAAAAA),
                    selectedLabelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gilroy-SemiBold',
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Gilroy-SemiBold',
                    ),
                    elevation: 0,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home),
                        label: 'Inicio',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.explore_outlined),
                        activeIcon: Icon(Icons.explore),
                        label: 'Explorar',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.play_circle_outline),
                        activeIcon: Icon(Icons.play_circle),
                        label: 'Multimídia',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: 'Perfil',
                      ),
                    ],
                  )),
            ),
          ),
        ));
  }
}

class _MultimidiaPlaceholder extends StatelessWidget {
  const _MultimidiaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kNavy,
        title: const Text(
          'Multimídia',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Gilroy-Bold',
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, size: 80, color: Color(0xFFCCCCCC)),
            SizedBox(height: 16),
            Text(
              'Em breve',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF999999),
                fontFamily: 'Gilroy-SemiBold',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
