import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/constants/color_constants.dart';
import '../components/history/wallet_header.dart';
import '../components/history/transaction_tile.dart';
import '../components/history/wallet_empty_state.dart';
import '../../data/providers/transactions_provider.dart';
import '../../data/providers/screen_size_provider.dart';
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
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: canPop
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF373737),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'My Wallet',
          style: GoogleFonts.urbanist(
            color: const Color(0xFF373737),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        titleSpacing: canPop ? 0 : screenSize.responsivePadding(16),
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
                            slivers: const [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: WalletEmptyState(),
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            bottom: screenSize.responsivePadding(24),
                          ),
                          itemCount: paginated.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction =
                                paginated.transactions[index];
                            return TransactionTile.fromTransaction(transaction)
                                .fadeSlideInFromLeft(
                              delayMilliseconds: index * 40,
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
                        slivers: const [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: WalletEmptyState(),
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
