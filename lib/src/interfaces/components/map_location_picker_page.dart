import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/providers/map_location_provider.dart';
import 'primary_button.dart';
import 'primary_text_field.dart';

class MapLocationPickerPage extends ConsumerStatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialLocalBody;

  const MapLocationPickerPage({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialLocalBody,
  });

  @override
  ConsumerState<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends ConsumerState<MapLocationPickerPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  late TextEditingController _localBodyController;
  
  bool _isInit = true;
  bool _isInitCenterSet = false;

  @override
  void initState() {
    super.initState();
    _localBodyController = TextEditingController(text: widget.initialLocalBody ?? '');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialCenter = (widget.initialLat != null && widget.initialLng != null)
          ? LatLng(widget.initialLat!, widget.initialLng!)
          : null;
      ref.read(mapLocationProvider.notifier).initLocation(
          initialCenter, widget.initialLocalBody);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _localBodyController.dispose();
    super.dispose();
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd && event.source != MapEventSource.mapController) {
      ref.read(mapLocationProvider.notifier).updateLocation(_mapController.camera.center);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapLocationProvider);

    ref.listen(mapLocationProvider, (MapLocationState? prev, MapLocationState next) {
      if (_isInit) {
        _isInit = false;
        return;
      }

      if (!_isInitCenterSet && widget.initialLat == null && !next.isFetching && prev?.isFetching == true) {
         _mapController.move(next.center, 15.0);
         _isInitCenterSet = true;
      }

      if (prev?.localBody != next.localBody && next.localBody.isNotEmpty) {
        _localBodyController.text = next.localBody;
      }
      
      if (prev?.errorMessage != next.errorMessage && next.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
      appBar: AppBar(
        title: Text('Pick Google Map Location', style: kSmallTitleM.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kBlack),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.white,
            child: PrimaryTextField(
              controller: _searchController,
              hint: 'Search locations...',
              prefixIcon: const Icon(Icons.search, color: kGrey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final loc = await ref.read(mapLocationProvider.notifier).searchAddress(_searchController.text);
                  if (loc != null) {
                    _mapController.move(loc, 15.0);
                  }
                },
              ),
              onSubmitted: (val) async {
                  final loc = await ref.read(mapLocationProvider.notifier).searchAddress(val);
                  if (loc != null) {
                    _mapController.move(loc, 15.0);
                  }
              },
            ),
          ),
          
          // Map
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: mapState.center,
                    initialZoom: 15.0,
                    onMapEvent: _onMapEvent,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.setgo.digistore',
                    ),
                  ],
                ),
                // Draggable Pin overlay
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0), 
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: mapState.isFetching ? Colors.grey : kPrimaryColor,
                    ),
                  ),
                ),
                
                // My Location FAB
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: kPrimaryColor),
                    onPressed: () async {
                      await ref.read(mapLocationProvider.notifier).determineCurrentLocation();
                      final currentCenter = ref.read(mapLocationProvider).center;
                      _mapController.move(currentCenter, 15.0);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Details
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ]
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (mapState.isFetching)
                     const Center(child: LinearProgressIndicator(color: kPrimaryColor)),
                  const SizedBox(height: 8),
                  Text(
                    mapState.address.isNotEmpty ? mapState.address : 'Move map to select location',
                    style: kBodyTitleR.copyWith(color: kTextColor, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 12),
                  PrimaryTextField(
                    label: 'Local Body',
                    hint: 'Municipality / Panchayat',
                    controller: _localBodyController,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Confirm Location',
                    onPressed: () {
                      Navigator.of(context).pop({
                        'localBody': _localBodyController.text.trim(),
                        'lat': mapState.center.latitude,
                        'lng': mapState.center.longitude,
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      ),
    );
  }
}
