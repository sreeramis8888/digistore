import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../../../src/data/services/image_services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MerchantAccountPage extends ConsumerStatefulWidget {
  final bool isEditMode;
  const MerchantAccountPage({super.key, this.isEditMode = false});

  @override
  ConsumerState<MerchantAccountPage> createState() =>
      _MerchantAccountPageState();
}

class _MerchantAccountPageState extends ConsumerState<MerchantAccountPage> {
  late bool isEditMode;
  File? _profileImage;

  late TextEditingController _ownerNameCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _locationCtrl;

  late TextEditingController _shopNameCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _contactNumCtrl;
  late TextEditingController _whatsappCtrl;
  late TextEditingController _panCtrl;
  late TextEditingController _shopAddressCtrl;
  late TextEditingController _pincodeCtrl;
  late TextEditingController _mapLocationCtrl;

  Map<String, bool> workingDays = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': true,
    'Sunday': false,
  };

  @override
  void initState() {
    super.initState();
    isEditMode = widget.isEditMode;

    _ownerNameCtrl = TextEditingController(text: 'John Sam');
    _mobileCtrl = TextEditingController(text: '98888774456');
    _emailCtrl = TextEditingController(text: 'freshmartKlm@gmail.com');
    _locationCtrl = TextEditingController(text: 'Palarivattom, Kochi');

    _shopNameCtrl = TextEditingController(text: 'Freshmart Supermarket');
    _categoryCtrl = TextEditingController(text: 'Daily Needs');
    _contactNumCtrl = TextEditingController(text: '9898887776');
    _whatsappCtrl = TextEditingController(text: '9898887776');
    _panCtrl = TextEditingController(text: 'AANPS8558A');
    _shopAddressCtrl = TextEditingController(text: '12, Church Road, Kochi');
    _pincodeCtrl = TextEditingController(text: '7056030');
    _mapLocationCtrl = TextEditingController(
      text: '12, MG Road, Palarivattom, Kochi',
    );
  }

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _locationCtrl.dispose();

    _shopNameCtrl.dispose();
    _categoryCtrl.dispose();
    _contactNumCtrl.dispose();
    _whatsappCtrl.dispose();
    _panCtrl.dispose();
    _shopAddressCtrl.dispose();
    _pincodeCtrl.dispose();
    _mapLocationCtrl.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title, {bool showAdd = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: kSmallTitleM.copyWith(
                fontWeight: FontWeight.w600,
                color: kBlack,
              ),
            ),
            if (showAdd && isEditMode)
              Text(
                '+Add',
                style: kSmallTitleL.copyWith(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReadOnlyRow(String label, String value, {Widget? prefixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: kSmallTitleM.copyWith(color: const Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon,
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    value.isNotEmpty ? value : '-',
                    style: kSmallTitleM.copyWith(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableChip(String label, {Widget? prefixIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixIcon != null) ...[prefixIcon, const SizedBox(width: 6)],
          Text(
            label,
            style: kSmallTitleL.copyWith(color: const Color(0xFF373737)),
          ),
          if (isEditMode) ...[
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 14, color: Color(0xFF808080)),
          ],
        ],
      ),
    );
  }

  Widget _buildShopImage(int index, bool isLast) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Icon(
              Icons.storefront,
              color: Colors.grey.shade400,
              size: 30,
            ),
          ),
          if (isLast)
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                '+ 3 More',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkingHourRow(String day, String start, String end) {
    bool isOpen = workingDays[day] ?? false;

    if (isEditMode) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                day,
                style: kSmallTitleL.copyWith(color: const Color(0xFF373737)),
              ),
            ),
            if (isOpen) ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    start,
                    style: kSmallTitleL.copyWith(
                      color: const Color(0xFF373737),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    end,
                    style: kSmallTitleL.copyWith(
                      color: const Color(0xFF373737),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text(
                    'Closed',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
            const SizedBox(width: 16),
            SizedBox(
              height: 24,
              child: CupertinoSwitch(
                value: isOpen,
                onChanged: (v) {
                  setState(() {
                    workingDays[day] = v;
                  });
                },
                activeTrackColor: kPrimaryColor,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                day,
                style: kSmallTitleL.copyWith(color: const Color(0xFF373737)),
              ),
            ),
            if (isOpen) ...[
              Expanded(
                child: Center(
                  child: Text(
                    start,
                    style: kSmallTitleL.copyWith(
                      color: const Color(0xFF373737),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    end,
                    style: kSmallTitleL.copyWith(
                      color: const Color(0xFF373737),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'Closed',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 40),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.transparent,
              size: 20,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: SvgPicture.asset('assets/svg/edit.svg'),
            onPressed: () {
              setState(() {
                isEditMode = true;
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(12),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: _profileImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          'FRESH\nSUPERMARKET',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              if (isEditMode)
                                GestureDetector(
                                  onTap: () async {
                                    final result = await pickMedia(
                                      context: context,
                                      enableCrop: true,
                                      cropRatio: const CropAspectRatio(
                                        ratioX: 1,
                                        ratioY: 1,
                                      ),
                                      showDocument: false,
                                    );
                                    if (result is XFile) {
                                      setState(() {
                                        _profileImage = File(result.path);
                                      });
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.flip_camera_ios_outlined,
                                        size: 16,
                                        color: kPrimaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Change Photo',
                                        style: kSmallTitleM.copyWith(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '4.5 ',
                                      style: kSmallTitleM.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: kBlack,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    Text(
                                      ' out of 10',
                                      style: kSmallTitleL.copyWith(
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Text(
                                      'Personal Informations',
                                      style: kSmallTitleM.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: kBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFF3F4F6),
                              ),
                              if (isEditMode) ...[
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'Owner Name',
                                    controller: _ownerNameCtrl,
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'Mobile Number',
                                    controller: _mobileCtrl,
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'Email',
                                    controller: _emailCtrl,
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'Location',
                                    controller: _locationCtrl,
                                    readOnly: true,
                                    suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xFF808080),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                _buildReadOnlyRow(
                                  'Owner Name',
                                  _ownerNameCtrl.text,
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                _buildReadOnlyRow(
                                  'Mobile Number',
                                  _mobileCtrl.text,
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                _buildReadOnlyRow('Email', _emailCtrl.text),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                _buildReadOnlyRow(
                                  'Location',
                                  _locationCtrl.text,
                                ),
                              ],
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Text(
                                      'Shop Details',
                                      style: kSmallTitleM.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: kBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0xFFF3F4F6),
                              ),
                              if (isEditMode) ...[
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'Shop Name',
                                    controller: _shopNameCtrl,
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'Category',
                                    controller: _categoryCtrl,
                                    readOnly: true,
                                    suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xFF808080),
                                    ),
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'Contact Number',
                                    controller: _contactNumCtrl,
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'WhatsApp Number',
                                    controller: _whatsappCtrl,
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'PAN Number',
                                    controller: _panCtrl,
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'Shop Address',
                                    controller: _shopAddressCtrl,
                                    readOnly: true,
                                    suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xFF808080),
                                    ),
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'Pincode',
                                    controller: _pincodeCtrl,
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PrimaryTextField(
                                    label: 'Google Map Location',
                                    controller: _mapLocationCtrl,
                                    readOnly: true,
                                    prefixIcon: const Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0xFF808080),
                                      size: 18,
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xFF808080),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                _buildReadOnlyRow(
                                  'Shop Name',
                                  _shopNameCtrl.text,
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                _buildReadOnlyRow(
                                  'Category',
                                  _categoryCtrl.text,
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                _buildReadOnlyRow(
                                  'Contact Number',
                                  _contactNumCtrl.text,
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                _buildReadOnlyRow(
                                  'WhatsApp Number',
                                  _whatsappCtrl.text,
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                _buildReadOnlyRow('PAN Number', _panCtrl.text),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                _buildReadOnlyRow(
                                  'Shop Address',
                                  _shopAddressCtrl.text,
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                _buildReadOnlyRow('Pincode', _pincodeCtrl.text),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                _buildReadOnlyRow(
                                  'Google Map Location',
                                  _mapLocationCtrl.text,
                                  prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFF808080),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        _buildSectionHeader('Branches', showAdd: true),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildRemovableChip('Kochi'),
                            _buildRemovableChip('Kottayam'),
                            _buildRemovableChip('Karunagapally'),
                          ],
                        ),

                        _buildSectionHeader('Social Media', showAdd: true),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildRemovableChip(
                              '@freshmart_supermarket',
                              prefixIcon: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.pink,
                                size: 16,
                              ),
                            ),
                            _buildRemovableChip(
                              'Freshmart Supermarket',
                              prefixIcon: const Icon(
                                Icons.facebook,
                                color: Colors.blue,
                                size: 16,
                              ),
                            ),
                          ],
                        ),

                        _buildSectionHeader('Shop Images', showAdd: true),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildShopImage(0, false),
                            _buildShopImage(1, false),
                            _buildShopImage(2, false),
                            _buildShopImage(3, true),
                          ],
                        ),

                        _buildSectionHeader('Working Hours'),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isEditMode
                                ? const Color(0xFFFFF7F7)
                                : Colors
                                      .transparent, // faint background not quite visible in image, let's keep transparent as there is none.
                          ),
                          child: Column(
                            children: [
                              _buildWorkingHourRow(
                                'Monday',
                                '09:00 AM',
                                '09:00 PM',
                              ),
                              _buildWorkingHourRow(
                                'Tuesday',
                                '09:00 AM',
                                '09:00 PM',
                              ),
                              _buildWorkingHourRow(
                                'Wednesday',
                                '09:00 AM',
                                '09:00 PM',
                              ),
                              _buildWorkingHourRow(
                                'Thursday',
                                '09:00 AM',
                                '09:00 PM',
                              ),
                              _buildWorkingHourRow(
                                'Friday',
                                '09:00 AM',
                                '09:00 PM',
                              ),
                              _buildWorkingHourRow(
                                'Saturday',
                                '10:00 AM',
                                '08:00 PM',
                              ),
                              _buildWorkingHourRow('Sunday', '-', '-'),
                            ],
                          ),
                        ),

                        SizedBox(height: screenSize.responsivePadding(32)),
                      ],
                    ),
                  ),
                ),
                if (isEditMode) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenSize.responsivePadding(16),
                    ),
                    child: PrimaryButton(
                      text: 'Save',
                      onPressed: () {
                        setState(() {
                          isEditMode = false;
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
