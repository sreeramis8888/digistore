import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/providers/notifications_provider.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/advanced_network_image.dart';
import '../../main_pages/partner/partner_profile_page.dart';
import 'partner_overview_cards.dart';

class PartnerHomeHeader extends ConsumerWidget {
  final ScreenSizeData screenSize;
  final int? totalCustomers;
  final double? commissionAmount;
  final int? totalSalesViaSetgo;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchChanged;

  const PartnerHomeHeader({
    super.key,
    required this.screenSize,
    this.totalCustomers,
    this.commissionAmount,
    this.totalSalesViaSetgo,
    this.searchController,
    this.searchFocusNode,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = ref.watch(partnerProvider);
    final businessName = partner?.businessDetails?.businessName ?? 'Partners Shop';
    final location = partner?.businessDetails?.address ?? 'Location';
    final logo = partner?.businessInfo?.businessLogo;
    final partnerName = partner?.businessDetails?.businessName?.split(' ').first ?? 'Partner';

    final initial = businessName.isNotEmpty ? businessName[0].toUpperCase() : 'P';
    final unreadCount = ref.watch(notificationsProvider).unreadCount;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6D0CB2),
            Color(0xFFBD6AF1),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            screenSize.responsivePadding(16),
            screenSize.responsivePadding(12),
            screenSize.responsivePadding(16),
            screenSize.responsivePadding(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Profile & Notification Bell Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InteractiveFeedbackButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PartnerProfilePage(),
                          ),
                        );
                      },
                      scaleFactor: 0.98,
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10B981),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: logo != null && logo.isNotEmpty
                                ? AdvancedNetworkImage(
                                    imageUrl: logo,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text(
                                      initial,
                                      style: GoogleFonts.urbanist(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(width: screenSize.responsivePadding(12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  businessName,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        location,
                                        style: GoogleFonts.urbanist(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFFE6F4EA),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InteractiveFeedbackButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'notifications');
                    },
                    scaleFactor: 1.05,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.125),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: kRed,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenSize.responsivePadding(20)),

              // Greeting
              Text(
                'Welcome Back, $partnerName',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: screenSize.responsivePadding(16)),

              // Search Bar
              Container(
                height: screenSize.responsivePadding(52),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFF6B7280),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        onTapOutside: (_) => searchFocusNode?.unfocus(),
                        onChanged: onSearchChanged,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111827),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search for offers',
                          hintStyle: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenSize.responsivePadding(20)),

              // Today's Overview Card
              PartnerOverviewCards(
                screenSize: screenSize,
                totalCustomers: totalCustomers,
                commissionAmount: commissionAmount,
                totalSalesViaSetgo: totalSalesViaSetgo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

