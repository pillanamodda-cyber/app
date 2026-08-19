import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class AdminTab extends StatelessWidget {
  const AdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final players = provider.adminPlayers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - MongoDB Data', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF131B2E),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchUserData(),
          ),
        ],
      ),
      body: players.isEmpty
          ? const Center(child: Text('No players found or unauthorized', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final playerId = player['_id'] ?? player['id'];
                return Card(
                  color: const Color(0xFF131B2E),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(player['name'] ?? 'Player', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Email: ${player['email'] ?? 'N/A'}\nFF UID: ${player['ffUid'] ?? 'N/A'}', style: TextStyle(color: Colors.grey[400])),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFFF5722)),
                      onPressed: () {
                        _showEditUserDialog(context, provider, playerId, player);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showEditUserDialog(BuildContext context, AppProvider provider, String playerId, Map<String, dynamic> player) {
    final nameController = TextEditingController(text: player['name'] ?? '');
    final ffUidController = TextEditingController(text: player['ffUid'] ?? '');
    bool isAdminVal = player['isAdmin'] ?? false;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text('Adjust User Data (MongoDB)', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ffUidController,
              decoration: const InputDecoration(labelText: 'Free Fire UID', labelStyle: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Is Admin', style: TextStyle(color: Colors.white)),
              value: isAdminVal,
              activeColor: const Color(0xFFFF5722),
              onChanged: (val) {
                isAdminVal = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.adminUpdateUser(playerId, {
                'name': nameController.text.trim(),
                'ffUid': ffUidController.text.trim(),
                'isAdmin': isAdminVal,
              });
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User data updated successfully in MongoDB backend!')),
              );
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
