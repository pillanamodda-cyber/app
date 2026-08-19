import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/app_provider.dart';

class TournamentsTab extends StatelessWidget {
  const TournamentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final tournaments = provider.tournaments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OSG LIVE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: const Color(0xFF131B2E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFF5722)),
            onPressed: () => provider.fetchUserData(),
          ),
        ],
      ),
      body: provider.isLoading && tournaments.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
          : RefreshIndicator(
              onRefresh: () => provider.fetchUserData(),
              color: const Color(0xFFFF5722),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  const Text(
                    'ACTIVE TOURNAMENTS',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  if (tournaments.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No active tournaments found', style: TextStyle(color: Colors.grey)),
                    ))
                  else
                    ...tournaments.map((t) => _buildTournamentCard(context, provider, t)).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF5722).withOpacity(0.8), const Color(0xFFFF9800).withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Win Big Today!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Join high-stakes Free Fire matches and climb the leaderboard.', style: TextStyle(color: Colors.whiteCC, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF5722)),
            onPressed: () {},
            child: const Text('VIEW RANKINGS'),
          ),
        ],
      ),
    ).animate().fadeIn().scale(duration: 400.ms);
  }

  Widget _buildTournamentCard(BuildContext context, AppProvider provider, dynamic t) {
    final status = t['status']?.toString().toUpperCase() ?? 'UPCOMING';
    final isLive = status == 'LIVE';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLive ? const Color(0xFFFF5722) : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Image placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=500'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLive ? Colors.red : Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLive) ...[
                          const Icon(Icons.circle, size: 8, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['title'] ?? t['name'] ?? 'Tournament', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.emoji_events, size: 16, color: Color(0xFFFF9800)),
                    const SizedBox(width: 4),
                    Text('Prize: ₹${t['prizePool'] ?? t['prize'] ?? '0'}', style: const TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.people, size: 16, color: Colors.white60),
                    const SizedBox(width: 4),
                    Text('${t['registeredTeamsCount'] ?? 0}/${t['maxTeams'] ?? 12} Teams', style: const TextStyle(color: Colors.white60)),
                  ],
                ),
                const Divider(color: Colors.white10, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ENTRY FEE', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        Text('₹${t['entryFee'] ?? 0}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5722),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showJoinDialog(context, provider, t),
                      child: const Text('JOIN NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  void _showJoinDialog(BuildContext context, AppProvider provider, dynamic t) {
    if (!provider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to join tournaments')));
      return;
    }

    if (provider.myTeams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You need a team to join. Create one in the Teams tab!')));
      return;
    }

    String? selectedTeamId = provider.myTeams.first['id'] ?? provider.myTeams.first['_id'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF131B2E),
          title: const Text('Register for Tournament', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select your team to compete:', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTeamId,
                dropdownColor: const Color(0xFF131B2E),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white05,
                  border: OutlineInputBorder(),
                ),
                items: provider.myTeams.map<DropdownMenuItem<String>>((team) {
                  return DropdownMenuItem<String>(
                    value: team['id'] ?? team['_id'],
                    child: Text(team['name'] ?? 'Team', style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedTeamId = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await provider.joinTournament(t['id'] ?? t['_id'], selectedTeamId!);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('CONFIRM'),
            ),
          ],
        ),
      ),
    );
  }
}
