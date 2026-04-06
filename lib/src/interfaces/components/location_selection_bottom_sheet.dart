import 'package:digistore/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/services/permission_manager_service.dart';
import 'primary_button.dart';
import 'primary_text_field.dart';

class LocationSelectionBottomSheet extends ConsumerStatefulWidget {
  final Function(String district, String localBody, double lat, double lng)
  onLocationSelected;
  final double? initialLat;
  final double? initialLng;
  final String? initialDistrict;
  final String? initialLocalBody;

  const LocationSelectionBottomSheet({
    super.key,
    required this.onLocationSelected,
    this.initialLat,
    this.initialLng,
    this.initialDistrict,
    this.initialLocalBody,
  });

  @override
  ConsumerState<LocationSelectionBottomSheet> createState() =>
      _LocationSelectionBottomSheetState();
}

class _LocationSelectionBottomSheetState
    extends ConsumerState<LocationSelectionBottomSheet> {
  bool _isFetching = false;
  String _errorMessage = '';

  late final TextEditingController _districtController;
  late final TextEditingController _localBodyController;

  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _districtController = TextEditingController(
      text: widget.initialDistrict ?? '',
    );
    _localBodyController = TextEditingController(
      text: widget.initialLocalBody ?? '',
    );
    _lat = widget.initialLat;
    _lng = widget.initialLng;
  }

  @override
  void dispose() {
    _districtController.dispose();
    _localBodyController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isFetching = true;
      _errorMessage = '';
    });

    try {
      final permissionManager = ref.read(permissionManagerServiceProvider);
      final isGranted = await permissionManager.requestLocationPermission();

      if (!isGranted)
        throw Exception(
          'Location permissions are required to capture geolocation.',
        );

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled)
        throw Exception('Location services are disabled on your device.');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _districtController.text =
              place.subAdministrativeArea ?? place.administrativeArea ?? '';
          _localBodyController.text = place.locality ?? place.subLocality ?? '';
        }
      } catch (_) {}

      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      setState(() => _isFetching = false);
    }
  }

  void _submit() {
    if (_districtController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'District is mandatory.');
      return;
    }

    if (_lat == null || _lng == null) {
      setState(
        () => _errorMessage =
            'Geolocation is mandatory. Please capture device coordinates.',
      );
      return;
    }

    widget.onLocationSelected(
      _districtController.text.trim(),
      _localBodyController.text.trim(),
      _lat!,
      _lng!,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text('Update Location', style: kHeadTitleM.copyWith(fontSize: 16)),

            const SizedBox(height: 4),

            Text(
              'Coordinates stay locked once captured.',
              style: kBodyTitleR.copyWith(
                fontSize: 12,
                color: kSecondaryTextColor,
              ),
            ),

            const SizedBox(height: 16),

            PrimaryTextField(
              label: 'District',
              hint: 'Enter district',
              controller: _districtController,
              isRequired: true,
            ),

            const SizedBox(height: 10),

            PrimaryTextField(
              label: 'Local Body',
              hint: 'Municipality / Panchayat',
              controller: _localBodyController,
            ),

            const SizedBox(height: 16),

            RichText(
              text: TextSpan(
                text: 'Geolocation',
                style: kSmallTitleM.copyWith(fontSize: 13, color: kTextColor),
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: kRed),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            InkWell(
              onTap: _isFetching ? null : _detectLocation,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: kField,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _lat != null ? kPrimaryColor : kRed,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _lat != null
                          ? Icons.gps_fixed_rounded
                          : Icons.gps_not_fixed_rounded,
                      size: 18,
                      color: _lat != null ? kPrimaryColor : kRed,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _lat != null
                                ? 'Location Captured'
                                : (_isFetching
                                      ? 'Detecting...'
                                      : 'Detect location'),
                            style: kBodyTitleM.copyWith(
                              fontSize: 13,
                              color: _lat != null ? kPrimaryColor : kRed,
                            ),
                          ),

                          if (_lat != null)
                            Text(
                              '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                              style: kSmallerTitleR.copyWith(
                                fontSize: 11,
                                color: kSecondaryTextColor,
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (_isFetching)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: LoadingAnimation(),
                      )
                    else if (_lat != null)
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: kPrimaryColor,
                      )
                    else
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: kRed,
                      ),
                  ],
                ),
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kRed.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: kRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: kSmallerTitleR.copyWith(
                          fontSize: 11,
                          color: kRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(text: 'Save', onPressed: _submit),
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
