import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final wallet = provider.wallet;
    final balance = (wallet?['balance'] ?? wallet?['amount'] ?? 0.0).toDouble();
    final withdrawals = provider.withdrawals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WALLET', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF131B2E),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchUserData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBalanceCard(balance),
            const SizedBox(height: 24),
            _buildActionButtons(context, provider),
            const SizedBox(height: 32),
            const Text(
              'WITHDRAWAL HISTORY',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (withdrawals.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('No withdrawal history found', style: TextStyle(color: Colors.grey)),
              ))
            else
              ...withdrawals.map((w) => _buildWithdrawalItem(w)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              const Text('CURRENT BALANCE', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const Icon(Icons.account_balance_wallet, color: Color(0xFFFF5722)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${balance.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Instantly syncs with MongoDB production database', style: TextStyle(color: Colors.white24, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.add_circle_outline,
            label: 'TOP UP',
            color: const Color(0xFFFF5722),
            onPressed: () => _showTopupDialog(context, provider),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton(
            icon: Icons.outbound_outlined,
            label: 'WITHDRAW',
            color: const Color(0xFF38BDF8),
            onPressed: () => _showWithdrawDialog(context, provider),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: onPressed,
    );
  }

  Widget _buildWithdrawalItem(dynamic w) {
    final status = w['status']?.toString().toUpperCase() ?? 'PENDING';
    final amount = w['amount'] ?? 0.0;
    final date = w['createdAt'] != null ? DateTime.parse(w['createdAt']) : DateTime.now();
    
    Color statusColor = Colors.orange;
    if (status == 'COMPLETED') statusColor = Colors.green;
    if (status == 'FAILED') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.history, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Withdrawal Request', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM dd, yyyy • hh:mm a').format(date), style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('-₹$amount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _showTopupDialog(BuildContext context, AppProvider provider) {
    final amountController = TextEditingController();
    final utrController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text('Top Up Wallet', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter amount and UTR number from your payment app.', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹)', labelStyle: TextStyle(color: Colors.white38)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: utrController,
              decoration: const InputDecoration(labelText: 'UTR / Transaction ID', labelStyle: TextStyle(color: Colors.white38)),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount < 10) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum top-up is ₹10')));
                return;
              }
              Navigator.pop(ctx);
              try {
                await provider.topupWallet(amount, utrController.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Top-up request submitted!')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, AppProvider provider) {
    final amountController = TextEditingController();
    final upiController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text('Withdraw Funds', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Funds will be sent to your UPI ID within 24 hours.', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹)', labelStyle: TextStyle(color: Colors.white38)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: upiController,
              decoration: const InputDecoration(labelText: 'UPI ID (e.g. name@okaxis)', labelStyle: TextStyle(color: Colors.white38)),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount < 50) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum withdrawal is ₹50')));
                return;
              }
              Navigator.pop(ctx);
              try {
                await provider.requestWithdrawal(amount, upiController.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal request sent!')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('WITHDRAW'),
          ),
        ],
      ),
    );
  }
}
