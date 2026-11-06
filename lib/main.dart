import 'package:flutter/material.dart';

import 'data/chat_store.dart';
import 'data/claim_store.dart';
import 'data/user_profile_store.dart';
import 'design/bagi_porsi_theme.dart';
import 'screens/listing_makanan.dart';
import 'screens/peta.dart';
import 'screens/pilih_restoran.dart';
import 'screens/profil.dart';
import 'screens/klaim_saya.dart';
import 'widgets/claim_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final claims = ClaimStore(storage: DeviceClaimStorage());
  await claims.load();
  runApp(BagiPorsiApp(claims: claims));
}

class BagiPorsiApp extends StatefulWidget {
  const BagiPorsiApp({super.key, this.claims});
  final ClaimStore? claims;

  @override
  State<BagiPorsiApp> createState() => _BagiPorsiAppState();
}

class _BagiPorsiAppState extends State<BagiPorsiApp> {
  final _navigationKey = GlobalKey<_MainNavigationState>();
  late final _claims = widget.claims ?? ClaimStore();
  final _chatStore = ChatStore();

  @override
  void dispose() {
    if (widget.claims == null) _claims.dispose();
    _chatStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClaimScope(
      store: _claims,
      chatStore: _chatStore,
      onOpenClaims: () => _navigationKey.currentState?.showClaims(),
      child: MaterialApp(
        title: 'BagiPorsi',
        debugShowCheckedModeBanner: false,
        theme: BagiPorsiTheme.data,
        home: MainNavigation(key: _navigationKey, chatStore: _chatStore),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.chatStore});
  final ChatStore? chatStore;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void showClaims() => setState(() => _selectedIndex = 2);

  late final _chatStore = widget.chatStore ?? ChatStore();
  final _profile = UserProfileStore();

  late final List<Widget> _pages = [
    ListingMakanan(profile: _profile),
    Peta(profile: _profile, chatStore: _chatStore),
    const KlaimSaya(embedded: true),
    PilihRestoran(store: _chatStore),
    Profil(profile: _profile),
  ];

  @override
  void dispose() {
    if (widget.chatStore == null) _chatStore.dispose();
    _profile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = ClaimScope.maybeOf(context)?.store.active.length ?? 0;
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
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            const NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Peta',
            ),
            NavigationDestination(
              icon: Badge.count(
                count: activeCount,
                isLabelVisible: activeCount > 0,
                backgroundColor: BagiPorsiColors.green,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge.count(
                count: activeCount,
                isLabelVisible: activeCount > 0,
                backgroundColor: BagiPorsiColors.green,
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Klaim',
            ),
            const NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            const NavigationDestination(
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
