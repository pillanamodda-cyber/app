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
        title: const Text('ADMIN CONSOLE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF131B2E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: () => provider.fetchUserData(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStats(players),
          Expanded(
            child: players.isEmpty
                ? const Center(child: Text('No player data found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final p = players[index];
                      return _buildPlayerCard(context, provider, p);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<dynamic> players) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF131B2E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('TOTAL PLAYERS', players.length.toString()),
          _statItem('ACTIVE BANS', players.where((p) => p['isBanned'] == true).length.toString()),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPlayerCard(BuildContext context, AppProvider provider, dynamic p) {
    final isBanned = p['isBanned'] == true;
    final isAdmin = p['isAdmin'] == true || p['role'] == 'admin';

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isBanned ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
          child: Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: isBanned ? Colors.red : (isAdmin ? Colors.orange : Colors.green),
          ),
        ),
        title: Text(p['name'] ?? p['fullName'] ?? 'Player', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('UID: ${p['ffUid'] ?? 'N/A'}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Email', p['email'] ?? 'N/A'),
                _detailRow('Mobile', p['mobile'] ?? 'N/A'),
                _detailRow('IGN', p['ign'] ?? 'N/A'),
                _detailRow('Balance', '₹${p['wallet']?['balance'] ?? 0}'),
                const Divider(color: Colors.white10, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('EDIT DATA'),
                      onPressed: () => _showEditDialog(context, provider, p),
                    ),
                    TextButton.icon(
                      icon: Icon(isBanned ? Icons.gavel : Icons.block, size: 18, color: Colors.red),
                      label: Text(isBanned ? 'UNBAN' : 'BAN', style: const TextStyle(color: Colors.red)),
                      onPressed: () => _showBanDialog(context, provider, p),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppProvider provider, dynamic p) {
    final nameController = TextEditingController(text: p['name'] ?? p['fullName'] ?? '');
    final ffUidController = TextEditingController(text: p['ffUid'] ?? '');
    final ignController = TextEditingController(text: p['ign'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text('Update MongoDB User Data', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name', labelStyle: TextStyle(color: Colors.white38)), style: const TextStyle(color: Colors.white)),
            TextField(controller: ffUidController, decoration: const InputDecoration(labelText: 'FF UID', labelStyle: TextStyle(color: Colors.white38)), style: const TextStyle(color: Colors.white)),
            TextField(controller: ignController, decoration: const InputDecoration(labelText: 'IGN', labelStyle: TextStyle(color: Colors.white38)), style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await provider.adminUpdateUser(p['id'] ?? p['_id'], {
                  'name': nameController.text.trim(),
                  'ffUid': ffUidController.text.trim(),
                  'ign': ignController.text.trim(),
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User updated in production!')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(BuildContext context, AppProvider provider, dynamic p) {
    final reasonController = TextEditingController();
    final isBanned = p['isBanned'] == true;

    if (isBanned) {
      // Logic for unbanning
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text('Ban Player', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason for ban', labelStyle: TextStyle(color: Colors.white38)),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await provider.adminBanUser(p['id'] ?? p['_id'], reasonController.text, 'PERMANENT');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Player banned successfully.')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('CONFIRM BAN'),
          ),
        ],
      ),
    );
  }
}
