class SafeParser {
  static Map<String, dynamic>? asMap(dynamic json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return Map<String, dynamic>.from(json);
    return null;
  }

  static T? parseObject<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final map = asMap(json);
    if (map == null) return null;
    try {
      return fromJson(map);
    } catch (e) {
      // ignore: avoid_print
      print('Parse Object Error: $e');
      return null;
    }
  }

  static List<T>? parseList<T>(
    dynamic jsonList,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (jsonList == null) return null;
    if (jsonList is! List) return null;

    final List<T> result = [];
    for (final item in jsonList) {
      final map = asMap(item);
      if (map == null) continue;
      try {
        result.add(fromJson(map));
      } catch (e) {
        // ignore: avoid_print
        print('Parse Error: $e');
      }
    }
    return result;
  }

  /// First non-null value among [keys] on [map].
  static dynamic pick(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) return map[key];
    }
    return null;
  }
}
