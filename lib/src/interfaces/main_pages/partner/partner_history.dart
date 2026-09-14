import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/partner_history_provider.dart';
import '../../components/partner/partner_overview_cards.dart';
import '../../components/partner/partner_redemption_list.dart';
import '../../components/shimmers/card_shimmers.dart';

class PartnerHistoryPage extends ConsumerStatefulWidget {
  const PartnerHistoryPage({super.key});

  @override
  ConsumerState<PartnerHistoryPage> createState() => _PartnerHistoryPageState();
}

class _PartnerHistoryPageState extends ConsumerState<PartnerHistoryPage> {
  static const _bg = Color(0xFFF3F5F4);
  static const _accent = Color(0xFF6155F5);

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(partnerHistoryProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final historyState = ref.watch(partnerHistoryProvider);
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF111827),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        titleSpacing: canPop ? 0 : 16,
        title: Text(
          'History',
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF373737),
          ),
        ),
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
      ),
      body: SafeArea(
        child: historyState.isLoading
            ? CardShimmers.partnerHistoryShimmer(screenSize)
            : RefreshIndicator(
                color: _accent,
                onRefresh: () =>
                    ref.read(partnerHistoryProvider.notifier).refresh(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenSize.responsivePadding(8)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.responsivePadding(16),
                        ),
                        child: PartnerOverviewCards(
                          screenSize: screenSize,
                          lightStyle: true,
                          totalCustomers: historyState.data?.totalCustomers,
                          commissionAmount: historyState.data?.commissionAmount,
                          totalSalesViaSetgo: historyState
                              .data
                              ?.totalSalesViaSetgo
                              .toInt(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      PartnerRedemptionList(
                        screenSize: screenSize,
                        redemptions: historyState.data?.redemptions ?? [],
                      ),
                      if (historyState.isLoadingMore)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: screenSize.responsivePadding(16),
                            horizontal: screenSize.responsivePadding(16),
                          ),
                          child: CardShimmers.partnerRedemptionItemShimmer(
                            screenSize,
                          ),
                        ),
                      SizedBox(height: screenSize.responsivePadding(40)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
