import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/utils/currency_formatter.dart';

class PartnerOverviewCards extends StatelessWidget {
  final ScreenSizeData screenSize;
  final int? totalCustomers;
  final double? commissionAmount;
  final int? totalSalesViaSetgo;

  /// Digistore History style (white metric cards). Home keeps the dark variant.
  final bool lightStyle;

  const PartnerOverviewCards({
    super.key,
    required this.screenSize,
    this.totalCustomers,
    this.commissionAmount,
    this.totalSalesViaSetgo,
    this.lightStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (lightStyle) {
      return _buildLightOverview();
    }
    return _buildDarkOverview();
  }

  Widget _buildLightOverview() {
    return Row(
      children: [
        _lightStatCard(
          'Total Customers',
          '${totalCustomers ?? 0}',
        ),
        SizedBox(width: screenSize.responsivePadding(12)),
        _lightStatCard(
          'Your Commission',
          formatCurrency(commissionAmount ?? 0),
        ),
        SizedBox(width: screenSize.responsivePadding(12)),
        _lightStatCard(
          'Total Sales',
          formatCurrency(totalSalesViaSetgo ?? 0),
        ),
      ],
    );
  }

  Widget _lightStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6155F5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkOverview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xCC2C1F37),
            Color(0xCC211127),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(screenSize.responsivePadding(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S OVERVIEW",
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFBBF24),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
          Row(
            children: [
              _darkStatCard(
                "Total\nCustomers",
                _formatCompact(totalCustomers ?? 0),
              ),
              SizedBox(width: screenSize.responsivePadding(12)),
              _darkStatCard(
                "Your\nCommission",
                _formatCompact(commissionAmount ?? 0),
              ),
              SizedBox(width: screenSize.responsivePadding(12)),
              _darkStatCard(
                "Total Sales\nvia Setgo",
                _formatCompact(totalSalesViaSetgo ?? 0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCompact(num value) {
    if (value >= 10000000) {
      final cr = value / 10000000;
      return cr % 1 == 0 ? '${cr.toInt()}Cr' : '${cr.toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      final lakhs = value / 100000;
      return lakhs % 1 == 0
          ? '${lakhs.toInt()}L'
          : '${lakhs.toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      final k = value / 1000;
      return k % 1 == 0 ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
    } else {
      if (value is double) {
        return value % 1 == 0
            ? value.toInt().toString()
            : value.toStringAsFixed(1);
      }
      return value.toString();
    }
  }

  Widget _darkStatCard(String title, String value) {
    return Expanded(
      child: Container(
        height: screenSize.responsivePadding(93),
        padding: EdgeInsets.all(screenSize.responsivePadding(12)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE6F4EA),
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFBBF24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
