import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digistore/src/data/services/image_cache_service.dart';

final imageCacheServiceProvider = Provider<ImageCacheService>((ref) {
  return ImageCacheService();
});
