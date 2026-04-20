import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../components/advanced_network_image.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/image_services.dart' as img_service;
import '../../../data/services/toast_service.dart';
import '../../../data/utils/remove_nulls.dart';
import '../../components/partner/category_selection_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/partner_products_provider.dart';

class CreateProductPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? product;

  const CreateProductPage({super.key, this.product});

  @override
  ConsumerState<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends ConsumerState<CreateProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _tagsController;
  List<String> _tags = [];
  String? _selectedCategoryId;

  File? _pickedImage;
  bool _isLoading = false;
  bool _isActive = true;

  bool get _isModified {
    if (widget.product == null) return true;

    if (_nameController.text.trim() != (widget.product?['title'] ?? widget.product?['name'] ?? '')) return true;
    if (_descController.text.trim() != (widget.product?['description'] ?? '')) return true;
    if (_priceController.text.trim() != (widget.product?['price']?.toString() ?? '')) return true;
    
    final oldCategoryId = widget.product?['category'] is Map ? widget.product?['category']?['_id'] : widget.product?['category'];
    if (_selectedCategoryId != oldCategoryId) return true;

    final oldTags = (widget.product?['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
    if (_tags.length != oldTags.length) return true;
    for (int i = 0; i < _tags.length; i++) {
       if (_tags[i] != oldTags[i]) return true;
    }

    if (_pickedImage != null) return true;
    
    if (_isActive != (widget.product?['isActive'] ?? true)) return true;

    return false;
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?['title'] ?? widget.product?['name'] ?? '');
    _descController = TextEditingController(text: widget.product?['description'] ?? '');
    _priceController = TextEditingController(text: widget.product?['price']?.toString() ?? '');
    
    final cat = widget.product?['category'];
    _categoryController = TextEditingController(text: cat is Map ? cat['category'] : '');

    _nameController.addListener(_onFieldChanged);
    _descController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
    _tagsController = TextEditingController();
    final initialTags = widget.product?['tags'];
    if (initialTags is List) {
      _tags = initialTags.map((e) => e.toString()).toList();
    }
    _selectedCategoryId = widget.product?['category']?['_id'];
    _isActive = widget.product?['isActive'] ?? true;
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _descController.removeListener(_onFieldChanged);
    _priceController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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

  Future<void> _saveProduct() async {
    if (_nameController.text.trim().isEmpty) {
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

      final rawBody = <String, dynamic>{
        'title': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': _priceController.text.trim(),
        'tags': _tags.isNotEmpty ? jsonEncode(_tags) : null,
        'isActive': _isActive.toString(),
      };
      
      if (_selectedCategoryId != null) {
        rawBody['category'] = _selectedCategoryId!;
      }

      if (partner?.businessInfo?.storeLocation != null) {
        final loc = partner!.businessInfo!.storeLocation!;
        if (loc.coordinates != null && loc.coordinates!.length == 2) {
          rawBody['location'] = json.encode({
            'type': 'Point',
            'coordinates': loc.coordinates,
          });
        }
      }

      final cleanedBody = cleanMap(rawBody);
      final body = cleanedBody.map((key, value) => MapEntry(key, value.toString()));
      log('body: $body');

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
      }

      final isEdit = widget.product != null;
      final response = isEdit
          ? await api.putMultipart('/products/${widget.product!['_id'] ?? widget.product!['id']}', body, files: files)
          : await api.postMultipart('/products', body, files: files);

      if (response.success && mounted) {
        final newProduct = ProductModel.fromJson(response.data!['data']);
        if (isEdit) {
          ref.read(partnerProductsProvider.notifier).updateProductLocally(newProduct);
        } else {
          ref.read(partnerProductsProvider.notifier).addProduct(newProduct);
        }
        ToastService().showToast(context, 'Product ${isEdit ? 'updated' : 'created'} successfully');
        if (isEdit) {
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
      } else if (mounted) {
        ToastService().showToast(
          context,
          response.message ?? 'Failed to create product',
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
            widget.product != null ? 'Edit product' : 'Create a product',
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
                controller: _nameController,
                label: 'Product name',
                hint: 'Enter product name',
                isRequired: true,
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                controller: _descController,
                label: 'Product Description',
                hint: 'Enter product description',
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                controller: _priceController,
                label: 'Product Price',
                hint: 'Enter product price',
                type: TextFieldType.number,
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryTextField(
                    controller: _tagsController,
                    label: 'Tags',
                    hint: 'Type a tag and press space',
                    onChanged: (val) {
                      if (val.endsWith(' ')) {
                        final newTag = val.trim();
                        if (newTag.isNotEmpty && !_tags.contains(newTag)) {
                          setState(() {
                            _tags.add(newTag);
                          });
                        }
                        _tagsController.clear();
                      }
                    },
                    onSubmitted: (val) {
                      final newTag = val.trim();
                      if (newTag.isNotEmpty && !_tags.contains(newTag)) {
                        setState(() {
                          _tags.add(newTag);
                        });
                      }
                      _tagsController.clear();
                    },
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(color: kWhite),
                          ),
                          backgroundColor: kPrimaryColor,
                          deleteIconColor: kWhite,
                          onDeleted: () {
                            setState(() {
                              _tags.remove(tag);
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.transparent),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showCategoryPicker,
                child: AbsorbPointer(
                  child: PrimaryTextField(
                    controller: _categoryController,
                    label: 'Category',
                    hint: 'Select product category',
                    suffixIcon: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Text(
                'Product Image',
                style: kSmallTitleM.copyWith(
                  color: const Color(0xFF0A0A0A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _pickedImage != null
                        ? Image.file(_pickedImage!, fit: BoxFit.cover)
                        : (widget.product != null &&
                                widget.product!['images'] != null &&
                                (widget.product!['images'] as List).isNotEmpty)
                            ? AdvancedNetworkImage(
                                imageUrl: (widget.product!['images'] as List)[0],
                                fit: BoxFit.cover,
                              )
                            : Column(
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
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              onPressed: _isModified ? _saveProduct : () {},
              isLoading: _isLoading,
              text: widget.product != null ? 'Update' : 'Save',
              backgroundColor: _isModified ? kPrimaryColor : Colors.grey,
              textColor: kWhite,
            ),
          ),
        ),
      ),
    );
  }
}
