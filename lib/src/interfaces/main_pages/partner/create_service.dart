import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/business_info.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/branches.dart';
import '../../../data/providers/partner_services_provider.dart';
import '../../../data/services/image_services.dart' as img_service;
import '../../../data/services/toast_service.dart';
import '../../components/advanced_network_image.dart';
import '../../components/partner/service_category_selection_bottom_sheet.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';

// ---------------------------------------------------------------------------
// Helper data classes
// ---------------------------------------------------------------------------

/// A single variant row (Portions & size variants).
class _ServiceVariantDraft {
  final TextEditingController name;
  final TextEditingController price;
  final TextEditingController offerPrice;

  _ServiceVariantDraft({
    String name = '',
    String price = '',
    String offerPrice = '',
  }) : name = TextEditingController(text: name),
       price = TextEditingController(text: price),
       offerPrice = TextEditingController(text: offerPrice);

  void dispose() {
    name.dispose();
    price.dispose();
    offerPrice.dispose();
  }
}

/// A single time-window within a day's schedule.
class _TimeWindow {
  String start; // "HH:mm"
  String end; // "HH:mm"
  _TimeWindow({this.start = '09:00', this.end = '18:00'});
  Map<String, dynamic> toJson() => {'startTime': start, 'endTime': end};
}

/// Per-day schedule used in daily mode.
class _DaySchedule {
  final String day; // e.g. 'monday'
  bool isOpen;
  List<_TimeWindow> windows;

  _DaySchedule({required this.day, this.isOpen = true, List<_TimeWindow>? windows})
    : windows = windows ?? [_TimeWindow()];
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CreateServicePage extends ConsumerStatefulWidget {
  final ServiceModel? existingService;

  const CreateServicePage({super.key, this.existingService});

  @override
  ConsumerState<CreateServicePage> createState() => _CreateServicePageState();
}

class _CreateServicePageState extends ConsumerState<CreateServicePage> {
  // Basic fields
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _offerValueController;
  late TextEditingController _durationController;
  late TextEditingController _bufferController;
  late TextEditingController _maxGuestsController;
  late TextEditingController _spaceLabelController;

  // Offer
  bool _hasOffer = false;
  String _offerType = 'percentage'; // 'percentage' | 'amount'

  // Booking type
  String _bookingType = 'appointment';

  // Variants
  bool _hasVariants = false;
  final List<_ServiceVariantDraft> _variants = [];

  // Custom hours
  bool _hasCustomHours = false;
  String _customHoursMode = 'same'; // 'same' | 'daily'
  String _sameStart = '09:00';
  String _sameEnd = '18:00';
  final List<String> _allDays = [
    'monday', 'tuesday', 'wednesday', 'thursday',
    'friday', 'saturday', 'sunday',
  ];
  late List<_DaySchedule> _daySchedules;
  // Simple available-days toggle (used when !_hasCustomHours)
  final List<String> _selectedDays = [
    'monday', 'tuesday', 'wednesday', 'thursday',
    'friday', 'saturday', 'sunday',
  ];

  // Images (up to 5)
  static const int _maxImages = 5;
  // ignore: prefer_final_fields – reassigned in setState via removeAt/add
  List<File> _pickedImages = [];
  List<String> _existingImageUrls = [];

  // Status
  bool _isActive = true;
  bool _isSubmitting = false;
  String? _selectedCategoryId;

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  static const List<Map<String, String>> _bookingTypes = [
    {'value': 'appointment', 'label': 'Appointment (Slot Booking)'},
    {'value': 'walk_in', 'label': 'Walk-in Only'},
    {'value': 'table_booking', 'label': 'Table / Seating Booking'},
  ];

  void _onFieldChanged() => setState(() {});

  bool _asBool(dynamic raw, {bool fallback = true}) {
    if (raw is bool) return raw;
    if (raw == null) return fallback;
    return raw.toString().toLowerCase() != 'false';
  }

  // -------------------------------------------------------------------------
  // _isModified
  // -------------------------------------------------------------------------

