import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/business_info.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/branches.dart';
import '../../../data/providers/partner_services_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/services/image_services.dart' as img_service;
import '../../../data/services/toast_service.dart';
import '../../components/advanced_network_image.dart';
import '../../components/partner/service_category_selection_bottom_sheet.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';

class CreateServicePage extends ConsumerStatefulWidget {
  final ServiceModel? existingService;

  const CreateServicePage({super.key, this.existingService});

  @override
  ConsumerState<CreateServicePage> createState() => _CreateServicePageState();
}

class _CreateServicePageState extends ConsumerState<CreateServicePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _offerValueController;
  late TextEditingController _durationController;
  late TextEditingController _bufferController;
  late TextEditingController _maxGuestsController;
  late TextEditingController _spaceLabelController;

  bool _hasOffer = false;
  String _offerType = 'percentage';
  final List<String> _selectedDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  File? _pickedImage;
  String? _existingImageUrl;
  bool _isImageRemoved = false;
  bool _isSubmitting = false;
  String? _selectedCategoryId;

  final List<String> _allDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  bool get _isModified {
    if (widget.existingService == null) return true;

    final s = widget.existingService!;
    if (_nameController.text.trim() != s.name) return true;
    final oldCatId = s.categoryId ?? (s.category != null && s.category!.length == 24 ? s.category : null);
    if (_selectedCategoryId != oldCatId && _categoryController.text.trim() != (s.categoryName ?? s.category ?? '')) return true;
    if (_descriptionController.text.trim() != (s.description ?? '')) return true;
    if (_priceController.text.trim() != (s.originalPrice > 0 ? s.originalPrice.toInt().toString() : '')) return true;
    if (_hasOffer != s.hasOffer) return true;
    if (_offerType != (s.offerType ?? 'percentage')) return true;
    if (_offerValueController.text.trim() != (s.offerValue?.toInt().toString() ?? '')) return true;
    if (_durationController.text.trim() != s.durationMinutes.toString()) return true;
    if (_bufferController.text.trim() != s.bufferMinutes.toString()) return true;
    if (_maxGuestsController.text.trim() != s.maxConcurrentGuests.toString()) return true;
    if (_spaceLabelController.text.trim() != s.spaceLabel) return true;
    if (_pickedImage != null || _isImageRemoved) return true;

    return false;
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final s = widget.existingService;
    _nameController = TextEditingController(text: s?.name ?? '');
    String initialCat = s?.categoryName ?? s?.category ?? '';
    _selectedCategoryId = s?.categoryId ?? (s?.category != null && s!.category!.length == 24 ? s.category : null);
    if (RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(initialCat)) {
      final cats = ref.read(serviceCategoriesProvider).value;
      final matched = cats?.where((c) => c.id == initialCat).firstOrNull;
      if (matched?.name != null && matched!.name!.isNotEmpty) {
        initialCat = matched.name!;
      }
    }
    _categoryController = TextEditingController(text: initialCat);
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _priceController = TextEditingController(
      text: s != null && s.originalPrice > 0 ? s.originalPrice.toInt().toString() : '',
    );
    _offerValueController = TextEditingController(
      text: s?.offerValue != null ? s!.offerValue!.toInt().toString() : '',
    );
    _durationController = TextEditingController(text: s?.durationMinutes.toString() ?? '30');
    _bufferController = TextEditingController(text: s?.bufferMinutes.toString() ?? '5');
    _maxGuestsController = TextEditingController(text: s?.maxConcurrentGuests.toString() ?? '1');
    _spaceLabelController = TextEditingController(text: s?.spaceLabel ?? 'Chairs');

    _hasOffer = s?.hasOffer ?? false;
    _offerType = s?.offerType ?? 'percentage';

    if (s != null && s.availableDays.isNotEmpty) {
      _selectedDays.clear();
      _selectedDays.addAll(s.availableDays.map((d) => d.toLowerCase()));
    }

    if (s != null && s.images.isNotEmpty) {
      _existingImageUrl = s.images.first;
    }

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
    super.dispose();
  }

  Future<void> _pickImage() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await img_service.pickMedia(
      context: context,
      enableCrop: true,
      cropRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      showDocument: false,
    );

    if (result is XFile) {
      File compressedFile = await img_service.compressImageIfNeeded(
        File(result.path),
      );
      setState(() {
        _pickedImage = compressedFile;
        _isImageRemoved = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ToastService().showToast(
        context,
        'Service name is required',
        type: ToastType.error,
      );
      return;
    }

    if (_categoryController.text.trim().isEmpty) {
      ToastService().showToast(
        context,
        'Please select a category',
        type: ToastType.error,
      );
      return;
    }

    final priceStr = _priceController.text.trim();
    if (priceStr.isEmpty || double.tryParse(priceStr) == null) {
      ToastService().showToast(
        context,
        'Please enter a valid price',
        type: ToastType.error,
      );
      return;
    }

    final price = double.tryParse(priceStr) ?? 0.0;
    final offerVal = double.tryParse(_offerValueController.text.trim());
    final duration = int.tryParse(_durationController.text.trim()) ?? 30;
    final buffer = int.tryParse(_bufferController.text.trim()) ?? 0;
    final maxGuests = int.tryParse(_maxGuestsController.text.trim()) ?? 1;

    setState(() => _isSubmitting = true);

    try {
      final Map<String, dynamic> payload = {
        'name': name,
        if (_categoryController.text.trim().isNotEmpty)
          'category': _categoryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': price,
        'originalPrice': price,
        'hasOffer': _hasOffer,
        if (_hasOffer) 'offerType': _offerType,
        if (_hasOffer && offerVal != null) 'offerValue': offerVal,
        'durationMinutes': duration,
        'bufferMinutes': buffer,
        'maxConcurrentGuests': maxGuests,
        'spaceLabel': _spaceLabelController.text.trim().isNotEmpty
            ? _spaceLabelController.text.trim()
            : 'Chairs',
        'availableDays': _selectedDays,
      };

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

      if (primaryBranch != null && primaryBranch.location != null) {
        final loc = primaryBranch.location!;
        if (loc.coordinates != null && loc.coordinates!.length == 2) {
          payload['location'] = json.encode({
            'type': 'Point',
            'coordinates': loc.coordinates,
          });
        }
      }

      List<http.MultipartFile>? files;
      if (_pickedImage != null) {
        files = [
          await http.MultipartFile.fromPath(
            'images',
            _pickedImage!.path,
            contentType: MediaType.parse(
              lookupMimeType(_pickedImage!.path) ?? 'image/jpeg',
            ),
          ),
        ];
      } else if (_existingImageUrl != null && !_isImageRemoved) {
        payload['images'] = [_existingImageUrl!];
      } else if (_isImageRemoved) {
        payload['images'] = [];
      }

      final notifier = ref.read(partnerServicesProvider.notifier);
      final isEditing = widget.existingService != null;
      final res = isEditing
          ? await notifier.updateService(widget.existingService!.id!, payload, files: files)
          : await notifier.createService(payload, files: files);

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
    } catch (e) {
      if (mounted) {
        ToastService().showToast(
          context,
          'Error: $e',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
            isEditing ? 'Edit service' : 'Create a service',
            style: kSmallTitleM,
          ),
          centerTitle: false,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name
                PrimaryTextField(
                  controller: _nameController,
                  label: 'Service Name',
                  hint: 'Enter service name',
                  isRequired: true,
                  maxLength: 50,
                  showCounter: true,
                ),
                const SizedBox(height: 20),

                // Category Picker
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

                // Description
                PrimaryTextField(
                  controller: _descriptionController,
                  label: 'Service Description',
                  hint: 'Describe what the service includes...',
                  maxLines: 4,
                  maxLength: 500,
                  showCounter: true,
                ),
                const SizedBox(height: 20),

                // Price
                PrimaryTextField(
                  controller: _priceController,
                  label: 'Standard Price (₹)',
                  hint: 'Enter service price',
                  type: TextFieldType.number,
                  isRequired: true,
                ),
                const SizedBox(height: 20),

                // Promotional Offer Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Apply Promotional Offer',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Enable special discounted pricing',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _hasOffer,
                            activeTrackColor: kPrimaryColor,
                            onChanged: (val) => setState(() => _hasOffer = val),
                          ),
                        ],
                      ),
                      if (_hasOffer) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Discount Type',
                                    style: kSmallTitleM.copyWith(
                                      color: const Color(0xFF0A0A0A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _offerType,
                                        isExpanded: true,
                                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF808080)),
                                        style: kSmallTitleL.copyWith(color: const Color(0xFF111827)),
                                        dropdownColor: kWhite,
                                        items: const [
                                          DropdownMenuItem(value: 'percentage', child: Text('Percent (%)')),
                                          DropdownMenuItem(value: 'flat', child: Text('Flat (₹)')),
                                        ],
                                        onChanged: (v) => setState(() => _offerType = v ?? 'percentage'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: PrimaryTextField(
                                controller: _offerValueController,
                                label: _offerType == 'percentage' ? 'Discount %' : 'Discount ₹',
                                hint: _offerType == 'percentage' ? 'e.g. 20' : 'e.g. 100',
                                type: TextFieldType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Timings & Capacity Header
                Text(
                  'Timings & Capacity',
                  style: kSmallTitleM.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Duration & Buffer Row
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

                // Concurrent Guests & Space Label Row
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

                // Available Days
                Text(
                  'Available Days',
                  style: kSmallTitleM.copyWith(
                    color: const Color(0xFF0A0A0A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allDays.map((day) {
                    final isSelected = _selectedDays.contains(day);
                    return ChoiceChip(
                      label: Text(
                        day.substring(0, 3).toUpperCase(),
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? kWhite : const Color(0xFF374151),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: kPrimaryColor,
                      backgroundColor: const Color(0xFFF5F5F5),
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSelected ? kPrimaryColor : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                const SizedBox(height: 24),

                // Service Image
                Text(
                  'Service Image',
                  style: kSmallTitleM.copyWith(
                    color: const Color(0xFF0A0A0A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: (_pickedImage != null ||
                            (_existingImageUrl != null && !_isImageRemoved))
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: _pickedImage != null
                                    ? Image.file(_pickedImage!, fit: BoxFit.cover)
                                    : AdvancedNetworkImage(
                                        imageUrl: _existingImageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _pickedImage = null;
                                      _existingImageUrl = null;
                                      _isImageRemoved = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: _pickImage,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Color(0xFF808080),
                                  size: 30,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Image',
                                  style: kSmallTitleL.copyWith(
                                    color: const Color(0xFF808080),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
}
