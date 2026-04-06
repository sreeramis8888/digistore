import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/category_model.dart';
import 'api_provider.dart';

part 'category_provider.g.dart';

@riverpod
Future<List<CategoryModel>> categories(Ref ref) async {
  final api = ref.watch(publicApiProvider);
  final response = await api.get('/categories', requireAuth: true);

  if (response.success && response.data != null) {
    final List<dynamic> data = response.data!['data'] as List<dynamic>;
    return data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  } else {
    throw Exception(response.message ?? 'Failed to fetch categories');
  }
}
