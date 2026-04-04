import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/home_data.dart';
import '../models/partner_home_data.dart';
import 'api_provider.dart';
import 'user_type_provider.dart';

part 'home_provider.g.dart';

@riverpod
Future<HomeResponseState?> homeData(Ref ref) async {
  final userType = ref.watch(userTypeProvider);
  final api = ref.watch(apiProvider);
  final response = await api.get('/home');

  if (response.success && response.data != null) {
    if (response.data!['data'] != null) {
      final json = response.data!['data'] as Map<String, dynamic>;
      if (userType == UserType.partner) {
        return PartnerHomeState(PartnerHomeData.fromJson(json));
      } else {
        return CustomerHomeState(HomeData.fromJson(json));
      }
    }
    return null;
  } else {
    throw Exception(response.message ?? 'Failed to fetch home data');
  }
}