  bool get _isModified {
    final s = widget.existingService;
    if (s == null) return true;

    if (_nameController.text.trim() != s.name) return true;
    final oldCatId = s.categoryId ??
        (s.category != null && s.category!.length == 24 ? s.category : null);
    if (_selectedCategoryId != oldCatId &&
        _categoryController.text.trim() !=
            (s.categoryName ?? s.category ?? '')) { return true; }
    if (_descriptionController.text.trim() != (s.description ?? '')) { return true; }
    if (_priceController.text.trim() !=
        (s.originalPrice > 0 ? s.originalPrice.toStringAsFixed(0) : '')) { return true; }
    if (_hasOffer != s.hasOffer) return true;
    if (_offerType != (s.offerType == 'amount' ? 'amount' : 'percentage')) return true;
    if (_offerValueController.text.trim() !=
        (s.offerValue != null ? s.offerValue!.toStringAsFixed(0) : '')) {
      return true;
    }
    if (_durationController.text.trim() != s.durationMinutes.toString()) return true;
    if (_bufferController.text.trim() != s.bufferMinutes.toString()) return true;
    if (_maxGuestsController.text.trim() != s.maxConcurrentGuests.toString()) return true;
    if (_spaceLabelController.text.trim() != (s.spaceLabel)) return true;
    if (_bookingType != s.bookingType) return true;

    // Variants
    if (_hasVariants != s.hasVariants) return true;
    if (_hasVariants) {
      final origVars = s.variants;
      if (_variants.length != origVars.length) return true;
      for (int i = 0; i < _variants.length; i++) {
        final v = _variants[i];
        final o = origVars[i];
        if (v.name.text.trim() != (o['name']?.toString() ?? '')) return true;
        if (v.price.text.trim() != (o['price']?.toString() ?? '')) return true;
        if (v.offerPrice.text.trim() != (o['offerPrice']?.toString() ?? '')) return true;
      }
    }

    // Custom hours
    if (_hasCustomHours != s.hasCustomHours) return true;
    if (_hasCustomHours) {
      if (_customHoursMode == 'same') {
        if (_sameStart != (s.customStartTime ?? '09:00')) return true;
        if (_sameEnd != (s.customEndTime ?? '18:00')) return true;
      } else {
        final origSlots = s.dailyCustomSlots;
        if (_daySchedules.length != origSlots.length) return true;
        for (int i = 0; i < _daySchedules.length; i++) {
          final ds = _daySchedules[i];
          final os = origSlots.length > i ? origSlots[i] : null;
          if (os == null) return true;
          if (ds.isOpen != _asBool(os['isOpen'], fallback: false)) return true;
          final oWindows = os['timeWindows'];
          if (oWindows is! List || ds.windows.length != oWindows.length) return true;
          for (int j = 0; j < ds.windows.length; j++) {
            final ow = oWindows[j] is Map ? oWindows[j] as Map : {};
            if (ds.windows[j].start != (ow['startTime'] ?? '09:00')) return true;
            if (ds.windows[j].end != (ow['endTime'] ?? '18:00')) return true;
          }
        }
      }
    }

    // Available days (simple mode)
    if (!_hasCustomHours) {
      final sorted = List<String>.from(_selectedDays)..sort();
      final origSorted = List<String>.from(s.availableDays)..sort();
      if (sorted.join(',') != origSorted.join(',')) return true;
    }

    // isActive
    if (_isActive != s.isActive) return true;

    // Images
    if (_pickedImages.isNotEmpty) return true;
    final origUrls = s.images;
    if (_existingImageUrls.length != origUrls.length) return true;
    for (int i = 0; i < _existingImageUrls.length; i++) {
      if (_existingImageUrls[i] != origUrls[i]) return true;
    }

    return false;
  }

  // -------------------------------------------------------------------------
  // initState
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    final s = widget.existingService;

    // Basic controllers
    _nameController = TextEditingController(text: s?.name ?? '');
    String initialCat = s?.categoryName ?? s?.category ?? '';
    _selectedCategoryId = s?.categoryId ??
        (s?.category != null && s!.category!.length == 24 ? s.category : null);
    if (RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(initialCat) &&
        (s?.categoryName?.trim().isNotEmpty == true)) {
      initialCat = s!.categoryName!.trim();
    }
    _categoryController = TextEditingController(text: initialCat);
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _priceController = TextEditingController(
      text: s != null && s.originalPrice > 0
          ? s.originalPrice.toStringAsFixed(0)
          : '',
    );
    _offerValueController = TextEditingController(
      text: s?.offerValue != null ? s!.offerValue!.toStringAsFixed(0) : '',
    );
    _durationController = TextEditingController(
      text: s?.durationMinutes.toString() ?? '30',
    );
    _bufferController = TextEditingController(
      text: s?.bufferMinutes.toString() ?? '5',
    );
    _maxGuestsController = TextEditingController(
      text: s?.maxConcurrentGuests.toString() ?? '1',
    );
    _spaceLabelController = TextEditingController(
      text: s?.spaceLabel ?? 'Chairs',
    );

