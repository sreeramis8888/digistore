import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../advanced_network_image.dart';

class PartnerProfileHeader extends ConsumerWidget {
  final ScreenSizeData screenSize;

  const PartnerProfileHeader({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = ref.watch(partnerProvider);
    final businessName =
        partner?.businessDetails?.businessName ?? 'Partners Shop';
    final location = partner?.businessDetails?.address ?? 'Location';
    final logo = partner?.businessInfo?.businessLogo;
    final category = partner?.businessDetails?.businessType ?? '';

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: logo != null && logo.isNotEmpty
                ? AdvancedNetworkImage(
                    imageUrl: logo,
                    fit: BoxFit.cover,
                    disableFade: true,
                  )
                : Container(
                    color: const Color(0xFFF3F4F6),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 32,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          businessName,
                          style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InteractiveFeedbackButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            'partnerAccount',
                            arguments: {'isEditMode': true},
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/svg/edit.svg',
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF1C274C),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (category.isNotEmpty &&
                      category.toLowerCase() != 'null') ...[
                    const Spacer(),
                    Text(
                      category,
                      style: GoogleFonts.urbanist(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4E4E4E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
