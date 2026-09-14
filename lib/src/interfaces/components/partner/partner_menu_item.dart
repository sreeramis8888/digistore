import 'package:setgo/src/data/utils/interactive_feedback_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/screen_size_provider.dart';

class PartnerMenuItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final ScreenSizeData screenSize;
  final VoidCallback? onTap;
  final bool isDestructive;

  /// When true, renders as a standalone Digistore setting card.
  final bool asCard;

  const PartnerMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.screenSize,
    this.onTap,
    this.isDestructive = false,
    this.asCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor =
        isDestructive ? const Color(0xFFFF383C) : const Color(0xFF111827);

    final row = InteractiveFeedbackButton(
      onPressed: onTap ?? () {},
      scaleFactor: 0.98,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Center(child: icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Color(0xFF99A1AF),
            ),
          ],
        ),
      ),
    );

    if (!asCard) return row;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: row,
    );
  }
}