    // Offer
    _hasOffer = s?.hasOffer ?? false;
    _offerType = s?.offerType == 'amount' ? 'amount' : 'percentage';

    // Booking type
    _bookingType = s?.bookingType ?? 'appointment';

    // Active
    _isActive = s?.isActive ?? true;

    // Available days (simple)
    if (s != null && s.availableDays.isNotEmpty) {
      _selectedDays.clear();
      _selectedDays.addAll(s.availableDays.map((d) => d.toLowerCase()));
    }

    // Images
    _existingImageUrls = List<String>.from(s?.images ?? []);

    // Variants
    _hasVariants = s?.hasVariants ?? false;
    if (s?.variants.isNotEmpty == true) {
      for (final v in s!.variants) {
        _variants.add(_ServiceVariantDraft(
          name: v['name']?.toString() ?? '',
          price: v['price']?.toString() ?? '',
          offerPrice: v['offerPrice']?.toString() ?? '',
        ));
      }
    }

    // Custom hours
    _hasCustomHours = s?.hasCustomHours ?? false;
    _daySchedules = _allDays.map((day) {
      final existing = s?.dailyCustomSlots
          .cast<Map?>()
          .firstWhere((e) => e?['day'] == day, orElse: () => null);
      if (existing != null) {
        final isOpen = _asBool(existing['isOpen'], fallback: true);
        final rawWindows = existing['timeWindows'];
        List<_TimeWindow> windows = [];
        if (rawWindows is List && rawWindows.isNotEmpty) {
          for (final w in rawWindows) {
            if (w is Map) {
              windows.add(_TimeWindow(
                start: w['startTime']?.toString() ?? '09:00',
                end: w['endTime']?.toString() ?? '18:00',
              ));
            }
          }
        }
        if (windows.isEmpty) windows = [_TimeWindow()];
        return _DaySchedule(day: day, isOpen: isOpen, windows: windows);
      }
      final isOpen = _selectedDays.contains(day);
      return _DaySchedule(
        day: day,
        isOpen: isOpen,
        windows: [
          _TimeWindow(
            start: s?.customStartTime ?? '09:00',
            end: s?.customEndTime ?? '18:00',
          ),
        ],
      );
    }).toList();

    _sameStart = s?.customStartTime ?? '09:00';
    _sameEnd = s?.customEndTime ?? '18:00';
    // Infer mode: if dailyCustomSlots is populated → daily, else same
    _customHoursMode = (s?.dailyCustomSlots.isNotEmpty == true) ? 'daily' : 'same';

    // Listeners
    _nameController.addListener(_onFieldChanged);
    _categoryController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
    _offerValueController.addListener(_onFieldChanged);
    _durationController.addListener(_onFieldChanged);
    _bufferController.addListener(_onFieldChanged);
    _maxGuestsController.addListener(_onFieldChanged);
    _spaceLabelController.addListener(_onFieldChanged);
  }

  // -------------------------------------------------------------------------
  // dispose
  // -------------------------------------------------------------------------

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _categoryController.removeListener(_onFieldChanged);
    _descriptionController.removeListener(_onFieldChanged);
    _priceController.removeListener(_onFieldChanged);
    _offerValueController.removeListener(_onFieldChanged);
    _durationController.removeListener(_onFieldChanged);
    _bufferController.removeListener(_onFieldChanged);
    _maxGuestsController.removeListener(_onFieldChanged);
    _spaceLabelController.removeListener(_onFieldChanged);

    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _offerValueController.dispose();
    _durationController.dispose();
    _bufferController.dispose();
    _maxGuestsController.dispose();
    _spaceLabelController.dispose();

    for (final v in _variants) {
      v.dispose();
    }
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Category picker
  // -------------------------------------------------------------------------

