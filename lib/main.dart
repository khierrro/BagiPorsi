import 'package:flutter/material.dart';

import 'data/chat_store.dart';
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

  late final List<Widget> _pages = [
    const ListingMakanan(),
    const Peta(),
    PilihRestoran(store: _chatStore),
    const Profil(), // Menu ke-4
  ];

  @override
  void dispose() {
    _chatStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
