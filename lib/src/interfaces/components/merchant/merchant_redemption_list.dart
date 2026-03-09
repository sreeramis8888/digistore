import 'package:flutter/material.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class MerchantRedemptionList extends StatelessWidget {
  final ScreenSizeData screenSize;
  final int count;

  const MerchantRedemptionList({
    super.key,
    required this.screenSize,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (context, index) =>
          SizedBox(height: screenSize.responsivePadding(12)),
      itemBuilder: (context, index) {
        final isVerified = index % 2 == 0;
        final statusColor = isVerified
            ? const Color(0xFF139F5A)
            : const Color(0xFFEB4335);
        final statusText = isVerified ? 'Verified' : 'Rejected';

        return Container(
          padding: EdgeInsets.all(screenSize.responsivePadding(16)),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.002),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/png/shake.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Beverage Bonanza',
                          style: kSmallTitleB.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: screenSize.responsivePadding(4)),
                        Text(
                          'Mix and match 3 drinks → Get 20% off',
                          maxLines: 1,
                          style: kSmallerTitleM.copyWith(
                            color: const Color(0xFF6B7280),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    statusText,
                    style: kSmallTitleB.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(10)),
              const Divider(color: Color(0xFFDFDFDF), height: .5),
              SizedBox(height: screenSize.responsivePadding(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Redeemed on: ',
                          style: kSmallerTitleM.copyWith(
                            color: const Color(0xFFA1A1AA),
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        TextSpan(
                          text: '03:30 PM, Yesterday',
                          style: kSmallerTitleM.copyWith(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Redemption ID: ',
                          style: kSmallerTitleM.copyWith(
                            color: const Color(0xFFA1A1AA),
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        TextSpan(
                          text: '12345',
                          style: kSmallerTitleM.copyWith(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
