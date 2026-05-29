import 'package:setgo/src/interfaces/animations/index.dart';
import 'package:setgo/src/interfaces/components/shimmers/card_shimmers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../components/history/wallet_header.dart';
import '../components/history/transaction_tile.dart';
import '../../data/providers/transactions_provider.dart';
import '../../data/providers/screen_size_provider.dart';
import '../components/empty_state.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final transactionsAsync = ref.watch(transactionsProvider());

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          'My Wallet',
          style: kBodyTitleM.copyWith(color: const Color(0xFF373737)),
        ),
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const WalletHeader(),
            Expanded(
              child: RefreshIndicator(
                color: kPrimaryColor,
                onRefresh: () async {
                  ref.invalidate(transactionsProvider);
                  await ref.read(transactionsProvider().future);
                },
                child: transactionsAsync.when(
                  data: (paginated) {
                    if (paginated.transactions.isEmpty) {
                      return CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: const EmptyState(
                              imagePath: 'assets/png/empty_history.png',
                              title: 'No transaction history',
                              subtitle:
                                  'You haven\'t earned or redeemed any points yet. Start exploring offers to earn points!',
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: paginated.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = paginated.transactions[index];
                        return TransactionTile.fromTransaction(
                          transaction,
                        ).fadeSlideInFromLeft(delayMilliseconds: index * 40);
                      },
                    );
                  },
                  loading: () => ListView.builder(
                    itemCount: 8,
                    itemBuilder: (context, index) =>
                        CardShimmers.transactionTileShimmer(screenSize),
                  ),
                  error: (e, s) => CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: const EmptyState(
                          imagePath: 'assets/png/empty_history.png',
                          title: 'No transaction history',
                          subtitle:
                              'You haven\'t earned or redeemed any points yet. Start exploring offers to earn points!',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
