import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/partner_plan_details.dart';
import 'api_provider.dart';

final partnerPlanDetailsProvider =
    FutureProvider.autoDispose<PartnerPlanDetails>((ref) async {
  final api = ref.watch(apiProvider);
  final response = await api.get('/profile/plan-details', requireAuth: true);

  if (response.success && response.data != null) {
    final data = response.data!['data'];
    if (data != null) {
      return PartnerPlanDetails.fromJson(data as Map<String, dynamic>);
    }
  }
  throw Exception(response.message ?? 'Failed to load plan details');
});
