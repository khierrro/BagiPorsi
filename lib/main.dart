import 'package:flutter/material.dart';

import 'data/chat_store.dart';
import 'data/user_profile_store.dart';
import 'design/bagi_porsi_theme.dart';
import 'screens/listing_makanan.dart';
import 'screens/peta.dart';
import 'screens/pilih_restoran.dart';
import 'screens/profil.dart';

void main() {
  runApp(const BagiPorsiApp());
}

class BagiPorsiApp extends StatelessWidget {
  const BagiPorsiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BagiPorsi',
      debugShowCheckedModeBanner: false,
      theme: BagiPorsiTheme.data,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final _chatStore = ChatStore();
  final _profile = UserProfileStore();

  late final List<Widget> _pages = [
    ListingMakanan(profile: _profile),
    Peta(profile: _profile, chatStore: _chatStore),
    PilihRestoran(store: _chatStore),
    Profil(profile: _profile),
  ];

  @override
  void dispose() {
    _chatStore.dispose();
    _profile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          // Tambahkan tab navigasi untuk Chat
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Peta',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
