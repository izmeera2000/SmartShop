import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomImageCacheManager {
  static final BaseCacheManager instance = CacheManager(
    Config(
      'customImageCache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
    ),
  );
}
