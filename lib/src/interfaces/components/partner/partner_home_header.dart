import 'package:flutter/material.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../main_pages/partner/partner_profile_page.dart';

class PartnerHomeHeader extends StatelessWidget {
  final ScreenSizeData screenSize;

  const PartnerHomeHeader({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PartnerProfilePage(),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/png/shake.png', fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: screenSize.responsivePadding(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Freshmart Supermarket', style: kSubHeadingSB),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ernakulam',
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
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Icon(Icons.notifications_none, size: 24, color: kBlack),
        ),
      ],
    );
  }
}
