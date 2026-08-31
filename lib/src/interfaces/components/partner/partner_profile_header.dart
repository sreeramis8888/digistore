import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
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
      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AdvancedNetworkImage(
                imageUrl: logo ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: screenSize.responsivePadding(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  businessName,
                  style: kBodyTitleM.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category.isNotEmpty &&
                    category.toLowerCase() != '' &&
                    category.toLowerCase() != 'null') ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0XFFDFEAFF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: kSmallerTitleSB.copyWith(
                        fontSize: 10,
                        color: kPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: kSmallTitleL.copyWith(
                          color: const Color(0xFF616161),
                          fontSize: 12,
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
          const SizedBox(width: 8),
          InteractiveFeedbackButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                'partnerAccount',
                arguments: {'isEditMode': true},
              );
            },
            child: SvgPicture.asset('assets/svg/edit.svg'),
          ),
        ],
      ),
    );
  }
}
