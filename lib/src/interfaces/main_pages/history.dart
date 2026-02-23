import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../components/history/wallet_header.dart';
import '../components/history/transaction_tile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'isEarned': true, 'title': 'Points Earned', 'subtitle': 'From: Daily Mart', 'points': '300', 'date': 'Today at 2:45 PM'},
      {'isEarned': true, 'title': 'Points Earned', 'subtitle': 'From: Coffee House', 'points': '1500', 'date': 'Today at 10:30 AM'},
      {'isEarned': false, 'title': 'Points Used', 'subtitle': 'Purchasing Voucher', 'points': '-200', 'date': 'Today at 2:45 PM'},
      {'isEarned': true, 'title': 'Points Earned', 'subtitle': 'From: Bookstore', 'points': '2500', 'date': '08-09-2026 at 1:00 PM'},
      {'isEarned': true, 'title': 'Points Earned', 'subtitle': 'From: Bookstore', 'points': '2500', 'date': '08-09-2026 at 1:00 PM'},
      {'isEarned': true, 'title': 'Points Earned', 'subtitle': 'From: Bookstore', 'points': '2500', 'date': '08-09-2026 at 1:00 PM'},
      {'isEarned': true, 'title': 'Points Earned', 'subtitle': 'From: Bookstore', 'points': '2500', 'date': '08-09-2026 at 1:00 PM'},
      {'isEarned': false, 'title': 'Points Used', 'subtitle': 'Offer Purchase', 'points': '-100', 'date': '08-09-2026 at 1:00 PM'},
    ];

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text('My Wallet', style: kHeadTitleB),
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const WalletHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final t = transactions[index];
                  return TransactionTile(
                    isEarned: t['isEarned'] as bool,
                    title: t['title'] as String,
                    subtitle: t['subtitle'] as String,
                    points: t['points'] as String,
                    date: t['date'] as String,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
