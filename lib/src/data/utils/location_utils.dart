import 'dart:math' as math;
import '../services/routing_service.dart';

class LocationUtils {
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final c = math.cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  static Future<double> calculateRoadDistance({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final routingService = RoutingService();
    
    final roadDistance = await routingService.calculateRoadDistance(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );

    if (roadDistance == null) {
      return calculateDistance(fromLat, fromLng, toLat, toLng);
    }

    return roadDistance;
  }

  static Future<Map<String, double>?> calculateRoadDistanceAndDuration({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final routingService = RoutingService();
    
    return await routingService.calculateRoadDistanceAndDuration(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
    );
  }
}
