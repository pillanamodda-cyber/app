import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'tabs/tournaments_tab.dart';
import 'tabs/teams_tab.dart';
import 'tabs/wallet_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/admin_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isAdmin = provider.isAdmin;

    final List<Widget> tabs = [
      const TournamentsTab(),
      const TeamsTab(),
      const WalletTab(),
      const ProfileTab(),
      if (isAdmin) const AdminTab(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Tournaments'),
      const BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Teams'),
      const BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      if (isAdmin)
        const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings, color: Colors.orange), label: 'Admin'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > navItems.length - 1 ? 0 : _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF131B2E),
        selectedItemColor: const Color(0xFFFF5722),
        unselectedItemColor: Colors.grey,
        items: navItems,
      ),
    );
  }
}
