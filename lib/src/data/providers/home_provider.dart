import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/home_data.dart';
import '../models/partner_home_data.dart';
import 'api_provider.dart';
import 'user_provider.dart';
import 'user_type_provider.dart';

import 'auth_provider.dart';

part 'home_provider.g.dart';

@Riverpod(keepAlive: true)
Future<HomeResponseState?> homeData(Ref ref) async {
  // Watch session to ensure clean state on logout
  ref.watch(sessionProvider);
  
  final userType = ref.watch(userTypeProvider);
  final api = ref.watch(apiProvider);
  final user = ref.watch(userProvider);

  final lat = user?.location?.coordinates?.lat;
  final lng = user?.location?.coordinates?.lng;

  final Map<String, String>? queryParams = (lat != null && lng != null)
      ? {
          'lat': lat.toString(),
          'lng': lng.toString(),
        }
      : null;

  final response = await api.get('/home', queryParams: queryParams);

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
