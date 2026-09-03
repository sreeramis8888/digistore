import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class LocationSuggestion {
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
  final String? localBody;

  const LocationSuggestion({
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    this.localBody,
  });
}

class LocationSearchService {
  final http.Client _client;

  LocationSearchService({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<LocationSuggestion>> searchLocations(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    // 1. Primary: OpenStreetMap Nominatim
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(cleanQuery)}&format=json&addressdetails=1&limit=6',
      );
      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': 'SetgoApp/1.0 (com.setgoinnovations.digistore)',
          'Accept-Language': 'en',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final results = <LocationSuggestion>[];
          for (final item in data) {
            final lat = double.tryParse(item['lat']?.toString() ?? '');
            final lon = double.tryParse(item['lon']?.toString() ?? '');
            if (lat == null || lon == null) continue;

            final displayName = (item['display_name'] as String?) ?? '';
            final parts =
                displayName.split(',').map((p) => p.trim()).toList();
            final name = (item['name'] as String?)?.trim();
            final title = (name != null && name.isNotEmpty)
                ? name
                : (parts.isNotEmpty ? parts.first : cleanQuery);

            final subtitleParts = parts.length > 1
                ? parts.where((p) => p != title).toList()
                : parts;
            final subtitle = subtitleParts.isNotEmpty
                ? subtitleParts.join(', ')
                : displayName;

            final address = item['address'] as Map<String, dynamic>?;
            final localBody = address?['suburb'] ??
                address?['city'] ??
                address?['town'] ??
                address?['municipality'] ??
                address?['village'] ??
                address?['county'];

            results.add(
              LocationSuggestion(
                title: title,
                subtitle: subtitle,
                latitude: lat,
                longitude: lon,
                localBody: localBody?.toString(),
              ),
            );
          }
          if (results.isNotEmpty) return results;
        }
      }
    } catch (_) {
      // Fall through to Photon
    }

    // 2. Fallback: Photon API (Fast OSM geocoder)
    try {
      final uri = Uri.parse(
        'https://photon.komoot.io/api/?q=${Uri.encodeComponent(cleanQuery)}&limit=6',
      );
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];
        if (features.isNotEmpty) {
          final results = <LocationSuggestion>[];
          for (final f in features) {
            final geom = f['geometry'];
            final coords = geom?['coordinates'] as List<dynamic>?;
            if (coords == null || coords.length < 2) continue;

            final double lon = (coords[0] as num).toDouble();
            final double lat = (coords[1] as num).toDouble();
            final props = f['properties'] as Map<String, dynamic>? ?? {};

            final name = (props['name'] as String?)?.trim();
            final street = (props['street'] as String?)?.trim();
            final district = (props['district'] as String?)?.trim();
            final city = (props['city'] as String?)?.trim();
            final state = (props['state'] as String?)?.trim();
            final country = (props['country'] as String?)?.trim();

            final title = (name != null && name.isNotEmpty)
                ? name
                : (street != null && street.isNotEmpty)
                    ? street
                    : (city != null && city.isNotEmpty)
                        ? city
                        : cleanQuery;

            final subtitleParts = [
              if (street != null && street.isNotEmpty && street != title)
                street,
              if (district != null && district.isNotEmpty && district != title)
                district,
              if (city != null && city.isNotEmpty && city != title) city,
              if (state != null && state.isNotEmpty) state,
              if (country != null && country.isNotEmpty) country,
            ];
            final subtitle = subtitleParts.isNotEmpty
                ? subtitleParts.join(', ')
                : (city ?? state ?? country ?? '');

            results.add(
              LocationSuggestion(
                title: title,
                subtitle: subtitle,
                latitude: lat,
                longitude: lon,
                localBody: district ?? city ?? state,
              ),
            );
          }
          if (results.isNotEmpty) return results;
        }
      }
    } catch (_) {
      // Fall through to native geocoding
    }

    // 3. Fallback: Native device geocoding
    try {
      final locations = await locationFromAddress(cleanQuery);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return [
          LocationSuggestion(
            title: cleanQuery,
            subtitle:
                '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
            latitude: loc.latitude,
            longitude: loc.longitude,
          ),
        ];
      }
    } catch (_) {}

    return [];
  }
}

final locationSearchServiceProvider = Provider<LocationSearchService>((ref) {
  return LocationSearchService();
});
