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

class _SpecDraft {
  final TextEditingController key;
  final TextEditingController value;

  _SpecDraft({String key = '', String value = ''})
    : key = TextEditingController(text: key),
      value = TextEditingController(text: value);

  void dispose() {
    key.dispose();
    value.dispose();
  }
}

class _VariantDraft {
  final TextEditingController name;
  final TextEditingController sku;
  final TextEditingController price;
  final TextEditingController offerPrice;
  bool inStock;

  _VariantDraft({
    String name = '',
    String sku = '',
    String price = '',
    String offerPrice = '',
    this.inStock = true,
  }) : name = TextEditingController(text: name),
       sku = TextEditingController(text: sku),
       price = TextEditingController(text: price),
       offerPrice = TextEditingController(text: offerPrice);

  void dispose() {
    name.dispose();
    sku.dispose();
    price.dispose();
    offerPrice.dispose();
  }
}

class CreateProductPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? product;

  const CreateProductPage({super.key, this.product});

  @override
  ConsumerState<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends ConsumerState<CreateProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _skuController;
  late TextEditingController _unitController;
  late TextEditingController _weightController;
  late TextEditingController _categoryController;
  late TextEditingController _tagsController;
  late TextEditingController _offerValueController;
  late TextEditingController _offerPriceController;

  List<String> _tags = [];
  String? _selectedCategoryId;

  List<String> _existingImageUrls = [];
  List<File> _pickedImages = [];
  bool _isLoading = false;
  bool _isActive = true;
  bool _inStock = true;

  bool _hasOffer = false;
  String _offerType = 'percentage'; // percentage | amount (admin/API)

  bool _hasVariants = false;
  final List<_SpecDraft> _specs = [];
  final List<_VariantDraft> _variants = [];

  static const int _maxImages = 5;

  List<String> get _initialImageUrls {
    final imgs = widget.product?['images'];
    if (imgs is! List) return const [];
    return imgs
        .map((e) => e?.toString().trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  bool _asBool(dynamic raw, {bool fallback = true}) {
    if (raw is bool) return raw;
    if (raw == null) return fallback;
    return raw.toString().toLowerCase() != 'false';
  }

  void _recomputeOfferPrice() {
    final p = double.tryParse(_priceController.text.trim()) ?? 0;
    final v = double.tryParse(_offerValueController.text.trim()) ?? 0;
    if (!_hasOffer || p <= 0) return;
    final computed = _offerType == 'amount'
        ? (p - v).clamp(0, double.infinity)
        : (p * (1 - v / 100)).clamp(0, double.infinity);
    _offerPriceController.text = computed.round().toString();
  }

  bool get _isModified {
    if (widget.product == null) return true;

    if (_nameController.text.trim() !=
        (widget.product?['title'] ?? widget.product?['name'] ?? '')) {
      return true;
    }
    if (_descController.text.trim() != (widget.product?['description'] ?? '')) {
      return true;
    }
    if (_brandController.text.trim() !=
        (widget.product?['brand']?.toString() ?? '')) {
      return true;
    }
    if (_priceController.text.trim() !=
        (widget.product?['price']?.toString() ?? '')) {
      return true;
    }
    if (_skuController.text.trim() !=
        (widget.product?['sku']?.toString() ?? '')) {
      return true;
    }
    if (_unitController.text.trim() !=
        (widget.product?['unit']?.toString().isNotEmpty == true
            ? widget.product!['unit'].toString()
            : 'piece')) {
      return true;
    }
    if (_weightController.text.trim() !=
        (widget.product?['weight']?.toString() ?? '')) {
      return true;
    }

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

    if (_isActive != _asBool(widget.product?['isActive'])) return true;
    if (_inStock != _asBool(widget.product?['inStock'])) return true;

    if (_hasOffer != _asBool(widget.product?['hasOffer'], fallback: false)) {
      return true;
    }
    if (_hasOffer) {
      if (_offerType !=
          (widget.product?['offerType']?.toString() ?? 'percentage')) {
        return true;
      }
      if (_offerValueController.text.trim() !=
          (widget.product?['offerValue']?.toString() ?? '0')) {
        return true;
      }
      if (_offerPriceController.text.trim() !=
          (widget.product?['offerPrice']?.toString() ?? '')) {
        return true;
      }
    }

    final origHasVariants = _asBool(
      widget.product?['hasVariants'],
      fallback: false,
    );
    if (_hasVariants != origHasVariants) return true;

    final origSpecs = widget.product?['specifications'];
    final origSpecLen = origSpecs is List ? origSpecs.length : 0;
    if (_specs.length != origSpecLen) return true;
    if (origSpecs is List) {
      for (int i = 0; i < _specs.length && i < origSpecs.length; i++) {
        final s = origSpecs[i];
        if (s is! Map) return true;
        if (_specs[i].key.text.trim() != (s['key']?.toString() ?? '')) {
          return true;
        }
        if (_specs[i].value.text.trim() != (s['value']?.toString() ?? '')) {
          return true;
        }
      }
    }

    final origVariants = widget.product?['variants'];
    final origVarLen = origVariants is List ? origVariants.length : 0;
    if (_variants.length != origVarLen) return true;
    if (origVariants is List) {
      for (int i = 0; i < _variants.length && i < origVariants.length; i++) {
        final v = origVariants[i];
        if (v is! Map) return true;
        if (_variants[i].name.text.trim() != (v['name']?.toString() ?? '')) {
          return true;
        }
        if (_variants[i].sku.text.trim() != (v['sku']?.toString() ?? '')) {
          return true;
        }
        if (_variants[i].price.text.trim() != (v['price']?.toString() ?? '')) {
          return true;
        }
        if (_variants[i].offerPrice.text.trim() !=
            (v['offerPrice']?.toString() ?? '')) {
          return true;
        }
        if (_variants[i].inStock != _asBool(v['inStock'])) return true;
      }
    }

    return false;
  }

  void _onFieldChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(
      text: p?['title'] ?? p?['name'] ?? '',
    );
    _descController = TextEditingController(text: p?['description'] ?? '');
    _brandController = TextEditingController(text: p?['brand']?.toString() ?? '');
    _priceController = TextEditingController(text: p?['price']?.toString() ?? '');
    _skuController = TextEditingController(text: p?['sku']?.toString() ?? '');
    _unitController = TextEditingController(
      text: p?['unit']?.toString() ?? 'piece',
    );
    _weightController = TextEditingController(
      text: p?['weight']?.toString() ?? '',
    );
    _offerValueController = TextEditingController(
      text: p?['offerValue']?.toString() ?? '0',
    );
    _offerPriceController = TextEditingController(
      text: p?['offerPrice']?.toString() ?? '',
    );

    final cat = p?['category'];
    _categoryController = TextEditingController(
      text: cat is Map ? cat['category'] : '',
    );

    _nameController.addListener(_onFieldChanged);
    _descController.addListener(_onFieldChanged);
    _brandController.addListener(_onFieldChanged);
    _priceController.addListener(() {
      _recomputeOfferPrice();
      _onFieldChanged();
    });
    _skuController.addListener(_onFieldChanged);
    _unitController.addListener(_onFieldChanged);
    _weightController.addListener(_onFieldChanged);
    _offerValueController.addListener(() {
      _recomputeOfferPrice();
      _onFieldChanged();
    });
    _offerPriceController.addListener(_onFieldChanged);
    _tagsController = TextEditingController();

    final initialTags = p?['tags'];
    if (initialTags is List) {
      _tags = initialTags.map((e) => e.toString()).toList();
    }
    _selectedCategoryId = p?['category'] is Map
        ? p?['category']?['_id']
        : p?['category']?.toString();

    _isActive = _asBool(p?['isActive']);
    _inStock = _asBool(p?['inStock']);
    _hasOffer = _asBool(p?['hasOffer'], fallback: false);
    _offerType = p?['offerType']?.toString() == 'amount'
        ? 'amount'
        : 'percentage';
    _hasVariants = _asBool(p?['hasVariants'], fallback: false);

    final specs = p?['specifications'];
    if (specs is List) {
      for (final s in specs) {
        if (s is Map) {
          _specs.add(
            _SpecDraft(
              key: s['key']?.toString() ?? '',
              value: s['value']?.toString() ?? '',
            ),
          );
        }
      }
    }

    final variants = p?['variants'];
    if (variants is List) {
      for (final v in variants) {
        if (v is Map) {
          _variants.add(
            _VariantDraft(
              name: v['name']?.toString() ?? '',
              sku: v['sku']?.toString() ?? '',
              price: v['price']?.toString() ?? '',
              offerPrice: v['offerPrice']?.toString() ?? '',
              inStock: _asBool(v['inStock']),
            ),
          );
        }
      }
    }

    _existingImageUrls = List<String>.from(_initialImageUrls);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _descController.removeListener(_onFieldChanged);
    _brandController.removeListener(_onFieldChanged);
    _skuController.removeListener(_onFieldChanged);
    _unitController.removeListener(_onFieldChanged);
    _weightController.removeListener(_onFieldChanged);

    _nameController.dispose();
    _descController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _skuController.dispose();
    _unitController.dispose();
    _weightController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _offerValueController.dispose();
    _offerPriceController.dispose();
    for (final s in _specs) {
      s.dispose();
    }
    for (final v in _variants) {
      v.dispose();
    }
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
      setState(() => _pickedImages.addAll(newFiles));
    } else if (result is XFile && remaining > 0) {
      final compressedFile = await img_service.compressImageIfNeeded(
        File(result.path),
      );
      setState(() => _pickedImages.add(compressedFile));
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
        'Title is required',
        type: ToastType.error,
      );
      return;
    }
    if (title.length < 3) {
      ToastService().showToast(
        context,
        'Title must be at least 3 characters',
        type: ToastType.error,
      );
      return;
    }
    if (title.length > 100) {
      ToastService().showToast(
        context,
        'Title cannot exceed 100 characters',
        type: ToastType.error,
      );
      return;
    }
    if (_descController.text.trim().length > 1000) {
      ToastService().showToast(
        context,
        'Description cannot exceed 1000 characters',
        type: ToastType.error,
      );
      return;
    }

    final priceStr = _priceController.text.trim();
    final priceVal = double.tryParse(priceStr);
    if (priceStr.isEmpty || priceVal == null || priceVal <= 0) {
      ToastService().showToast(
        context,
        'Base price is required and must be greater than 0',
        type: ToastType.error,
      );
      return;
    }

    if (_hasVariants) {
      for (final v in _variants) {
        if (v.name.text.trim().isEmpty) {
          ToastService().showToast(
            context,
            'Each variant needs a name',
            type: ToastType.error,
          );
          return;
        }
        final vp = double.tryParse(v.price.text.trim());
        if (vp == null || vp < 0) {
          ToastService().showToast(
            context,
            'Variant price cannot be negative',
            type: ToastType.error,
          );
          return;
        }
      }
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);

      final brand = _brandController.text.trim();
      final sku = _skuController.text.trim();
      final unit = _unitController.text.trim();
      final weight = _weightController.text.trim();

      final validSpecs = _specs
          .where((s) => s.key.text.trim().isNotEmpty)
          .map(
            (s) => {
              'key': s.key.text.trim(),
              'value': s.value.text.trim(),
            },
          )
          .toList();

      final validVariants = _hasVariants
          ? _variants
                .where((v) => v.name.text.trim().isNotEmpty)
                .map((v) {
                  final op = v.offerPrice.text.trim();
                  return {
                    'name': v.name.text.trim(),
                    'sku': v.sku.text.trim().isEmpty
                        ? null
                        : v.sku.text.trim(),
                    'price': double.tryParse(v.price.text.trim()) ?? 0,
                    'offerPrice': op.isEmpty ? null : double.tryParse(op),
                    'inStock': v.inStock,
                  };
                })
                .toList()
          : <Map<String, dynamic>>[];

      final rawBody = <String, dynamic>{
        'title': title,
        'description': _descController.text.trim(),
        'price': priceStr,
        'tags': _tags.isNotEmpty ? jsonEncode(_tags) : null,
        'isActive': _isActive.toString(),
        'inStock': _inStock.toString(),
        'hasOffer': _hasOffer.toString(),
        'hasVariants': _hasVariants.toString(),
        'specifications': jsonEncode(validSpecs),
        'variants': jsonEncode(validVariants),
        if (brand.isNotEmpty) 'brand': brand,
        if (sku.isNotEmpty) 'sku': sku,
        if (unit.isNotEmpty) 'unit': unit,
        if (weight.isNotEmpty) 'weight': weight,
      };

      if (_hasOffer) {
        rawBody['offerType'] = _offerType;
        rawBody['offerValue'] = _offerValueController.text.trim().isEmpty
            ? '0'
            : _offerValueController.text.trim();
        final op = _offerPriceController.text.trim();
        if (op.isNotEmpty) rawBody['offerPrice'] = op;
      }

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
              // Images (admin order)
              Text(
                'Images',
                style: kSmallTitleM.copyWith(
                  color: const Color(0xFF0A0A0A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add up to $_maxImages images. First image is used as thumbnail.',
                style: kSmallTitleL.copyWith(
                  color: const Color(0xFF808080),
                  fontSize: 11,
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
                    return _imageTile(
                      child: AdvancedNetworkImage(
                        imageUrl: _existingImageUrls[index],
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                      onRemove: () => setState(
                        () => _existingImageUrls.removeAt(index),
                      ),
                      isThumb: index == 0,
                    );
                  }),
                  ...List.generate(_pickedImages.length, (index) {
                    return _imageTile(
                      child: Image.file(
                        _pickedImages[index],
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                      onRemove: () =>
                          setState(() => _pickedImages.removeAt(index)),
                      isThumb:
                          _existingImageUrls.isEmpty && index == 0,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),

              PrimaryTextField(
                controller: _nameController,
                label: 'Title',
                hint: 'Product name (3 - 100 characters)',
                isRequired: true,
                maxLength: 100,
                showCounter: true,
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                controller: _brandController,
                label: 'Brand / Manufacturer',
                hint: "e.g. L'Oréal, Nike, Apple",
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Product description (max 1000 characters)',
                maxLines: 4,
                maxLength: 1000,
                showCounter: true,
              ),
              const SizedBox(height: 20),

              PrimaryTextField(
                controller: _priceController,
                label: 'Base Price (₹)',
                hint: '₹ 0.00',
                isRequired: true,
                type: TextFieldType.number,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _skuController,
                      label: 'SKU / Code',
                      hint: 'e.g. PRD-1029',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryTextField(
                      controller: _unitController,
                      label: 'Unit / Packaging',
                      hint: 'e.g. piece, pack, ml',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                controller: _weightController,
                label: 'Net Weight / Vol',
                hint: 'e.g. 500g, 1.2 kg',
              ),
              const SizedBox(height: 20),

              // Special Offer / Discount
              _sectionCard(
                borderColor: const Color(0xFFA7F3D0),
                bg: const Color(0xFFECFDF5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_offer_outlined,
                          color: Color(0xFF059669),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Special Offer / Discount',
                            style: kSmallTitleM.copyWith(
                              fontWeight: FontWeight.w600,
                              color: kBlack,
                            ),
                          ),
                        ),
                        CupertinoSwitch(
                          value: _hasOffer,
                          activeTrackColor: kPrimaryColor,
                          onChanged: (val) {
                            setState(() {
                              _hasOffer = val;
                              if (val) _recomputeOfferPrice();
                            });
                          },
                        ),
                      ],
                    ),
                    if (_hasOffer) ...[
                      const SizedBox(height: 14),
                      const Divider(color: Color(0xFFA7F3D0), height: 1),
                      const SizedBox(height: 14),
                      Text(
                        'Offer Type',
                        style: kSmallTitleM.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _offerTypeChip(
                              label: '% Percent Off',
                              selected: _offerType == 'percentage',
                              onTap: () {
                                setState(() {
                                  _offerType = 'percentage';
                                  _recomputeOfferPrice();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _offerTypeChip(
                              label: '₹ Flat Off',
                              selected: _offerType == 'amount',
                              onTap: () {
                                setState(() {
                                  _offerType = 'amount';
                                  _recomputeOfferPrice();
                                });
                              },
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
                      const SizedBox(height: 14),
                      PrimaryTextField(
                        controller: _offerPriceController,
                        label: 'Offer Price (₹)',
                        hint: 'Final customer price',
                        type: TextFieldType.number,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Specifications
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product Specifications',
                                style: kSmallTitleM.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Color, Size, Material, Warranty, etc.',
                                style: kSmallTitleL.copyWith(
                                  fontSize: 11,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _specs.add(_SpecDraft()));
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add'),
                          style: TextButton.styleFrom(
                            foregroundColor: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (_specs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'No custom specifications added.',
                          style: kSmallTitleL.copyWith(
                            color: const Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      ...List.generate(_specs.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: PrimaryTextField(
                                  controller: _specs[i].key,
                                  label: 'Attribute',
                                  hint: 'e.g. Color',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: PrimaryTextField(
                                  controller: _specs[i].value,
                                  label: 'Value',
                                  hint: 'e.g. Black',
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _specs[i].dispose();
                                    _specs.removeAt(i);
                                  });
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Variants
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.layers_outlined,
                          size: 18,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product Variants',
                                style: kSmallTitleM.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Sizes, colors, or options with custom prices',
                                style: kSmallTitleL.copyWith(
                                  fontSize: 11,
                                  color: const Color(0xFF808080),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: _hasVariants,
                          activeTrackColor: kPrimaryColor,
                          onChanged: (val) {
                            setState(() {
                              _hasVariants = val;
                              if (val && _variants.isEmpty) {
                                _variants.add(
                                  _VariantDraft(
                                    price: _priceController.text.trim(),
                                  ),
                                );
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
                            setState(() {
                              _variants.add(
                                _VariantDraft(
                                  price: _priceController.text.trim(),
                                ),
                              );
                            });
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Variant'),
                          style: TextButton.styleFrom(
                            foregroundColor: kPrimaryColor,
                          ),
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
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Variant #${i + 1}',
                                    style: kSmallTitleM.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    v.inStock ? 'In Stock' : 'Out of Stock',
                                    style: kSmallTitleL.copyWith(fontSize: 11),
                                  ),
                                  CupertinoSwitch(
                                    value: v.inStock,
                                    activeTrackColor: kPrimaryColor,
                                    onChanged: (val) {
                                      setState(() => v.inStock = val);
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        v.dispose();
                                        _variants.removeAt(i);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                              PrimaryTextField(
                                controller: v.name,
                                label: 'Variant Name',
                                hint: 'e.g. XL / Red, 500ml',
                                isRequired: true,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: PrimaryTextField(
                                      controller: v.sku,
                                      label: 'SKU / Code',
                                      hint: 'e.g. VAR-01',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: PrimaryTextField(
                                      controller: v.price,
                                      label: 'Price (₹)',
                                      hint: '₹',
                                      isRequired: true,
                                      type: TextFieldType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              PrimaryTextField(
                                controller: v.offerPrice,
                                label: 'Offer Price (₹)',
                                hint: 'Optional',
                                type: TextFieldType.number,
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

              // Stock & Active
              _sectionCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'In Stock',
                              style: kSmallTitleM.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Available for customers',
                              style: kSmallTitleL.copyWith(
                                fontSize: 11,
                                color: const Color(0xFF808080),
                              ),
                            ),
                          ],
                        ),
                        CupertinoSwitch(
                          value: _inStock,
                          activeTrackColor: kPrimaryColor,
                          onChanged: (val) => setState(() => _inStock = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFE5E7EB), height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active',
                              style: kSmallTitleM.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Visible on catalog',
                              style: kSmallTitleL.copyWith(
                                fontSize: 11,
                                color: const Color(0xFF808080),
                              ),
                            ),
                          ],
                        ),
                        CupertinoSwitch(
                          value: _isActive,
                          activeTrackColor: kPrimaryColor,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],
                    ),
                  ],
                ),
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
                          setState(() => _tags.add(newTag));
                        }
                        _tagsController.clear();
                      }
                    },
                    onSubmitted: (val) {
                      final newTag = val.trim();
                      if (newTag.isNotEmpty && !_tags.contains(newTag)) {
                        setState(() => _tags.add(newTag));
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
                          onDeleted: () => setState(() => _tags.remove(tag)),
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
              const SizedBox(height: 24),
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

  Widget _offerTypeChip({
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
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
}
