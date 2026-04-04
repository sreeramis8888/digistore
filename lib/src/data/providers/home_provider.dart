import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/home_data.dart';
import 'api_provider.dart';

part 'home_provider.g.dart';

@riverpod
Future<HomeData?> homeData(Ref ref) async {
  final api = ref.watch(apiProvider);
  final response = await api.get('/home');

  if (response.success && response.data != null) {
    if (response.data!['data'] != null) {
      return HomeData.fromJson(response.data!['data'] as Map<String, dynamic>);
    }
    return null;
  } else {
    throw Exception(response.message ?? 'Failed to fetch home data');
  }
}
