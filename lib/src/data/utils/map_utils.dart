class MapUtils {
  static Map<String, dynamic> cleanMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is Map<String, dynamic>) {
        final cleanedMap = cleanMap(value);
        if (cleanedMap.isNotEmpty) {
          result[key] = cleanedMap;
        }
      } else if (value is List) {
        final cleanedList = value.where((item) => item != null).map((item) {
          if (item is Map<String, dynamic>) {
            return cleanMap(item);
          }
          return item;
        }).toList();
        result[key] = cleanedList;
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}
