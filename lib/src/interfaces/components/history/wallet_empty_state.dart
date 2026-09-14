import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/router/nav_router.dart';

class WalletEmptyState extends ConsumerWidget {
  const WalletEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(24),
          vertical: screenSize.responsivePadding(32),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration Container
            Container(
              width: screenSize.responsivePadding(200),
              height: screenSize.responsivePadding(200),
              decoration: BoxDecoration(
                color: const Color(0xFF6155F5).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: screenSize.responsivePadding(80),
                  color: const Color(0xFF6155F5),
                ),
              ),
            ),
            SizedBox(height: screenSize.responsivePadding(24)),
            // Title
            Text(
              'No Wallet Activity',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.responsivePadding(8)),
            // Subtitle
            Text(
              'Start shopping to earn points and track them here.',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenSize.responsivePadding(24)),
            // Action Button
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref.read(selectedIndexProvider.notifier).updateIndex(1);
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16),
                  vertical: screenSize.responsivePadding(8),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6155F5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Offers',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6155F5),
                      ),
                    ),
                    SizedBox(width: screenSize.responsivePadding(6)),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: screenSize.responsivePadding(16),
                      color: const Color(0xFF6155F5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
