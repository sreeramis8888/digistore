import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/image_services.dart' as img_service;
import '../../../data/services/toast_service.dart';
import '../../components/partner/category_selection_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/providers/offers_provider.dart';

class CreateOfferPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? offer;

  const CreateOfferPage({super.key, this.offer});

  @override
  ConsumerState<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends ConsumerState<CreateOfferPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;
  late TextEditingController _discountValueController;
  late TextEditingController _tagsController;
  late TextEditingController _originalPriceController;
  late TextEditingController _offerPriceController;
  late TextEditingController _validFromController;
  late TextEditingController _validToController;
  final List<TextEditingController> _termControllers = [];

  String? _selectedCategoryId;
  DateTime? _validFrom;
  DateTime? _validTo;

  List<File> _pickedImages = [];
  bool _isLoading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.offer?['title']);
    _descController = TextEditingController(text: widget.offer?['description']);
    _categoryController = TextEditingController(
      text: widget.offer?['category'],
    );
    _discountValueController = TextEditingController(
      text: widget.offer?['discountValue']?.toString(),
    );
    _tagsController = TextEditingController(
      text: (widget.offer?['tags'] as List?)?.join(', '),
    );
    _originalPriceController = TextEditingController(
      text: widget.offer?['originalPrice']?.toString(),
    );
    _offerPriceController = TextEditingController(
      text: widget.offer?['offerPrice']?.toString(),
    );

    if (widget.offer?['validFrom'] != null) {
      _validFrom = DateTime.tryParse(widget.offer!['validFrom'])?.toLocal();
      if (_validFrom != null) {
        _validFromController = TextEditingController(
          text: DateFormat('dd MMM, yyyy').format(_validFrom!),
        );
      } else {
        _validFromController = TextEditingController();
      }
    } else {
      _validFromController = TextEditingController();
    }

    if (widget.offer?['validTo'] != null) {
      _validTo = DateTime.tryParse(widget.offer!['validTo'])?.toLocal();
      if (_validTo != null) {
        _validToController = TextEditingController(
          text: DateFormat('dd MMM, yyyy').format(_validTo!),
        );
      } else {
        _validToController = TextEditingController();
      }
    } else {
      _validToController = TextEditingController();
    }

    _selectedCategoryId =
        widget.offer?['categoryId'] ?? widget.offer?['category'];
    _isActive = widget.offer?['isActive'] ?? true;

    if (widget.offer?['terms'] != null) {
      final terms = widget.offer!['terms'] as List;
      for (final term in terms) {
        _termControllers.add(TextEditingController(text: term.toString()));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _discountValueController.dispose();
    _originalPriceController.dispose();
    _offerPriceController.dispose();
    _validFromController.dispose();
    _validToController.dispose();
    for (final controller in _termControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_pickedImages.length >= 5) {
      ToastService().showToast(
        context,
        'Maximum 5 images allowed',
        type: ToastType.error,
      );
      return;
    }

    final result = await img_service.pickMedia(
      context: context,
      allowMultiple: true,
      enableCrop: false,
      showDocument: false,
    );

    if (result is List<XFile>) {
      setState(() {
        final remaining = 5 - _pickedImages.length;
        _pickedImages.addAll(result.take(remaining).map((e) => File(e.path)));
      });
    } else if (result is XFile) {
      setState(() {
        if (_pickedImages.length < 5) {
          _pickedImages.add(File(result.path));
        }
      });
    }
  }

  void _showCategoryPicker() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategorySelectionBottomSheet(
        selectedCategoryId: _selectedCategoryId,
        onCategorySelected: (cat) {
          setState(() {
            _categoryController.text = cat.name ?? '';
            _selectedCategoryId = cat.id;
          });
        },
      ),
    );
  }

  void _addTerm() {
    setState(() {
      _termControllers.add(TextEditingController());
    });
  }

  void _removeTerm(int index) {
    setState(() {
      _termControllers[index].dispose();
      _termControllers.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isValidFrom) async {
    FocusScope.of(context).unfocus();
    DateTime initialDate =
        (isValidFrom ? _validFrom : _validTo) ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isValidFrom ? 'Offer Start Date' : 'Offer End Date',
                    style: kSmallTitleB.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: kTextColor),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: kPrimaryColor,
                    onPrimary: kWhite,
                    onSurface: kTextColor,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: initialDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 0)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (date) {
                    setState(() {
                      if (isValidFrom) {
                        _validFrom = date;
                        _validFromController.text = DateFormat(
                          'dd MMM, yyyy',
                        ).format(date);
                      } else {
                        _validTo = date;
                        _validToController.text = DateFormat(
                          'dd MMM, yyyy',
                        ).format(date);
                      }
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                onPressed: () {
                  if (isValidFrom && _validFrom == null) {
                    setState(() {
                      _validFrom = initialDate;
                      _validFromController.text = DateFormat(
                        'dd MMM, yyyy',
                      ).format(initialDate);
                    });
                  } else if (!isValidFrom && _validTo == null) {
                    setState(() {
                      _validTo = initialDate;
                      _validToController.text = DateFormat(
                        'dd MMM, yyyy',
                      ).format(initialDate);
                    });
                  }
                  Navigator.pop(context);
                },
                text: 'Confirm Date',
                backgroundColor: kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOffer() async {
    if (_titleController.text.trim().isEmpty) {
      ToastService().showToast(
        context,
        'Title is required',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      final partner = ref.read(partnerProvider);

      if (partner == null ||
          partner.businessInfo?.storeLocation?.coordinates == null ||
          partner.businessInfo!.storeLocation!.coordinates!.isEmpty) {
        ToastService().showToast(
          context,
          'Shop location is required. Please set it in "My Account" profile.',
          type: ToastType.error,
        );
        setState(() => _isLoading = false);
        return;
      }

      final body = <String, String>{
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'isActive': _isActive.toString(),
        'discountValue': _discountValueController.text.trim(),
        'originalPrice': _originalPriceController.text.trim(),
        'offerPrice': _offerPriceController.text.trim(),
        'tags': _tagsController.text.trim(),
        'terms': json.encode(
          _termControllers
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
        ),
      };

      if (_selectedCategoryId != null) {
        body['category'] = _selectedCategoryId!;
      } else {
        body['category'] = _categoryController.text.trim();
      }

      if (partner?.businessInfo?.storeLocation != null) {
        final loc = partner!.businessInfo!.storeLocation!;
        if (loc.coordinates != null && loc.coordinates!.length == 2) {
          body['location'] = json.encode({
            'type': 'Point',
            'coordinates': loc.coordinates,
          });
        }
      }

      if (_validFrom != null) body['validFrom'] = _validFrom!.toIso8601String();
      if (_validTo != null) body['validTo'] = _validTo!.toIso8601String();

      List<http.MultipartFile>? files;
      if (_pickedImages.isNotEmpty) {
        files = await Future.wait(
          _pickedImages.map(
            (f) => http.MultipartFile.fromPath(
              'images',
              f.path,
              contentType: MediaType.parse(
                lookupMimeType(f.path) ?? 'image/jpeg',
              ),
            ),
          ),
        );
      }

      final response = await api.postMultipart('/offers', body, files: files);

      if (response.success && mounted) {
        final newOffer = OfferModel.fromJson(response.data!['data']);
        ref.read(offersProvider.notifier).addOffer(newOffer);
        ToastService().showToast(context, 'Offer created successfully');
        Navigator.pop(context);
      } else if (mounted) {
        ToastService().showToast(
          context,
          response.message ?? 'Failed to create offer',
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService().showToast(context, 'Error: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
          title: Text(
            widget.offer != null ? 'Edit offer' : 'Create an offer',
            style: kSmallTitleM,
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryTextField(
                controller: _titleController,
                label: 'Offer title',
                hint: 'Enter offer title',
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Enter offer description',
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showCategoryPicker,
                child: AbsorbPointer(
                  child: PrimaryTextField(
                    controller: _categoryController,
                    label: 'Category',
                    hint: 'Select offer category',
                    suffixIcon: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _originalPriceController,
                      label: 'Original Price',
                      hint: '₹ 0.00',
                      type: TextFieldType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryTextField(
                      controller: _offerPriceController,
                      label: 'Offer Price',
                      hint: '₹ 0.00',
                      type: TextFieldType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                controller: _discountValueController,
                label: 'Discount Value (%)',
                hint: 'e.g. 20',
                type: TextFieldType.number,
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                controller: _tagsController,
                label: 'Tags',
                hint: 'e.g. food, pizza, vegetarian (comma separated)',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: AbsorbPointer(
                        child: PrimaryTextField(
                          controller: _validFromController,
                          label: 'Valid From',
                          hint: 'DD MMM, YYYY',
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: AbsorbPointer(
                        child: PrimaryTextField(
                          controller: _validToController,
                          label: 'Valid To',
                          hint: 'DD MMM, YYYY',
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: kSmallTitleB.copyWith(fontSize: 14),
                  ),
                  TextButton.icon(
                    onPressed: _addTerm,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Term'),
                    style: TextButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_termControllers.isEmpty)
                Text(
                  'No terms added yet.',
                  style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
                ),
              ...List.generate(_termControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PrimaryTextField(
                          controller: _termControllers[index],
                          hint: 'Enter term (e.g. Valid on weekends only)',
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeTerm(index),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        padding: const EdgeInsets.only(top: 12),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              Text(
                'Offer Images',
                style: kSmallTitleM.copyWith(
                  color: const Color(0xFF0A0A0A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ...List.generate(_pickedImages.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.file(
                                _pickedImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _pickedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: kWhite,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              onPressed: _saveOffer,
              isLoading: _isLoading,
              text: 'Save',
              backgroundColor: kPrimaryColor,
              textColor: kWhite,
            ),
          ),
        ),
      ),
    );
  }
}
