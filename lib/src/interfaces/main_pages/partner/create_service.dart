import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/service_model.dart';
import '../../../data/providers/partner_services_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';

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
  late TextEditingController _imageUrlController;

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
  bool _isSubmitting = false;

  final List<String> _allDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.existingService;
    _nameController = TextEditingController(text: s?.name ?? '');
    _categoryController = TextEditingController(text: s?.category ?? 'Hair');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _priceController = TextEditingController(text: s != null ? s.originalPrice.toInt().toString() : '');
    _offerValueController = TextEditingController(text: s?.offerValue?.toInt().toString() ?? '');
    _durationController = TextEditingController(text: s?.durationMinutes.toString() ?? '30');
    _bufferController = TextEditingController(text: s?.bufferMinutes.toString() ?? '5');
    _maxGuestsController = TextEditingController(text: s?.maxConcurrentGuests.toString() ?? '1');
    _spaceLabelController = TextEditingController(text: s?.spaceLabel ?? 'Chairs');
    _imageUrlController = TextEditingController(text: s != null && s.images.isNotEmpty ? s.images.first : '');
    _hasOffer = s?.hasOffer ?? false;
    _offerType = s?.offerType ?? 'percentage';
    if (s != null && s.availableDays.isNotEmpty) {
      _selectedDays.clear();
      _selectedDays.addAll(s.availableDays);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _offerValueController.dispose();
    _durationController.dispose();
    _bufferController.dispose();
    _maxGuestsController.dispose();
    _spaceLabelController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final offerVal = double.tryParse(_offerValueController.text.trim());
    final duration = int.tryParse(_durationController.text.trim()) ?? 30;
    final buffer = int.tryParse(_bufferController.text.trim()) ?? 0;
    final maxGuests = int.tryParse(_maxGuestsController.text.trim()) ?? 1;

    final payload = {
      'name': _nameController.text.trim(),
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
      if (_imageUrlController.text.trim().isNotEmpty)
        'images': [_imageUrlController.text.trim()],
    };

    final notifier = ref.read(partnerServicesProvider.notifier);
    final res = widget.existingService != null
        ? await notifier.updateService(widget.existingService!.id!, payload)
        : await notifier.createService(payload);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingService != null
                ? 'Service updated successfully'
                : 'Service created successfully'),
            backgroundColor: const Color(0xFF34C759),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? 'Failed to save service'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final isEditing = widget.existingService != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF373737),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Service' : 'Create Service',
          style: kSubHeadingM.copyWith(
            color: const Color(0xFF373737),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenSize.responsivePadding(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardSection(
                  screenSize: screenSize,
                  title: 'Basic Information',
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Service Name',
                      hint: 'e.g. Deluxe Haircut & Wash',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _categoryController,
                      label: 'Category',
                      hint: 'e.g. Hair, Facial, Massage, Spa, Auto',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe what the service includes...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _imageUrlController,
                      label: 'Image URL (Optional)',
                      hint: 'https://...',
                    ),
                  ],
                ),
                SizedBox(height: screenSize.responsivePadding(16)),

                _buildCardSection(
                  screenSize: screenSize,
                  title: 'Pricing & Offers',
                  children: [
                    _buildTextField(
                      controller: _priceController,
                      label: 'Standard Price (₹)',
                      hint: 'e.g. 500',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Apply Promotional Offer',
                        style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      value: _hasOffer,
                      activeThumbColor: kPrimaryColor,
                      onChanged: (val) => setState(() => _hasOffer = val),
                    ),
                    if (_hasOffer) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _offerType,
                              decoration: _inputDecoration('Offer Type'),
                              items: const [
                                DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
                                DropdownMenuItem(value: 'flat', child: Text('Flat Discount (₹)')),
                              ],
                              onChanged: (v) => setState(() => _offerType = v ?? 'percentage'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _offerValueController,
                              label: _offerType == 'percentage' ? 'Discount %' : 'Discount ₹',
                              hint: _offerType == 'percentage' ? 'e.g. 20' : 'e.g. 100',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                SizedBox(height: screenSize.responsivePadding(16)),

                _buildCardSection(
                  screenSize: screenSize,
                  title: 'Timings & Capacity',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _durationController,
                            label: 'Duration (mins)',
                            hint: '30',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _bufferController,
                            label: 'Buffer (mins)',
                            hint: '5',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _maxGuestsController,
                            label: 'Concurrent Guests',
                            hint: '1',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _spaceLabelController,
                            label: 'Space Label',
                            hint: 'Chairs / Rooms',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Available Days',
                      style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allDays.map((day) {
                        final isSelected = _selectedDays.contains(day);
                        return FilterChip(
                          label: Text(day.substring(0, 3).toUpperCase()),
                          selected: isSelected,
                          selectedColor: kPrimaryColor,
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: isSelected ? kWhite : const Color(0xFF374151),
                          ),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedDays.add(day);
                              } else {
                                if (_selectedDays.length > 1) {
                                  _selectedDays.remove(day);
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.responsivePadding(24)),

                PrimaryButton(
                  onPressed: _handleSubmit,
                  isEnabled: !_isSubmitting,
                  width: double.infinity,
                  height: screenSize.responsivePadding(48),
                  text: _isSubmitting
                      ? 'Saving...'
                      : (isEditing ? 'Update Service' : 'Create Service'),
                  textSize: 15,
                  backgroundColor: kPrimaryColor,
                  textColor: kWhite,
                ),
                SizedBox(height: screenSize.responsivePadding(30)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required ScreenSizeData screenSize,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const Divider(height: 20, color: Color(0xFFE5E7EB)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDecoration(label, hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF6B7280)),
      hintText: hintText,
      hintStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF9CA3AF)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
