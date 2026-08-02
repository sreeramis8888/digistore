import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/partner_plan_details_provider.dart';
import '../../../data/models/partner_plan_details.dart';

class PartnerPlanDetailsSheet extends ConsumerWidget {
  const PartnerPlanDetailsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PartnerPlanDetailsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final planDetailsAsync = ref.watch(partnerPlanDetailsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: screenSize.responsivePadding(12),
        left: screenSize.responsivePadding(20),
        right: screenSize.responsivePadding(20),
        bottom: screenSize.responsivePadding(24) +
            MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plan Details',
                style: kSubHeadingSB.copyWith(fontSize: 18, color: kBlack),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, color: kGreyDark),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: screenSize.responsivePadding(12)),
          planDetailsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
              ),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline_rounded, color: kRed, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load plan details',
                    style: kSmallTitleM.copyWith(color: kRed),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    err.toString(),
                    style: kSmallerTitleR.copyWith(color: kGreyDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(partnerPlanDetailsProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Retry',
                        style: kSmallTitleM.copyWith(color: kWhite)),
                  ),
                ],
              ),
            ),
            data: (planDetails) {
              final currentPlan = planDetails.currentPlan;
              final snapshot = currentPlan?.planSnapshot;
              final planName = snapshot?.displayName ??
                  currentPlan?.planId?.displayName ??
                  'No Plan';
              final status = planDetails.subscriptionStatus ??
                  currentPlan?.status ??
                  'inactive';
              final isActive = status.toLowerCase() == 'active';
              final expiryDate =
                  planDetails.planExpiryDate ?? currentPlan?.endDate;
              final daysRemaining = planDetails.planInfo?.daysRemaining ??
                  currentPlan?.daysRemaining ??
                  0;
              final type = currentPlan?.subscriptionType ?? 'free';

              // Limit values
              final limits = planDetails.limits;
              final branchLimit =
                  limits?.branchLimit ?? snapshot?.features?.branchLimit ?? 0;
              final hexCount =
                  limits?.hexCount ?? snapshot?.features?.hexCount ?? 0;
              final coverageArea = limits?.coverageAreaKm2 ??
                  snapshot?.features?.coverageAreaKm2 ??
                  0;
              final maxLeads = currentPlan?.planSnapshot?.limits?.maxLeads ??
                  currentPlan?.planId?.limits?.maxLeads ??
                  0;
              final maxRedemptions =
                  currentPlan?.planSnapshot?.limits?.maxRedemptions ??
                      currentPlan?.planId?.limits?.maxRedemptions ??
                      0;
              final maxOffers = currentPlan?.planSnapshot?.limits?.maxOffers ??
                  currentPlan?.planId?.limits?.maxOffers ??
                  0;
              final allKerala = limits?.isAllKeralaAllowed ??
                  snapshot?.features?.isAllKeralaAllowed ??
                  false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Plan overview card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isActive
                            ? [const Color(0xFFE8F0FE), const Color(0xFFF4F8FF)]
                            : [const Color(0xFFFEE8E8), const Color(0xFFFFF4F4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFFADC7FF)
                            : const Color(0xFFFFADAD),
                      ),
                    ),
                    padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  planName.toUpperCase(),
                                  style: kBodyTitleB.copyWith(
                                    color: kPrimaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(
                                    height: screenSize.responsivePadding(4)),
                                Text(
                                  type == 'paid'
                                      ? 'Paid Subscription'
                                      : 'Free / Trial Plan',
                                  style: kSmallerTitleM.copyWith(
                                      color: kGreyDark),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? kGreen.withOpacity(0.12)
                                    : kRed.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isActive ? kGreen : kRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isActive ? 'Active' : 'Inactive',
                                    style: kSmallerTitleB.copyWith(
                                      color: isActive ? kGreen : kRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Color(0xFFADC7FF), height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expiryDate != null
                                      ? 'Expiry Date'
                                      : 'No Expiry',
                                  style:
                                      kSmallerTitleR.copyWith(color: kGreyDark),
                                ),
                                if (expiryDate != null) ...[
                                  SizedBox(
                                      height: screenSize.responsivePadding(2)),
                                  Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(expiryDate),
                                    style:
                                        kSmallTitleSB.copyWith(color: kBlack),
                                  ),
                                ],
                              ],
                            ),
                            if (isActive && expiryDate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$daysRemaining Days Left',
                                  style: kSmallerTitleSB.copyWith(
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  Text(
                    'Plan Features & Limits',
                    style: kSmallTitleB.copyWith(color: kBlack),
                  ),
                  SizedBox(height: screenSize.responsivePadding(10)),
                  // Limits / features grid or list
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        _buildLimitRow(
                          screenSize,
                          icon: Icons.storefront_outlined,
                          title: 'Branch Limit',
                          value:
                              '$branchLimit Branch${branchLimit > 1 ? 's' : ''}',
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        _buildLimitRow(
                          screenSize,
                          icon: Icons.hexagon_outlined,
                          title: 'Hexagons Count',
                          value: '$hexCount Hexagon${hexCount > 1 ? 's' : ''}',
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        _buildLimitRow(
                          screenSize,
                          icon: Icons.map_outlined,
                          title: 'Coverage Area',
                          value: '$coverageArea km²',
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        _buildLimitRow(
                          screenSize,
                          icon: Icons.people_outline_rounded,
                          title: 'Max Leads Limit',
                          value: '$maxLeads Leads',
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        _buildLimitRow(
                          screenSize,
                          icon: Icons.monetization_on_outlined,
                          title: 'Max Redemptions',
                          value: '$maxRedemptions Redemptions',
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        _buildLimitRow(
                          screenSize,
                          icon: Icons.local_offer_outlined,
                          title: 'Max Offers Limit',
                          value:
                              '$maxOffers Offer${maxOffers > 1 ? 's' : ''}',
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        _buildLimitRow(
                          screenSize,
                          icon: Icons.map_rounded,
                          title: 'All Kerala Allowed',
                          value: allKerala ? 'Yes' : 'No',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLimitRow(
    ScreenSizeData screenSize, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kGreyDark),
          SizedBox(width: screenSize.responsivePadding(12)),
          Expanded(
            child: Text(
              title,
              style: kSmallTitleL.copyWith(color: kGreyDarker),
            ),
          ),
          Text(
            value,
            style: kSmallTitleSB.copyWith(color: kBlack),
          ),
        ],
      ),
    );
  }
}
