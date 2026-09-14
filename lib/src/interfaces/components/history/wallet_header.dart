import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/home_provider.dart';
import '../../../data/models/home_data_model.dart';

class WalletHeader extends ConsumerWidget {
  const WalletHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final user = ref.watch(userProvider);
    final homeDataState = ref.watch(homeDataProvider).value;

    final name = (user?.name != null && user!.name!.trim().isNotEmpty)
        ? user.name!.trim().toUpperCase()
        : 'ABDUL WAHAAB';

    int points = user?.pointsBalance ?? 0;

    if (homeDataState is CustomerHomeState) {
      final loyaltyCard = homeDataState.data.loyaltyCard;
      if (loyaltyCard != null && loyaltyCard.pointsBalance != null) {
        points = loyaltyCard.pointsBalance!;
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenSize.responsivePadding(16),
        screenSize.responsivePadding(16),
        screenSize.responsivePadding(16),
        screenSize.responsivePadding(10),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(20),
          vertical: screenSize.responsivePadding(20),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF7770D2), Color(0xFF6155F5)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.082),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your available points:',
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: screenSize.responsivePadding(4)),
                  Text(
                    name,
                    style: GoogleFonts.urbanist(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: screenSize.responsivePadding(12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(12),
                vertical: screenSize.responsivePadding(8),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$points',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6155F5),
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(4)),
                  SvgPicture.asset(
                    'assets/svg/coin.svg',
                    width: 12,
                    height: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
