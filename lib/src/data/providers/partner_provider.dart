import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/partner_model.dart';
import 'api_provider.dart';

class PartnerNotifier extends Notifier<PartnerModel?> {
  @override
  PartnerModel? build() => null;

  Future<void> savePartner(PartnerModel partner) async {
    // We can store partner data in a separate key in secure storage if needed
    // For now, let's just keep it in memory
    state = partner;
  }

  Future<void> clearPartner() async {
    state = null;
  }

  Future<int?> getPartnerProfile() async {
    final api = ref.read(apiProvider);
    final response = await api.get('/profile', requireAuth: true);

    if (response.success && response.data != null) {
      final partnerData = response.data!['data'];
      if (partnerData != null) {
        final partner = PartnerModel.fromJson(partnerData as Map<String, dynamic>);
        state = partner;
        return 200;
      }
    }
    return response.statusCode;
  }
}

final partnerProvider = NotifierProvider<PartnerNotifier, PartnerModel?>(PartnerNotifier.new);
