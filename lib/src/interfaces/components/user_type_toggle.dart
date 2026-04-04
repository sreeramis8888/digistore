import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/providers/user_type_provider.dart';
import '../../data/providers/screen_size_provider.dart';

class UserTypeToggle extends ConsumerWidget {
  const UserTypeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType = ref.watch(userTypeProvider);
    final screenSize = ref.watch(screenSizeProvider);

    return Container(
      width: double.infinity,
      height: screenSize.responsivePadding(52),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(screenSize.responsivePadding(12)),
      ),
      padding: EdgeInsets.all(screenSize.responsivePadding(4)),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            alignment: userType == UserType.customer
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - screenSize.responsivePadding(56)) / 2,
              height: double.infinity,
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(screenSize.responsivePadding(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(userTypeProvider.notifier).setUserType(UserType.customer),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: screenSize.responsivePadding(18),
                          color: userType == UserType.customer ? kPrimaryColor : kGreyDarker,
                        ),
                        SizedBox(width: screenSize.responsivePadding(8)),
                        Text(
                          'Customer',
                          style: kSmallTitleSB.copyWith(
                            color: userType == UserType.customer ? kPrimaryColor : kGreyDarker,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(userTypeProvider.notifier).setUserType(UserType.partner),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: screenSize.responsivePadding(18),
                          color: userType == UserType.partner ? kPrimaryColor : kGreyDarker,
                        ),
                        SizedBox(width: screenSize.responsivePadding(8)),
                        Text(
                          'Partner',
                          style: kSmallTitleSB.copyWith(
                            color: userType == UserType.partner ? kPrimaryColor : kGreyDarker,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
