import 'package:routing_client_dart/routing_client_dart.dart';

class RoutingService {
  static final RoutingService _instance = RoutingService._internal();
  factory RoutingService() => _instance;
  RoutingService._internal();

  final RoutingManager _routingManager = RoutingManager();

  Future<double?> calculateRoadDistance({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final waypoints = [
        LngLat(lng: fromLng, lat: fromLat),
        LngLat(lng: toLng, lat: toLat),
      ];

      final road = await _routingManager.getRoute(
        request: OSRMRequest.route(
          waypoints: waypoints,
          geometries: Geometries.polyline,
          steps: false,
          overview: Overview.simplified,
        ),
      );

      if (road.distance > 0) {
        return road.distance / 1000;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, double>?> calculateRoadDistanceAndDuration({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final waypoints = [
        LngLat(lng: fromLng, lat: fromLat),
        LngLat(lng: toLng, lat: toLat),
      ];

      final road = await _routingManager.getRoute(
        request: OSRMRequest.route(
          waypoints: waypoints,
          geometries: Geometries.polyline,
          steps: false,
          overview: Overview.simplified,
        ),
      );

      if (road.distance > 0 && road.duration > 0) {
        final distanceInKm = road.distance / 1000;
        final durationInMinutes = road.duration / 60;

        return {
          'distance': distanceInKm,
          'duration': durationInMinutes,
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Route?> getRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    try {
      final waypoints = [
        LngLat(lng: fromLng, lat: fromLat),
        LngLat(lng: toLng, lat: toLat),
      ];

      final road = await _routingManager.getRoute(
        request: OSRMRequest.route(
          waypoints: waypoints,
          geometries: Geometries.polyline,
          steps: true,
          overview: Overview.full,
        ),
      );

      return road;
    } catch (e) {
      return null;
    }
  }
}
