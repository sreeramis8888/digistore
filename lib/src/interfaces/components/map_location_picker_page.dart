import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/providers/map_location_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/services/location_search_service.dart';
import 'confirmation_dialog.dart';
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
  ConsumerState<MapLocationPickerPage> createState() =>
      _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends ConsumerState<MapLocationPickerPage>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TextEditingController _localBodyController;

  Timer? _debounceTimer;
  List<LocationSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;

  bool _isInit = true;
  bool _isInitCenterSet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localBodyController = TextEditingController(
      text: widget.initialLocalBody ?? '',
    );
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialCenter =
          (widget.initialLat != null && widget.initialLng != null)
          ? LatLng(widget.initialLat!, widget.initialLng!)
          : null;
      ref
          .read(mapLocationProvider.notifier)
          .initLocation(initialCenter, widget.initialLocalBody);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _localBodyController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationOnResume();
    }
  }

  Future<void> _checkLocationOnResume() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    if (serviceEnabled &&
        (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always)) {
      await ref.read(mapLocationProvider.notifier).determineCurrentLocation();
      if (mounted) {
        final currentCenter = ref.read(mapLocationProvider).center;
        _mapController.move(currentCenter, 15.0);
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _debounceTimer?.cancel();

    if (query.length < 2) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
          _showSuggestions = false;
        });
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() {
        _isSearching = true;
        _showSuggestions = true;
      });

      try {
        final results = await ref
            .read(locationSearchServiceProvider)
            .searchLocations(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isSearching = false;
            _showSuggestions = true;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _suggestions = [];
      _isSearching = false;
      _showSuggestions = false;
    });
  }

  void _selectSuggestion(LocationSuggestion suggestion) {
    _debounceTimer?.cancel();
    _searchFocusNode.unfocus();
    setState(() {
      _showSuggestions = false;
      _searchController.text = suggestion.title;
    });

    final target = LatLng(suggestion.latitude, suggestion.longitude);
    _mapController.move(target, 16.0);
    ref.read(mapLocationProvider.notifier).updateLocation(target);

    if (suggestion.localBody != null && suggestion.localBody!.isNotEmpty) {
      _localBodyController.text = suggestion.localBody!;
    }
  }

  Future<void> _submitSearch(String query) async {
    _debounceTimer?.cancel();
    _searchFocusNode.unfocus();
    setState(() {
      _showSuggestions = false;
      _isSearching = true;
    });

    if (_suggestions.isNotEmpty) {
      _selectSuggestion(_suggestions.first);
      return;
    }

    final loc = await ref
        .read(mapLocationProvider.notifier)
        .searchAddress(query);
    if (loc != null && mounted) {
      _mapController.move(loc, 16.0);
    }
    if (mounted) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveStart) {
      if (_showSuggestions) {
        setState(() {
          _showSuggestions = false;
        });
      }
      FocusManager.instance.primaryFocus?.unfocus();
    }
    if (event is MapEventMoveEnd &&
        event.source != MapEventSource.mapController) {
      ref
          .read(mapLocationProvider.notifier)
          .updateLocation(_mapController.camera.center);
    }
  }

  Widget _buildSuffixIcon() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: kPrimaryColor,
          ),
        ),
      );
    }

    if (_searchController.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.close_rounded, color: kGrey, size: 20),
        onPressed: _clearSearch,
      );
    }

    return IconButton(
      icon: const Icon(
        Icons.arrow_forward_rounded,
        color: kGrey,
        size: 20,
      ),
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        _submitSearch(_searchController.text);
      },
    );
  }

  Widget _buildSuggestionsOverlay(BoxConstraints constraints) {
    if (!_showSuggestions ||
        (_suggestions.isEmpty &&
            !_isSearching &&
            _searchController.text.length < 2)) {
      return const SizedBox.shrink();
    }

    final maxOverlayHeight =
        (constraints.maxHeight - 24).clamp(140.0, 360.0);

    return Positioned(
      top: 8,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        color: kWhite,
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxOverlayHeight),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: _isSearching && _suggestions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Searching places...',
                        style: kSmallTitleL.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                )
              : _suggestions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_off_outlined,
                              size: 20,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'No locations found',
                                  style: kSmallTitleM.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: kBlack,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Try searching with city or area name',
                                  style: kSmallerTitleL.copyWith(
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF3F4F6),
                        indent: 52,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        return InkWell(
                          onTap: () => _selectSuggestion(item),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    size: 18,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.title,
                                        style: kBodyTitleM.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: kBlack,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (item.subtitle.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item.subtitle,
                                          style: kSmallTitleL.copyWith(
                                            fontSize: 12,
                                            color: const Color(0xFF6B7280),
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 16,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Future<void> _showPermissionPermanentlyDeniedDialog() async {
    await showConfirmationDialog(
      context: context,
      title: 'Location Permission Required',
      message:
          'Location access is permanently disabled for Setgo. Please enable location permission in app settings to detect your current location.',
      confirmText: 'Open Settings',
      cancelText: 'Not Now',
      icon: Icons.location_off_rounded,
      confirmColor: kPrimaryColor,
      onConfirm: () async {
        await openAppSettings();
      },
    );
  }

  Future<void> _showLocationServiceDisabledDialog() async {
    await showConfirmationDialog(
      context: context,
      title: 'Location Services Disabled',
      message:
          'Location service (GPS) is turned off on your device. Please turn on location services in device settings to detect your current location.',
      confirmText: 'Open Settings',
      cancelText: 'Not Now',
      icon: Icons.location_disabled_rounded,
      confirmColor: kPrimaryColor,
      onConfirm: () async {
        await Geolocator.openLocationSettings();
      },
    );
  }

  Widget _buildBottomDetails(MapLocationState mapState) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mapState.isFetching)
              const Center(
                child: LinearProgressIndicator(color: kPrimaryColor),
              ),
            const SizedBox(height: 8),
            Text(
              mapState.address.isNotEmpty
                  ? mapState.address
                  : 'Move map to select location',
              style: kBodyTitleR.copyWith(
                color: kTextColor,
                fontSize: 13,
              ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapLocationProvider);

    ref.listen(mapLocationProvider, (
      MapLocationState? prev,
      MapLocationState next,
    ) {
      if (_isInit) {
        _isInit = false;
        return;
      }

      if (!_isInitCenterSet &&
          widget.initialLat == null &&
          !next.isFetching &&
          prev?.isFetching == true) {
        _mapController.move(next.center, 15.0);
        _isInitCenterSet = true;
      }

      if (prev?.localBody != next.localBody && next.localBody.isNotEmpty) {
        _localBodyController.text = next.localBody;
      }

      if (next.errorReason == LocationErrorReason.permissionPermanentlyDenied &&
          prev?.errorReason != LocationErrorReason.permissionPermanentlyDenied) {
        _showPermissionPermanentlyDeniedDialog();
      } else if (next.errorReason == LocationErrorReason.serviceDisabled &&
          prev?.errorReason != LocationErrorReason.serviceDisabled) {
        _showLocationServiceDisabledDialog();
      } else if (prev?.errorMessage != next.errorMessage &&
          next.errorMessage.isNotEmpty &&
          next.errorReason == LocationErrorReason.general) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      }
    });

    return PopScope(
      canPop: !_showSuggestions,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_showSuggestions) {
          setState(() => _showSuggestions = false);
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: GestureDetector(
        onTap: () {
          if (_showSuggestions) {
            setState(() => _showSuggestions = false);
          }
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Pick Google Map Location',
              style: kSmallTitleM.copyWith(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: kBlack),
            elevation: 0,
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                color: Colors.white,
                child: PrimaryTextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hint: 'Search locations...',
                  prefixIcon: const Icon(Icons.search, color: kGrey),
                  suffixIcon: _buildSuffixIcon(),
                  onTap: () {
                    if (_suggestions.isNotEmpty ||
                        _searchController.text.trim().length >= 2) {
                      setState(() {
                        _showSuggestions = true;
                      });
                    }
                  },
                  onSubmitted: (val) => _submitSearch(val),
                ),
              ),

              // Map & Overlays
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter:
                                (widget.initialLat != null &&
                                    widget.initialLng != null)
                                ? LatLng(widget.initialLat!, widget.initialLng!)
                                : mapState.center,
                            initialZoom: 15.0,
                            onMapEvent: _onMapEvent,
                            onTap: (tapPosition, point) {
                              if (_showSuggestions) {
                                setState(() => _showSuggestions = false);
                              }
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.setgoinnovations',
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
                              color: mapState.isFetching
                                  ? Colors.grey
                                  : kPrimaryColor,
                            ),
                          ),
                        ),

                        // My Location FAB
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.my_location,
                              color: kPrimaryColor,
                            ),
                            onPressed: () async {
                              if (_showSuggestions) {
                                setState(() => _showSuggestions = false);
                              }
                              FocusManager.instance.primaryFocus?.unfocus();
                              await ref
                                  .read(mapLocationProvider.notifier)
                                  .determineCurrentLocation();
                              final mapLocState =
                                  ref.read(mapLocationProvider);
                              if (mapLocState.errorReason ==
                                  LocationErrorReason.none) {
                                _mapController.move(mapLocState.center, 15.0);
                              }
                            },
                          ),
                        ),

                        // Semi-transparent backdrop when suggestions are showing
                        if (_showSuggestions)
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() => _showSuggestions = false);
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: Container(
                                color: Colors.black.withOpacity(0.12),
                              ),
                            ),
                          ),

                        // Suggestions Overlay
                        _buildSuggestionsOverlay(constraints),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Details (smoothly collapses when suggestions are active)
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                child: _showSuggestions
                    ? const SizedBox.shrink()
                    : _buildBottomDetails(mapState),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
