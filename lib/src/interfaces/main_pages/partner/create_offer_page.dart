import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/services/image_services.dart' as img_service;
import '../../../data/services/toast_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';

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
    _categoryController = TextEditingController(text: widget.offer?['category']);
    _discountValueController = TextEditingController(text: widget.offer?['discountValue']?.toString());
    _tagsController = TextEditingController(text: (widget.offer?['tags'] as List?)?.join(', '));
    _originalPriceController = TextEditingController(text: widget.offer?['originalPrice']?.toString());
    _offerPriceController = TextEditingController(text: widget.offer?['offerPrice']?.toString());
    
    if (widget.offer?['validFrom'] != null) {
      _validFrom = DateTime.tryParse(widget.offer!['validFrom']);
      if (_validFrom != null) {
        _validFromController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_validFrom!));
      } else {
        _validFromController = TextEditingController();
      }
    } else {
      _validFromController = TextEditingController();
    }

    if (widget.offer?['validTo'] != null) {
      _validTo = DateTime.tryParse(widget.offer!['validTo']);
      if (_validTo != null) {
        _validToController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_validTo!));
      } else {
        _validToController = TextEditingController();
      }
    } else {
      _validToController = TextEditingController();
    }

    _isActive = widget.offer?['isActive'] ?? true;
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
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await img_service.pickMedia(
      context: context,
      enableCrop: false,
      showDocument: false,
    );

    if (result is XFile) {
      setState(() {
        _pickedImages.add(File(result.path));
      });
    }
  }

  void _showCategoryPicker() async {
    final categoriesList = await ref.read(categoriesProvider.future);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Category',
                style: kSmallTitleM.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index) {
                    final cat = categoriesList[index];
                    return ListTile(
                      title: Text(cat.name ?? ''),
                      onTap: () {
                        setState(() {
                          _categoryController.text = cat.name ?? '';
                          _selectedCategoryId = cat.name; // Backend might expect name or ID, adjusting to name based on common patterns for category string
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isValidFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isValidFrom) {
          _validFrom = picked;
          _validFromController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _validTo = picked;
          _validToController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> _saveOffer() async {
    if (_titleController.text.trim().isEmpty) {
      ToastService().showToast(context, 'Title is required', type: ToastType.error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      final body = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'isActive': _isActive.toString(),
        'discountValue': _discountValueController.text.trim(),
        'originalPrice': _originalPriceController.text.trim(),
        'offerPrice': _offerPriceController.text.trim(),
        'category': _categoryController.text.trim(),
        'tags': _tagsController.text.trim(),
      };
      
      if (_selectedCategoryId != null) {
        body['category'] = _selectedCategoryId!;
      }
      
      if (_validFrom != null) body['validFrom'] = _validFrom!.toIso8601String();
      if (_validTo != null) body['validTo'] = _validTo!.toIso8601String();

      List<http.MultipartFile>? files;
      if (_pickedImages.isNotEmpty) {
        files = await Future.wait(_pickedImages.map((f) => http.MultipartFile.fromPath(
          'images',
          f.path,
          contentType: MediaType.parse(lookupMimeType(f.path) ?? 'image/jpeg'),
        )));
      }

      final response = await api.postMultipart('/offers', body, files: files);

      if (response.success && mounted) {
        ToastService().showToast(context, 'Offer created successfully');
        Navigator.pop(context);
      } else if (mounted) {
        ToastService().showToast(context, response.message ?? 'Failed to create offer', type: ToastType.error);
      }
    } catch (e) {
      if (mounted) ToastService().showToast(context, 'Error: $e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
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
                        hint: 'YYYY-MM-DD',
                        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
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
                        hint: 'YYYY-MM-DD',
                        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
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
                  'Is Active',
                  style: kSmallTitleM.copyWith(fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeColor: kPrimaryColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                      child: const Icon(Icons.add_a_photo_outlined, color: kSecondaryTextColor),
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
                            child: Image.file(_pickedImages[index], fit: BoxFit.cover),
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
                                child: const Icon(Icons.close, color: kWhite, size: 14),
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
    );
  }
}
