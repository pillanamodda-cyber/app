import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../auth_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.user ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamer Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF131B2E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFFF5722),
              child: Text(
                (user['name'] ?? user['email'] ?? 'G')[0].toUpperCase(),
                style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user['name'] ?? 'Free Fire Player',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user['email'] ?? '',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: const Color(0xFF131B2E),
            child: ListTile(
              leading: const Icon(Icons.sports_esports, color: Color(0xFFFF5722)),
              title: const Text('Free Fire UID', style: TextStyle(color: Colors.white)),
              trailing: Text(user['ffUid'] ?? 'Not Set', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          ),
          Card(
            color: const Color(0xFF131B2E),
            child: ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFFFF5722)),
              title: const Text('Mobile Number', style: TextStyle(color: Colors.white)),
              trailing: Text(user['mobile'] ?? 'Not Set', style: const TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              await provider.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
