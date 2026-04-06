import 'package:flutter/material.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/models/redemption_model.dart';
import '../advanced_network_image.dart';
import 'package:intl/intl.dart';

class PartnerRedemptionList extends StatelessWidget {
  final ScreenSizeData screenSize;
  final List<RedemptionModel> redemptions;

  const PartnerRedemptionList({
    super.key,
    required this.screenSize,
    required this.redemptions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: redemptions.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: screenSize.responsivePadding(12)),
      itemBuilder: (context, index) {
        final redemption = redemptions[index];
        final isCompleted = redemption.status == 'completed';
        final statusColor = isCompleted
            ? const Color(0xFF139F5A)
            : const Color(0xFFEB4335);
        
        final formattedDate = redemption.redeemedAt != null 
            ? DateFormat('hh:mm a, dd MMM').format(redemption.redeemedAt!)
            : 'N/A';

        final offer = redemption.offerId;
        final user = redemption.publicUserId;

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
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: AdvancedNetworkImage(
                        imageUrl: (offer?.images != null && offer!.images!.isNotEmpty)
                            ? offer.images![0]
                            : '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer?.title ?? 'Redeemed Offer',
                          style: kSmallTitleB.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenSize.responsivePadding(4)),
                        Text(
                          'Customer: ${user?.name ?? 'Unknown'}',
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
                    redemption.status?.toUpperCase() ?? 'N/A',
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
                          text: formattedDate,
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
                          text: 'Sale: ',
                          style: kSmallerTitleM.copyWith(
                            color: const Color(0xFFA1A1AA),
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        TextSpan(
                          text: '₹${redemption.saleAmount ?? 0}',
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
