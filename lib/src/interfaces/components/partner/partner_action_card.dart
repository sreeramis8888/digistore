import 'package:setgo/src/data/utils/interactive_feedback_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/screen_size_provider.dart';

class PartnerActionCard extends StatelessWidget {
  final ScreenSizeData screenSize;
  final String title;
  final IconData iconData;
  final VoidCallback? onTap;
  final bool expand;

  const PartnerActionCard({
    super.key,
    required this.screenSize,
    required this.title,
    required this.iconData,
    this.onTap,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = InteractiveFeedbackButton(
      onPressed: onTap,
      scaleFactor: 0.95,
      child: Container(
        width: expand ? null : double.infinity,
        height: 84,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: const Color(0xFF8E8E8E), size: 24),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.urbanist(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

    if (expand) {
      return Expanded(child: card);
    }
    return card;
  }
}
