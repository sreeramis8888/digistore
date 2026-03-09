import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../components/advanced_network_image.dart';

class CreateProductPage extends StatefulWidget {
  final Map<String, String>? product;

  const CreateProductPage({super.key, this.product});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?['name']);
    _descController = TextEditingController(
      text: widget.product != null
          ? 'Sodales cras etiam senectus turpis at scelerisque sed ullamcorper. Orci tincidunt scelerisque nunc in. Ut semper cursus in vel. Gravida vehicula lorem amet faucibus. Nec tellus nisi arcu neque ultrices. Urna lobortis ipsum sollicitudin quis id tortor.'
          : null,
    );

    String? initialPrice = widget.product?['price'];
    if (initialPrice != null) {
      initialPrice = initialPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    }
    _priceController = TextEditingController(text: initialPrice);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
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
            Text(
              'Product Image',
              style: kSmallTitleM.copyWith(
                color: const Color(0xFF0A0A0A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Add image picker logic
              },
              child: Container(
                width: double.infinity,
                height: 140,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    widget.product != null && widget.product!['image'] != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          AdvancedNetworkImage(
                            imageUrl: widget.product!['image']!,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child:SvgPicture.asset('assets/svg/edit.svg'),
                          ),
                        ],
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
            onPressed: () {
              Navigator.pop(context);
            },
            text: 'Save',
            backgroundColor: kPrimaryColor,
            textColor: kWhite,
          ),
        ),
      ),
    );
  }
}
