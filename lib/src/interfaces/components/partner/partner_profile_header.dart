import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/partner_provider.dart';
import '../advanced_network_image.dart';

class PartnerProfileHeader extends ConsumerWidget {
  final ScreenSizeData screenSize;

  const PartnerProfileHeader({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = ref.watch(partnerProvider);
    final businessName = partner?.businessDetails?.businessName ?? 'Partners Shop';
    final location = partner?.businessDetails?.address ?? 'Location';
    final logo = partner?.businessInfo?.businessLogo;
    final tagline = partner?.businessInfo?.tagline ?? 'Daily Needs';

    return Container(
      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        businessName,
                        style: kBodyTitleM.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryLightColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tagline,
                        style: kSmallTitleL.copyWith(
                          fontSize: 10,
                          color: kSecondaryColor,
                        ),
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
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: kSmallTitleL.copyWith(
                        color: const Color(0xFF616161),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
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
