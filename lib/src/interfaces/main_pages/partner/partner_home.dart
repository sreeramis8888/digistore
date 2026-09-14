import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/home_data_model.dart';
import '../../../data/models/partner_home_data.dart';
import '../../../data/providers/home_provider.dart';
import '../../../data/providers/partner_bookings_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/partner/partner_booking_requests.dart';
import '../../components/partner/partner_home_header.dart';
import '../../components/partner/partner_quick_actions.dart';
import '../../components/partner/partner_recent_offers.dart';
import '../../components/partner/partner_uploaded_products.dart';
import '../../components/shimmers/partner_home_shimmer.dart';

class PartnerHomePage extends ConsumerStatefulWidget {
  const PartnerHomePage({super.key});

  @override
  ConsumerState<PartnerHomePage> createState() => _PartnerHomePageState();
}

class _PartnerHomePageState extends ConsumerState<PartnerHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final homeDataAsync = ref.watch(homeDataProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F4),
        body: RefreshIndicator(
          color: const Color(0xFF6D0CB2),
          onRefresh: () async {
            await Future.wait([
              ref.refresh(homeDataProvider.future),
              ref.refresh(partnerHomeBookingRequestsProvider.future),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: homeDataAsync.when(
              data: (state) {
                PartnerHomeData? data;
                if (state is PartnerHomeState) {
                  data = state.data;
                }

                return _buildPartnerContent(context, data, screenSize);
              },
              loading: () => Column(
                children: [
                  PartnerHomeHeader(
                    screenSize: screenSize,
                    searchController: _searchController,
                    searchFocusNode: _searchFocusNode,
                    onSearchChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: PartnerHomeShimmer(),
                  ),
                ],
              ),
              error: (err, stack) => _buildPartnerContent(context, null, screenSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerContent(
    BuildContext context,
    PartnerHomeData? data,
    ScreenSizeData screenSize,
  ) {
    final q = _searchQuery.trim().toLowerCase();

    final filteredOffers = data?.recentOffers?.where((offer) {
      if (q.isEmpty) return true;
      final title = offer.title?.toLowerCase() ?? '';
      final desc = offer.description?.toLowerCase() ?? '';
      final cat = offer.category?.name?.toLowerCase() ?? '';
      return title.contains(q) || desc.contains(q) || cat.contains(q);
    }).toList();

    final filteredProducts = data?.recentProducts?.where((p) {
      if (q.isEmpty) return true;
      final title = p.title?.toLowerCase() ?? '';
      final desc = p.description?.toLowerCase() ?? '';
      final tags = p.tags?.join(' ').toLowerCase() ?? '';
      return title.contains(q) || desc.contains(q) || tags.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Dark Zone with Gradient, Profile, Greeting, Search & Today's Overview
        PartnerHomeHeader(
          screenSize: screenSize,
          totalCustomers: data?.totalCustomers,
          commissionAmount: data?.commissionAmount,
          totalSalesViaSetgo: data?.totalSalesViaSetgo,
          searchController: _searchController,
          searchFocusNode: _searchFocusNode,
          onSearchChanged: _onSearchChanged,
        ),

        // Light Content Zone
        Padding(
          padding: EdgeInsets.only(
            top: screenSize.responsivePadding(20),
            bottom: screenSize.responsivePadding(40),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Quick Actions
              PartnerQuickActions(screenSize: screenSize),

              SizedBox(height: screenSize.responsivePadding(28)),

              // Section 2: Recently Uploaded Offers
              if (filteredOffers != null && filteredOffers.isNotEmpty) ...[
                PartnerRecentOffers(
                  screenSize: screenSize,
                  offers: filteredOffers,
                ),
                SizedBox(height: screenSize.responsivePadding(28)),
              ],

              // Section 3: Uploaded Products
              if (filteredProducts != null && filteredProducts.isNotEmpty) ...[
                PartnerUploadedProducts(
                  screenSize: screenSize,
                  products: filteredProducts,
                ),
                SizedBox(height: screenSize.responsivePadding(28)),
              ],

              // Section 4: Booking Requests
              PartnerBookingRequests(screenSize: screenSize),
            ],
          ),
        ),
      ],
    );
  }
}

