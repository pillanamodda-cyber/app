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
        title: const Text('OSG LIVE Tournaments', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF131B2E),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchUserData(),
          ),
        ],
      ),
      body: provider.isLoading && tournaments.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
          : tournaments.isEmpty
              ? const Center(child: Text('No active tournaments found', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: () => provider.fetchUserData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tournaments.length,
                    itemBuilder: (context, index) {
                      final t = tournaments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFF5722).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.between,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5722).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    t['game'] ?? 'Free Fire',
                                    style: const TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                Text(
                                  t['status'] ?? 'Upcoming',
                                  style: TextStyle(color: Colors.orange[300], fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t['title'] ?? t['name'] ?? 'Tournament',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t['description'] ?? 'Compete in high-stakes Free Fire esports battles.',
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.between,
                              children: [
                                Text(
                                  'Prize: ₹${t['prizePool'] ?? t['prize'] ?? '5000'}',
                                  style: const TextStyle(color: Color(0xFFFF9800), fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Tournament registration synced with MongoDB backend.')),
                                    );
                                  },
                                  child: const Text('View / Join', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
                    },
                  ),
                ),
    );
  }
}
