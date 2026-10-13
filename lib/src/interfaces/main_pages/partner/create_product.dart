import 'dart:developer';

import 'package:flutter/cupertino.dart';
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
import '../../../data/models/product_model.dart';
import '../../../data/providers/partner_products_provider.dart';
import '../../../data/providers/branches.dart';
import '../../../data/models/business_info.dart';

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

  List<String> _existingImageUrls = [];
  List<File> _pickedImages = [];
  bool _isLoading = false;
  bool _isActive = true;
  bool _inStock = true;

  static const int _maxImages = 5;

  List<String> get _initialImageUrls {
    final imgs = widget.product?['images'];
    if (imgs is! List) return const [];
    return imgs
        .map((e) => e?.toString().trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  bool get _isModified {
    if (widget.product == null) return true;

    if (_nameController.text.trim() !=
        (widget.product?['title'] ?? widget.product?['name'] ?? ''))
      return true;
    if (_descController.text.trim() != (widget.product?['description'] ?? ''))
      return true;
    if (_priceController.text.trim() !=
        (widget.product?['price']?.toString() ?? ''))
      return true;

    final oldCategoryId = widget.product?['category'] is Map
        ? widget.product?['category']?['_id']
        : widget.product?['category'];
    if (_selectedCategoryId != oldCategoryId) return true;

    final oldTags =
        (widget.product?['tags'] as List?)?.map((e) => e.toString()).toList() ??
        [];
    if (_tags.length != oldTags.length) return true;
    for (int i = 0; i < _tags.length; i++) {
      if (_tags[i] != oldTags[i]) return true;
    }

    if (_pickedImages.isNotEmpty) return true;
    final initialUrls = _initialImageUrls;
    if (_existingImageUrls.length != initialUrls.length) return true;
    for (int i = 0; i < _existingImageUrls.length; i++) {
      if (_existingImageUrls[i] != initialUrls[i]) return true;
    }

    final origActive = widget.product?['isActive'];
    final origActiveVal = origActive is bool
        ? origActive
        : (origActive?.toString().toLowerCase() == 'true');
    if (_isActive != origActiveVal) return true;

    final origStock = widget.product?['inStock'];
    final origStockVal = origStock is bool
        ? origStock
        : (origStock == null
              ? true
              : origStock.toString().toLowerCase() == 'true');
    if (_inStock != origStockVal) return true;

    return false;
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.product?['title'] ?? widget.product?['name'] ?? '',
    );
    _descController = TextEditingController(
      text: widget.product?['description'] ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?['price']?.toString() ?? '',
    );

    final cat = widget.product?['category'];
    _categoryController = TextEditingController(
      text: cat is Map ? cat['category'] : '',
    );

    _nameController.addListener(_onFieldChanged);
    _descController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
    _tagsController = TextEditingController();
    final initialTags = widget.product?['tags'];
    if (initialTags is List) {
      _tags = initialTags.map((e) => e.toString()).toList();
    }
    _selectedCategoryId = widget.product?['category']?['_id'];
    final rawActive = widget.product?['isActive'];
    _isActive = rawActive is bool
        ? rawActive
        : (rawActive?.toString().toLowerCase() != 'false');
    final rawStock = widget.product?['inStock'];
    _inStock = rawStock is bool
        ? rawStock
        : (rawStock == null
              ? true
              : rawStock.toString().toLowerCase() != 'false');
    _existingImageUrls = List<String>.from(_initialImageUrls);
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

  Future<void> _pickImages() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final totalCount = _existingImageUrls.length + _pickedImages.length;
    if (totalCount >= _maxImages) {
      ToastService().showToast(
        context,
        'Maximum limit of $_maxImages images reached',
        type: ToastType.warning,
      );
      return;
    }

    final result = await img_service.pickMedia(
      context: context,
      allowMultiple: true,
      enableCrop: true,
      cropRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      showDocument: false,
    );

    final remaining =
        _maxImages - (_existingImageUrls.length + _pickedImages.length);

    if (result is List<XFile>) {
      if (result.length > remaining) {
        ToastService().showToast(
          context,
          'Only $remaining more image(s) can be added',
          type: ToastType.warning,
        );
      }

      final newFiles = result.take(remaining).map((e) => File(e.path)).toList();
      for (int i = 0; i < newFiles.length; i++) {
        newFiles[i] = await img_service.compressImageIfNeeded(newFiles[i]);
      }
      setState(() {
        _pickedImages.addAll(newFiles);
      });
    } else if (result is XFile && remaining > 0) {
      final compressedFile = await img_service.compressImageIfNeeded(
        File(result.path),
      );
      setState(() {
        _pickedImages.add(compressedFile);
      });
    }
  }

  void _showCategoryPicker() {
    FocusManager.instance.primaryFocus?.unfocus();
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
    final title = _nameController.text.trim();
    if (title.isEmpty) {
      ToastService().showToast(
        context,
        'Product name is required',
        type: ToastType.error,
      );
      return;
    }

    if (title.length > 50) {
      ToastService().showToast(
        context,
        'Product name cannot exceed 50 characters',
        type: ToastType.error,
      );
      return;
    }

    if (_descController.text.trim().length > 500) {
      ToastService().showToast(
        context,
        'Product description cannot exceed 500 characters',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);

      final rawBody = <String, dynamic>{
        'title': title,
        'description': _descController.text.trim(),
        'price': _priceController.text.trim(),
        'tags': _tags.isNotEmpty ? jsonEncode(_tags) : null,
        'isActive': _isActive.toString(),
        'inStock': _inStock.toString(),
      };

      if (_selectedCategoryId != null) {
        rawBody['category'] = _selectedCategoryId!;
      }

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
          rawBody['location'] = json.encode({
            'type': 'Point',
            'coordinates': loc.coordinates,
          });
        }
      }

      final isEdit = widget.product != null;
      if (isEdit) {
        // Always send remaining existing URLs so multi-image edit keeps them.
        rawBody['images'] = jsonEncode(_existingImageUrls);
        rawBody['existingImages'] = jsonEncode(_existingImageUrls);
      } else if (_existingImageUrls.isNotEmpty) {
        rawBody['images'] = jsonEncode(_existingImageUrls);
      }

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

      final cleanedBody = cleanMap(rawBody);
      final body = cleanedBody.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      log('body: $body');

      final response = isEdit
          ? await api.putMultipart(
              '/products/${widget.product!['_id'] ?? widget.product!['id']}',
              body,
              files: files,
            )
          : await api.postMultipart('/products', body, files: files);

      if (response.success && mounted) {
        final newProduct = ProductModel.fromJson(response.data!['data']);
        if (isEdit) {
          ref
              .read(partnerProductsProvider.notifier)
              .updateProductLocally(newProduct);
        } else {
          ref.read(partnerProductsProvider.notifier).addProduct(newProduct);
        }
        ToastService().showToast(
          context,
          'Product ${isEdit ? 'updated' : 'created'} successfully',
        );
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
                maxLength: 50,
                showCounter: true,
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                controller: _descController,
                label: 'Product Description',
                hint: 'Enter product description',
                maxLines: 4,
                maxLength: 500,
                showCounter: true,
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
              const Divider(color: Color(0xFFF3F4F6), height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Status',
                    style: kSmallTitleM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: kBlack,
                    ),
                  ),
                  CupertinoSwitch(
                    value: _isActive,
                    onChanged: (val) {
                      setState(() {
                        _isActive = val;
                      });
                    },
                    activeTrackColor: kPrimaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'In Stock',
                    style: kSmallTitleM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: kBlack,
                    ),
                  ),
                  CupertinoSwitch(
                    value: _inStock,
                    onChanged: (val) {
                      setState(() {
                        _inStock = val;
                      });
                    },
                    activeTrackColor: kPrimaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF3F4F6), height: 1),
              const SizedBox(height: 20),
              Text(
                'Product Images',
                style: kSmallTitleM.copyWith(
                  color: const Color(0xFF0A0A0A),
                  fontWeight: FontWeight.w500,
                ),
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
                          const Icon(
                            Icons.add_a_photo_outlined,
                            color: Color(0xFF808080),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_existingImageUrls.length + _pickedImages.length}/$_maxImages',
                            style: kSmallTitleL.copyWith(
                              color: const Color(0xFF808080),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...List.generate(_existingImageUrls.length, (index) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AdvancedNetworkImage(
                            imageUrl: _existingImageUrls[index],
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _existingImageUrls.removeAt(index);
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
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  ...List.generate(_pickedImages.length, (index) {
                    return Stack(
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
                            width: 100,
                            height: 100,
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
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
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
