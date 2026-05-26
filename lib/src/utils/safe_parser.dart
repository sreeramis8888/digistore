class SafeParser {
  static T? parseObject<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      try {
        return fromJson(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static List<T>? parseList<T>(
    dynamic jsonList,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (jsonList == null) return null;
    if (jsonList is List) {
      final List<T> result = [];
      for (var item in jsonList) {
        if (item is Map<String, dynamic>) {
          try {
            result.add(fromJson(item));
          } catch (e) {}
        }
      }
      return result;
    }
    return null;
  }
}
