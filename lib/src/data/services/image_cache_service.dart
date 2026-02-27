import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  late CacheManager _cacheManager;

  factory ImageCacheService() {
    return _instance;
  }

  ImageCacheService._internal() {
    _cacheManager = CacheManager(
      Config(
        'app_image_cache',
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 200,
        fileService: HttpFileService(),
      ),
    );
  }

  CacheManager get cacheManager => _cacheManager;

  /// Pre-cache an image URL
  Future<void> precacheImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    try {
      await _cacheManager.getSingleFile(imageUrl);
    } catch (e) {
      print('Error pre-caching image: $e');
    }
  }

  /// Pre-cache multiple images
  Future<void> precacheImages(List<String> imageUrls) async {
    final validUrls = imageUrls.where((url) => url.isNotEmpty).toList();
    for (final url in validUrls) {
      await precacheImage(url);
    }
  }

  /// Get cached image file
  Future<void> getCachedImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    try {
      await _cacheManager.getSingleFile(imageUrl);
    } catch (e) {
      print('Error getting cached image: $e');
    }
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final files = await _cacheManager.getFileFromCache('');
      return files?.file.lengthSync() ?? 0;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }
}
