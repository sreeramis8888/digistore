import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/permission_manager_service.dart';

enum LocationErrorReason {
  none,
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  general,
}

class MapLocationState {
  final LatLng center;
  final bool isFetching;
  final String address;
  final String localBody;
  final String errorMessage;
  final LocationErrorReason errorReason;

  const MapLocationState({
    required this.center,
    this.isFetching = false,
    this.address = '',
    this.localBody = '',
    this.errorMessage = '',
    this.errorReason = LocationErrorReason.none,
  });

  MapLocationState copyWith({
    LatLng? center,
    bool? isFetching,
    String? address,
    String? localBody,
    String? errorMessage,
    LocationErrorReason? errorReason,
  }) {
    return MapLocationState(
      center: center ?? this.center,
      isFetching: isFetching ?? this.isFetching,
      address: address ?? this.address,
      localBody: localBody ?? this.localBody,
      errorMessage: errorMessage ?? this.errorMessage,
      errorReason: errorReason ?? this.errorReason,
    );
  }
}

class MapLocationNotifier extends StateNotifier<MapLocationState> {
  final Ref ref;

  MapLocationNotifier(this.ref, {LatLng? initialCenter})
    : super(
        MapLocationState(
          center: initialCenter ?? const LatLng(10.8505, 76.2711),
        ),
      );

  Future<void> initLocation(LatLng? initialCenter, String? initialLocalBody) async {
    if (initialCenter != null) {
      await updateLocation(initialCenter);
    } else {
      await determineCurrentLocation();
    }
  }

  Future<void> determineCurrentLocation() async {
    state = state.copyWith(
      isFetching: true,
      errorMessage: '',
      errorReason: LocationErrorReason.none,
    );
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isFetching: false,
          errorReason: LocationErrorReason.serviceDisabled,
          errorMessage: 'Location services are disabled.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isFetching: false,
          errorReason: LocationErrorReason.permissionPermanentlyDenied,
          errorMessage: 'Location permission is permanently denied.',
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          isFetching: false,
          errorReason: LocationErrorReason.permissionDenied,
          errorMessage: 'Location permission was denied.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);
      await updateLocation(latLng);
    } catch (e) {
      state = state.copyWith(
        isFetching: false,
        errorReason: LocationErrorReason.general,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> updateLocation(LatLng location) async {
    state = state.copyWith(
      isFetching: true,
      center: location,
      errorMessage: '',
    );
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final localBody = p.locality ?? p.subLocality ?? '';
        final addressParts = [
          p.name,
          p.thoroughfare,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.postalCode,
        ].where((e) => e != null && e.isNotEmpty).toList();

        final address = addressParts.join(', ');

        state = state.copyWith(
          center: location,
          localBody: localBody,
          address: address,
          isFetching: false,
        );
      } else {
        state = state.copyWith(center: location, isFetching: false);
      }
    } catch (e) {
      state = state.copyWith(
        center: location,
        isFetching: false,
        errorMessage: 'Failed to get address for this location.',
      );
    }
  }

  Future<LatLng?> searchAddress(String query) async {
    if (query.trim().isEmpty) return null;
    state = state.copyWith(isFetching: true, errorMessage: '');
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);
        await updateLocation(latLng);
        return latLng;
      } else {
        state = state.copyWith(
          isFetching: false,
          errorMessage: 'Location not found.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isFetching: false,
        errorMessage: 'Location not found.',
      );
    }
    return null;
  }
}

final mapLocationProvider =
    StateNotifierProvider.autoDispose<MapLocationNotifier, MapLocationState>((
      ref,
    ) {
      return MapLocationNotifier(ref);
    });
