import 'package:flutter/material.dart';
import '../../components/shops/all_reviews_page.dart';

class PartnerReviewsPage extends StatelessWidget {
  const PartnerReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AllReviewsPage(isPartner: true);
  }
}