  void _showCategoryPicker() {
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceCategorySelectionBottomSheet(
        selectedCategoryId: _selectedCategoryId,
        selectedCategory: _categoryController.text.trim(),
        onCategorySelected: (cat) {
          setState(() {
            _categoryController.text = cat.name ?? '';
            _selectedCategoryId = cat.id;
          });
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Image picking
  // -------------------------------------------------------------------------

  Future<void> _pickImages() async {
    final remaining =
        _maxImages - _existingImageUrls.length - _pickedImages.length;
    if (remaining <= 0) {
      if (!mounted) return;
      ToastService().showToast(
        context,
        'Maximum $_maxImages images allowed',
        type: ToastType.error,
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final result = await img_service.pickMedia(
      context: context,
      allowMultiple: remaining > 1,
      enableCrop: false,
      showDocument: false,
    );

    if (!mounted) return;

    if (result is List<XFile>) {
      final newFiles = result
          .map((f) => File(f.path))
          .take(remaining)
          .toList();
      for (int i = 0; i < newFiles.length; i++) {
        newFiles[i] = await img_service.compressImageIfNeeded(newFiles[i]);
      }
      if (mounted) setState(() => _pickedImages.addAll(newFiles));
    } else if (result is XFile && remaining > 0) {
      final compressed = await img_service.compressImageIfNeeded(
        File(result.path),
      );
      if (mounted) setState(() => _pickedImages.add(compressed));
    }
  }

  // -------------------------------------------------------------------------
  // Time picker helpers
  // -------------------------------------------------------------------------

  Future<String?> _pickTime(BuildContext ctx, String initial) async {
    final parts = initial.split(':');
    final init = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: ctx, initialTime: init);
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  // -------------------------------------------------------------------------
  // Submit
  // -------------------------------------------------------------------------

  Future<void> _handleSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ToastService().showToast(context, 'Service name is required',
          type: ToastType.error);
      return;
    }
    if (name.length < 3) {
      ToastService().showToast(context, 'Name must be at least 3 characters',
          type: ToastType.error);
      return;
    }

    if (_categoryController.text.trim().isEmpty) {
      ToastService().showToast(context, 'Please select a category',
          type: ToastType.error);
      return;
    }

    final priceStr = _priceController.text.trim();
    final price = double.tryParse(priceStr);
    if (priceStr.isEmpty || price == null || price < 0) {
      ToastService().showToast(context, 'Please enter a valid price (≥ 0)',
          type: ToastType.error);
      return;
    }

    if (_hasVariants) {
      for (final v in _variants) {
        if (v.name.text.trim().isEmpty) {
          ToastService().showToast(context, 'Each variant needs a name',
              type: ToastType.error);
          return;
        }
        final vp = double.tryParse(v.price.text.trim());
        if (vp == null || vp < 0) {
          ToastService().showToast(
              context, 'Variant price must be ≥ 0', type: ToastType.error);
          return;
        }
      }
    }

    if (_hasCustomHours && _customHoursMode == 'daily') {
      final hasOpen = _daySchedules.any((d) => d.isOpen);
      if (!hasOpen) {
        ToastService().showToast(
            context, 'Enable at least one day in custom schedule',
            type: ToastType.error);
        return;
      }
      for (final ds in _daySchedules.where((d) => d.isOpen)) {
        for (final w in ds.windows) {
          if (w.start.compareTo(w.end) >= 0) {
            ToastService().showToast(
                context,
                'Start time must be before end time on ${_capitalize(ds.day)}',
                type: ToastType.error);
            return;
          }
        }
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final offerVal = double.tryParse(_offerValueController.text.trim());
      final duration = int.tryParse(_durationController.text.trim()) ?? 30;
      final buffer = int.tryParse(_bufferController.text.trim()) ?? 0;
      final maxGuests = int.tryParse(_maxGuestsController.text.trim()) ?? 1;

      // Variants payload
      final validVariants = _hasVariants
          ? _variants.where((v) => v.name.text.trim().isNotEmpty).map((v) {
              final op = v.offerPrice.text.trim();
              return {
                'name': v.name.text.trim(),
                'price': double.tryParse(v.price.text.trim()) ?? 0.0,
                if (op.isNotEmpty) 'offerPrice': double.tryParse(op),
              };
            }).toList()
          : <Map<String, dynamic>>[];

      // Available days
      List<String> availableDays;
      List<Map<String, dynamic>> dailyCustomSlots = [];

      if (_hasCustomHours && _customHoursMode == 'daily') {
        availableDays =
            _daySchedules.where((d) => d.isOpen).map((d) => d.day).toList();
        dailyCustomSlots = _daySchedules
            .map((ds) => {
                  'day': ds.day,
                  'isOpen': ds.isOpen,
                  'timeWindows':
                      ds.windows.map((w) => w.toJson()).toList(),
                })
            .toList();
      } else if (_hasCustomHours && _customHoursMode == 'same') {
        availableDays = List<String>.from(_selectedDays);
        dailyCustomSlots = [];
      } else {
        availableDays = List<String>.from(_selectedDays);
      }

      final payload = <String, dynamic>{
        'name': name,
        if (_categoryController.text.trim().isNotEmpty)
          'category': _categoryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'originalPrice': price,
        'hasOffer': _hasOffer,
        if (_hasOffer) 'offerType': _offerType,
        if (_hasOffer && offerVal != null) 'offerValue': offerVal,
        'bookingType': _bookingType,
        'durationMinutes': duration,
        'bufferMinutes': buffer,
        'maxConcurrentGuests': maxGuests,
        'spaceLabel': _spaceLabelController.text.trim().isNotEmpty
            ? _spaceLabelController.text.trim()
            : 'Chairs',
        'availableDays': availableDays,
        'hasCustomHours': _hasCustomHours,
        if (_hasCustomHours && _customHoursMode == 'same') ...{
          'customStartTime': _sameStart,
          'customEndTime': _sameEnd,
        },
        if (_hasCustomHours && _customHoursMode == 'daily')
          'dailyCustomSlots': jsonEncode(dailyCustomSlots),
        'hasVariants': _hasVariants,
        'variants': jsonEncode(validVariants),
        'isActive': _isActive,
      };

      // Location from primary branch
      final branches = ref.read(branchesProvider);
      BusinessBranch? primaryBranch;
      for (final b in branches) {
        if (b.isPrimary == true) {
          primaryBranch = b;
          break;
        }
      }
      if (primaryBranch == null && branches.isNotEmpty) {
        primaryBranch = branches.first;
      }
      if (primaryBranch?.location?.coordinates?.length == 2) {
        payload['location'] = jsonEncode({
          'type': 'Point',
          'coordinates': primaryBranch!.location!.coordinates,
        });
      }

      // Images
      List<http.MultipartFile> files = [];
      for (int i = 0; i < _pickedImages.length; i++) {
        files.add(await http.MultipartFile.fromPath(
          'images',
          _pickedImages[i].path,
          contentType: MediaType.parse(
            lookupMimeType(_pickedImages[i].path) ?? 'image/jpeg',
          ),
        ));
      }

      // Edit: send existing URLs that weren't removed
      if (widget.existingService != null) {
        payload['images'] = jsonEncode(_existingImageUrls);
        payload['existingImages'] = jsonEncode(_existingImageUrls);
      } else if (_existingImageUrls.isNotEmpty) {
        payload['images'] = jsonEncode(_existingImageUrls);
      }

      log('service payload: $payload');

      final notifier = ref.read(partnerServicesProvider.notifier);
      final isEditing = widget.existingService != null;
      final res = isEditing
          ? await notifier.updateService(
              widget.existingService!.id!,
              payload,
              files: files.isEmpty ? null : files,
            )
          : await notifier.createService(
              payload,
              files: files.isEmpty ? null : files,
            );

      if (mounted) {
        if (res.success) {
          ToastService().showToast(
            context,
            isEditing
                ? 'Service updated successfully'
                : 'Service created successfully',
          );
          Navigator.pop(context);
        } else {
          ToastService().showToast(
            context,
            res.message ?? 'Failed to save service',
            type: ToastType.error,
          );
        }
      }
    } catch (e, st) {
      log('createService error: $e', stackTrace: st);
      if (mounted) {
        ToastService().showToast(context, 'Error: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // -------------------------------------------------------------------------
  // UI helpers
  // -------------------------------------------------------------------------

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _sectionCard({required Widget child, Color? borderColor, Color? bg}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg ?? const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }

  Widget _imageTile({
    required Widget child,
    required VoidCallback onRemove,
    bool isThumb = false,
  }) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(10)),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
        if (isThumb)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: const Text(
                'Thumbnail',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 9),
              ),
            ),
          ),
      ],
    );
  }

  Widget _timeButton(
    BuildContext ctx,
    String label,
    String value,
    void Function(String) onPicked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: kSmallTitleL.copyWith(
                fontSize: 11, color: const Color(0xFF6B7280))),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final t = await _pickTime(ctx, value);
            if (t != null) setState(() => onPicked(t));
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(value,
                    style: kSmallTitleM.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingService != null;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: kWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: kBlack, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Text(
            isEditing ? 'Edit Service' : 'Create a Service',
            style: kSmallTitleM,
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Images ──────────────────────────────────────────────────
              Text('Images',
                  style: kSmallTitleM.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                'Add up to $_maxImages images. First image is thumbnail.',
                style: kSmallTitleL.copyWith(
                    color: const Color(0xFF808080), fontSize: 11),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined,
                              color: Color(0xFF808080), size: 24),
                          const SizedBox(height: 4),
                          Text(
                            '${_existingImageUrls.length + _pickedImages.length}/$_maxImages',
                            style: kSmallTitleL.copyWith(
                                color: const Color(0xFF808080),
                                fontSize: 10,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...List.generate(_existingImageUrls.length, (i) {
                    return _imageTile(
                      child: AdvancedNetworkImage(
                        imageUrl: _existingImageUrls[i],
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                      onRemove: () =>
                          setState(() => _existingImageUrls.removeAt(i)),
                      isThumb: i == 0,
                    );
                  }),
                  ...List.generate(_pickedImages.length, (i) {
                    return _imageTile(
                      child: Image.file(_pickedImages[i],
                          fit: BoxFit.cover, width: 100, height: 100),
                      onRemove: () =>
                          setState(() => _pickedImages.removeAt(i)),
                      isThumb: _existingImageUrls.isEmpty && i == 0,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),

              // ── Service Name ────────────────────────────────────────────
              PrimaryTextField(
                controller: _nameController,
                label: 'Service Name',
                hint: 'e.g. Haircut & Styling',
                isRequired: true,
                maxLength: 100,
                showCounter: true,
              ),
              const SizedBox(height: 20),

              // ── Category ────────────────────────────────────────────────
              GestureDetector(
                onTap: _showCategoryPicker,
                child: AbsorbPointer(
                  child: PrimaryTextField(
                    controller: _categoryController,
                    label: 'Category',
                    hint: 'Select service category',
                    isRequired: true,
                    suffixIcon: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Description ─────────────────────────────────────────────
              PrimaryTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe what the service includes...',
                maxLines: 4,
                maxLength: 1000,
                showCounter: true,
              ),
              const SizedBox(height: 20),

              // ── Price ───────────────────────────────────────────────────
              PrimaryTextField(
                controller: _priceController,
                label: 'Base Price (₹)',
                hint: '₹ 0.00',
                type: TextFieldType.number,
                isRequired: true,
              ),
              const SizedBox(height: 20),

              // ── Booking Type ─────────────────────────────────────────────
              Text('Booking Type',
                  style: kSmallTitleM.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _bookingType,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF808080)),
                    style:
                        kSmallTitleL.copyWith(color: const Color(0xFF111827)),
                    dropdownColor: kWhite,
                    items: _bookingTypes
                        .map((t) => DropdownMenuItem<String>(
                              value: t['value'],
                              child: Text(t['label']!),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _bookingType = v ?? 'appointment'),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Promotional Offer ────────────────────────────────────────
              _sectionCard(
                borderColor: const Color(0xFFA7F3D0),
                bg: const Color(0xFFECFDF5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_offer_outlined,
                            color: Color(0xFF059669), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Special Offer / Discount',
                              style: kSmallTitleM.copyWith(
                                  fontWeight: FontWeight.w600)),
                        ),
                        CupertinoSwitch(
                          value: _hasOffer,
                          activeTrackColor: kPrimaryColor,
                          onChanged: (v) => setState(() => _hasOffer = v),
                        ),
                      ],
                    ),
                    if (_hasOffer) ...[
                      const SizedBox(height: 14),
                      const Divider(color: Color(0xFFA7F3D0), height: 1),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _offerChip(
                              label: '% Percent Off',
                              selected: _offerType == 'percentage',
                              onTap: () =>
                                  setState(() => _offerType = 'percentage'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _offerChip(
                              label: '₹ Flat Off',
                              selected: _offerType == 'amount',
                              onTap: () =>
                                  setState(() => _offerType = 'amount'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PrimaryTextField(
                        controller: _offerValueController,
                        label: _offerType == 'amount'
                            ? 'Flat Discount (₹)'
                            : 'Discount Percentage (%)',
                        hint: _offerType == 'amount' ? 'e.g. 100' : 'e.g. 20',
                        type: TextFieldType.number,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Portions & Size Variants ─────────────────────────────────
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.layers_outlined,
                            size: 18, color: kPrimaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Portions & Size Variants',
                                  style: kSmallTitleM.copyWith(
                                      fontWeight: FontWeight.w600)),
                              Text(
                                'Different sizes or options with custom prices',
                                style: kSmallTitleL.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF808080)),
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: _hasVariants,
                          activeTrackColor: kPrimaryColor,
                          onChanged: (v) {
                            setState(() {
                              _hasVariants = v;
                              if (v && _variants.isEmpty) {
                                _variants.add(_ServiceVariantDraft(
                                  price: _priceController.text.trim(),
                                ));
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (_hasVariants) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => _variants.add(
                                  _ServiceVariantDraft(
                                      price: _priceController.text.trim()),
                                ));
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Variant'),
                          style: TextButton.styleFrom(
                              foregroundColor: kPrimaryColor),
                        ),
                      ),
                      ...List.generate(_variants.length, (i) {
                        final v = _variants[i];
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Variant #${i + 1}',
                                      style: kSmallTitleM.copyWith(
                                          fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        v.dispose();
                                        _variants.removeAt(i);
                                      });
                                    },
                                    icon: const Icon(Icons.delete_outline,
                                        size: 20,
                                        color: Color(0xFF9CA3AF)),
                                  ),
                                ],
                              ),
                              PrimaryTextField(
                                controller: v.name,
                                label: 'Variant Name',
                                hint: 'e.g. Regular, Large, 60 min',
                                isRequired: true,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: PrimaryTextField(
                                      controller: v.price,
                                      label: 'Price (₹)',
                                      hint: '₹',
                                      isRequired: true,
                                      type: TextFieldType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: PrimaryTextField(
                                      controller: v.offerPrice,
                                      label: 'Offer Price (₹)',
                                      hint: 'Optional',
                                      type: TextFieldType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Timings & Capacity ───────────────────────────────────────
              Text('Timings & Capacity',
                  style: kSmallTitleM.copyWith(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _durationController,
                      label: 'Duration (mins)',
                      hint: '30',
                      type: TextFieldType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryTextField(
                      controller: _bufferController,
                      label: 'Buffer (mins)',
                      hint: '5',
                      type: TextFieldType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _maxGuestsController,
                      label: 'Capacity',
                      hint: '1',
                      type: TextFieldType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryTextField(
                      controller: _spaceLabelController,
                      label: 'Space Label',
                      hint: 'e.g. Chairs, Rooms',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Custom Hours ─────────────────────────────────────────────
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule_outlined,
                            size: 18, color: kPrimaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Custom Hours',
                                  style: kSmallTitleM.copyWith(
                                      fontWeight: FontWeight.w600)),
                              Text('Override default partner schedule',
                                  style: kSmallTitleL.copyWith(
                                      fontSize: 11,
                                      color: const Color(0xFF808080))),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: _hasCustomHours,
                          activeTrackColor: kPrimaryColor,
                          onChanged: (v) =>
                              setState(() => _hasCustomHours = v),
                        ),
                      ],
                    ),
                    if (_hasCustomHours) ...[
                      const SizedBox(height: 14),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      const SizedBox(height: 12),
                      // Mode toggle
                      Row(
                        children: [
                          Expanded(
                            child: _modeChip(
                              label: 'Same every day',
                              selected: _customHoursMode == 'same',
                              onTap: () =>
                                  setState(() => _customHoursMode = 'same'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _modeChip(
                              label: 'Per-day schedule',
                              selected: _customHoursMode == 'daily',
                              onTap: () =>
                                  setState(() => _customHoursMode = 'daily'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (_customHoursMode == 'same') ...[
                        Row(
                          children: [
                            Expanded(
                              child: _timeButton(
                                  context, 'Start Time', _sameStart,
                                  (t) => _sameStart = t),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _timeButton(
                                  context, 'End Time', _sameEnd,
                                  (t) => _sameEnd = t),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Daily mode
                        ..._daySchedules.map((ds) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      child: CupertinoSwitch(
                                        value: ds.isOpen,
                                        activeTrackColor: kPrimaryColor,
                                        onChanged: (v) =>
                                            setState(() => ds.isOpen = v),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(_capitalize(ds.day),
                                        style: kSmallTitleM.copyWith(
                                            fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    if (ds.isOpen)
                                      TextButton.icon(
                                        onPressed: () {
                                          // Copy this day's first window to all open days
                                          if (ds.windows.isEmpty) return;
                                          final src = ds.windows.first;
                                          setState(() {
                                            for (final other
                                                in _daySchedules) {
                                              if (other.isOpen &&
                                                  other.day != ds.day) {
                                                other.windows = [
                                                  _TimeWindow(
                                                      start: src.start,
                                                      end: src.end),
                                                ];
                                              }
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.copy, size: 14),
                                        label: const Text('Copy to all'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: kPrimaryColor,
                                          textStyle:
                                              const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                  ],
                                ),
                                if (ds.isOpen)
                                  ...List.generate(ds.windows.length, (wi) {
                                    final w = ds.windows[wi];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(top: 8, left: 40),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _timeButton(
                                              context,
                                              'Start',
                                              w.start,
                                              (t) => w.start = t,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _timeButton(
                                              context,
                                              'End',
                                              w.end,
                                              (t) => w.end = t,
                                            ),
                                          ),
                                          if (ds.windows.length > 1)
                                            IconButton(
                                              onPressed: () {
                                                setState(() =>
                                                    ds.windows.removeAt(wi));
                                              },
                                              icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  size: 18,
                                                  color: Color(0xFF9CA3AF)),
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                                if (ds.isOpen)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, left: 40),
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() => ds.windows.add(
                                            _TimeWindow(
                                                start: '14:00',
                                                end: '18:00')));
                                      },
                                      icon: const Icon(Icons.add, size: 14),
                                      label: const Text('Add shift'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: kPrimaryColor,
                                        textStyle:
                                            const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Available Days (simple — shown only when !_hasCustomHours) ─
              if (!_hasCustomHours) ...[
                Text('Available Days',
                    style: kSmallTitleM.copyWith(
                        color: const Color(0xFF0A0A0A),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allDays.map((day) {
                    final isSel = _selectedDays.contains(day);
                    return ChoiceChip(
                      label: Text(
                        day.substring(0, 3).toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSel ? kWhite : const Color(0xFF374151),
                        ),
                      ),
                      selected: isSel,
                      selectedColor: kPrimaryColor,
                      backgroundColor: const Color(0xFFF5F5F5),
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSel ? kPrimaryColor : const Color(0xFFE5E7EB),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedDays.add(day);
                          } else if (_selectedDays.length > 1) {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // ── Available for Booking (isActive) ─────────────────────────
              _sectionCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available for Booking',
                            style: kSmallTitleM.copyWith(
                                fontWeight: FontWeight.w600)),
                        Text('Customers can book this service',
                            style: kSmallTitleL.copyWith(
                                fontSize: 11,
                                color: const Color(0xFF808080))),
                      ],
                    ),
                    CupertinoSwitch(
                      value: _isActive,
                      activeTrackColor: kPrimaryColor,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              onPressed: _isModified ? _handleSubmit : () {},
              isLoading: _isSubmitting,
              text: isEditing ? 'Update Service' : 'Save Service',
              backgroundColor: _isModified ? kPrimaryColor : Colors.grey,
              textColor: kWhite,
            ),
          ),
        ),
      ),
    );
  }

  // ─── small UI helpers ────────────────────────────────────────────────────

  Widget _offerChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : kWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? kPrimaryColor : const Color(0xFFE5E7EB),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: kSmallTitleL.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? kWhite : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _modeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor.withValues(alpha: 0.1) : kWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? kPrimaryColor : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: kSmallTitleL.copyWith(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color:
                selected ? kPrimaryColor : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
