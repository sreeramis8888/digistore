import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../components/history/wallet_header.dart';
import '../components/history/transaction_tile.dart';
import '../../data/providers/transactions_provider.dart';
import '../../data/providers/screen_size_provider.dart';
import '../components/empty_state.dart';
import '../components/guest_login_prompt.dart';
import '../../data/utils/global_variables.dart';
import 'package:setgo/src/interfaces/animations/index.dart';
import 'package:setgo/src/interfaces/components/shimmers/card_shimmers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final transactionsAsync = ref.watch(transactionsProvider());

    return Scaffold(
      backgroundColor: kRewardPageBg,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: kWhite,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF111827),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Wallet',
          style: kSmallTitleB.copyWith(
            color: const Color(0xFF111827),
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: GlobalVariables.isGuest
          ? const GuestLoginPrompt(
              title: 'Login Required',
              subtitle:
                  'Please login or register to view your wallet history.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          padding: EdgeInsets.fromLTRB(
                            screenSize.responsivePadding(16),
                            0,
                            screenSize.responsivePadding(16),
                            screenSize.responsivePadding(24),
                          ),
                          itemCount: paginated.transactions.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: screenSize.responsivePadding(12),
                                  top: screenSize.responsivePadding(4),
                                ),
                                child: Text(
                                  'Transaction History',
                                  style: kSmallTitleB.copyWith(
                                    color: const Color(0xFF111827),
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                            final transaction =
                                paginated.transactions[index - 1];
                            return TransactionTile.fromTransaction(transaction)
                                .fadeSlideInFromLeft(
                              delayMilliseconds: (index - 1) * 40,
                            );
                          },
                        );
                      },
                      loading: () => ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.responsivePadding(16),
                        ),
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
    );
  }
}
