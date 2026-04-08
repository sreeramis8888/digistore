import 'package:digistore/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/partner_history_provider.dart';
import '../../components/partner/partner_overview_cards.dart';
import '../../components/partner/partner_redemption_list.dart';

class PartnerHistoryPage extends ConsumerStatefulWidget {
  const PartnerHistoryPage({super.key});

  @override
  ConsumerState<PartnerHistoryPage> createState() => _PartnerHistoryPageState();
}

class _PartnerHistoryPageState extends ConsumerState<PartnerHistoryPage> {
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

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: historyState.isLoading
            ? const Center(child: LoadingAnimation())
            : historyState.error != null
            ? Center(child: Text(historyState.error!))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(partnerHistoryProvider.notifier).refresh(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: kTextColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: screenSize.responsivePadding(12)),
                            Text(
                              'History',
                              style: kBodyTitleM.copyWith(
                                color: const Color(0xFF373737),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.responsivePadding(24)),
                        Text(
                          "Performance Overview",
                          style: kSmallTitleB.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: screenSize.responsivePadding(16)),
                        PartnerOverviewCards(
                          screenSize: screenSize,
                          totalCustomers: historyState.data?.totalCustomers,
                          commissionAmount: historyState.data?.commissionAmount,
                          totalSalesViaSetgo: historyState
                              .data
                              ?.totalSalesViaSetgo
                              .toInt(),
                        ),
                        SizedBox(height: screenSize.responsivePadding(24)),
                        Text(
                          'Redemption History',
                          style: kSmallTitleB.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: screenSize.responsivePadding(12)),
                        PartnerRedemptionList(
                          screenSize: screenSize,
                          redemptions: historyState.data?.redemptions ?? [],
                        ),
                        if (historyState.isLoadingMore)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: screenSize.responsivePadding(16),
                            ),
                            child: const Center(child: LoadingAnimation()),
                          ),
                        SizedBox(height: screenSize.responsivePadding(40)),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
