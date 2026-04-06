import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../components/advanced_network_image.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../../data/services/image_services.dart' as img_service;
import '../../../data/services/toast_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

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
  String? _selectedCategoryId;
  
  File? _pickedImage;
  bool _isLoading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?['title']);
    _descController = TextEditingController(text: widget.product?['description']);
    _priceController = TextEditingController(text: widget.product?['price']?.toString());
    _categoryController = TextEditingController(text: widget.product?['category']?['category']);
    _tagsController = TextEditingController(text: (widget.product?['tags'] as List?)?.join(', '));
    _selectedCategoryId = widget.product?['category']?['_id'];
    _isActive = widget.product?['isActive'] ?? true;
  }

  @override
  void dispose() {
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
      showDocument: false,
    );

    if (result is XFile) {
      setState(() {
        _pickedImage = File(result.path);
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
                          _selectedCategoryId = cat.id;
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

  Future<void> _saveProduct() async {
    if (_nameController.text.trim().isEmpty) {
      ToastService().showToast(context, 'Title is required', type: ToastType.error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      final body = {
        'title': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': _priceController.text.trim(),
        'tags': _tagsController.text.trim(),
        'isActive': _isActive.toString(),
      };
      if (_selectedCategoryId != null) {
        body['category'] = _selectedCategoryId!;
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
          )
        ];
      }

      final response = await api.postMultipart('/products', body, files: files);

      if (response.success && mounted) {
        ToastService().showToast(context, 'Product created successfully');
        Navigator.pop(context);
      } else if (mounted) {
        ToastService().showToast(context, response.message ?? 'Failed to create product', type: ToastType.error);
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
            PrimaryTextField(
              controller: _tagsController,
              label: 'Tags',
              hint: 'e.g. food, pizza, vegetarian (comma separated)',
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
              'Product Image',
              style: kSmallTitleM.copyWith(
                color: const Color(0xFF0A0A0A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 140,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _pickedImage != null
                    ? Image.file(_pickedImage!, fit: BoxFit.cover)
                    : (widget.product != null && widget.product!['images'] != null && (widget.product!['images'] as List).isNotEmpty)
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
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PrimaryButton(
            onPressed: _saveProduct,
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
