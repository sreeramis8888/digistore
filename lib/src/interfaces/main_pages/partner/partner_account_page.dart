import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../../data/services/image_services.dart' as img_service;
import '../../../data/services/toast_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/providers/category_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../../data/models/partner_model.dart';
import '../../../data/models/business_details.dart';
import '../../../data/models/business_info.dart';
import '../../../data/models/location_point.dart';
import '../../components/add_specialty_dialog.dart';
import '../../components/add_branch_dialog.dart';
import '../../components/map_location_picker_page.dart';
import '../../components/confirmation_dialog.dart';

class PartnerAccountPage extends ConsumerStatefulWidget {
  final bool isEditMode;
  const PartnerAccountPage({super.key, this.isEditMode = false});

  @override
  ConsumerState<PartnerAccountPage> createState() => _PartnerAccountPageState();
}

class _PartnerAccountPageState extends ConsumerState<PartnerAccountPage> {
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

  double? _lat;
  double? _lng;

  late TextEditingController _taglineCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _websiteUrlCtrl;
  late TextEditingController _instagramCtrl;
  late TextEditingController _facebookCtrl;
  late TextEditingController _youtubeCtrl;

  List<String> _specialties = [];
  List<BusinessBranch> _branches = [];
  List<String> _businessImages = [];
  OperatingHours? _operatingHours;

  File? _pickedLogo;
  File? _pickedCover;
  List<File> _pickedGallery = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.isEditMode;
    final partner = ref.read(partnerProvider);

    _ownerNameCtrl = TextEditingController(
      text: partner?.businessInfo?.ownerName ?? '',
    );
    _mobileCtrl = TextEditingController(
      text: partner?.businessInfo?.contactPhone ?? '',
    );
    _emailCtrl = TextEditingController(
      text: partner?.businessInfo?.email ?? '',
    );
    _locationCtrl = TextEditingController(
      text: partner?.businessDetails?.address ?? '',
    );

    _shopNameCtrl = TextEditingController(
      text: partner?.businessDetails?.businessName ?? '',
    );
    _categoryCtrl = TextEditingController(
      text: partner?.businessDetails?.businessType ?? '',
    );
    _contactNumCtrl = TextEditingController(
      text: partner?.businessInfo?.contactPhone ?? '',
    );
    _whatsappCtrl = TextEditingController(
      text: partner?.businessInfo?.whatsappNumber ?? '',
    );
    _panCtrl = TextEditingController(
      text: partner?.businessDetails?.gstNumber ?? '',
    );
    _shopAddressCtrl = TextEditingController(
      text: partner?.businessDetails?.address ?? '',
    );
    _pincodeCtrl = TextEditingController(
      text: partner?.businessDetails?.pincode ?? '',
    );
    _mapLocationCtrl = TextEditingController(
      text: partner?.businessDetails?.address ?? '',
    );

    _taglineCtrl = TextEditingController(
      text: partner?.businessInfo?.tagline ?? '',
    );
    _descriptionCtrl = TextEditingController(
      text: partner?.businessInfo?.description ?? '',
    );
    _websiteUrlCtrl = TextEditingController(
      text: partner?.businessInfo?.websiteUrl ?? '',
    );
    _instagramCtrl = TextEditingController(
      text: partner?.businessInfo?.socialLinks?.instagram ?? '',
    );
    _facebookCtrl = TextEditingController(
      text: partner?.businessInfo?.socialLinks?.facebook ?? '',
    );
    _youtubeCtrl = TextEditingController(
      text: partner?.businessInfo?.socialLinks?.youtube ?? '',
    );

    _specialties = List.from(partner?.businessInfo?.specialties ?? []);
    _branches = List.from(partner?.businessInfo?.branches ?? []);
    _businessImages = List.from(partner?.businessInfo?.businessImages ?? []);
    _operatingHours = partner?.businessInfo?.operatingHours;

    final coords = partner?.businessInfo?.storeLocation?.coordinates;
    if (coords != null && coords.length >= 2) {
      _lng = coords[0];
      _lat = coords[1];
    }
  }

  Future<void> _showGoogleMapLocationPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerPage(
          initialLat: _lat,
          initialLng: _lng,
          initialDistrict: _locationCtrl.text,
          initialLocalBody: _shopAddressCtrl.text,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _locationCtrl.text = result['district'] as String;
        _shopAddressCtrl.text = result['localBody'] as String;
        _lat = result['lat'] as double;
        _lng = result['lng'] as double;
        _mapLocationCtrl.text = '${_locationCtrl.text}, ${_shopAddressCtrl.text}';
      });
    }
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

    _taglineCtrl.dispose();
    _descriptionCtrl.dispose();
    _websiteUrlCtrl.dispose();
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _youtubeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(String field) async {
    final result = await img_service.pickMedia(
      context: context,
      enableCrop: true,
      cropRatio: field == 'logo'
          ? const CropAspectRatio(ratioX: 1, ratioY: 1)
          : null,
      showDocument: false,
    );

    if (result is XFile) {
      File originalFile = File(result.path);
      File compressedFile = await img_service.compressImageIfNeeded(originalFile);
      
      setState(() {
        if (field == 'logo') {
          _pickedLogo = compressedFile;
          _profileImage = _pickedLogo;
        } else if (field == 'cover') {
          _pickedCover = compressedFile;
        } else {
          _pickedGallery.add(compressedFile);
        }
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
                        setState(() => _categoryCtrl.text = cat.name ?? '');
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

  void _updateDayStatus(
    String day, {
    bool? isOpen,
    String? open,
    String? close,
  }) {
    final current = _operatingHours ?? const OperatingHours();
    DayStatus? status;
    switch (day) {
      case 'Monday':
        status = current.monday;
        break;
      case 'Tuesday':
        status = current.tuesday;
        break;
      case 'Wednesday':
        status = current.wednesday;
        break;
      case 'Thursday':
        status = current.thursday;
        break;
      case 'Friday':
        status = current.friday;
        break;
      case 'Saturday':
        status = current.saturday;
        break;
      case 'Sunday':
        status = current.sunday;
        break;
    }

    final newStatus = DayStatus(
      isOpen: isOpen ?? status?.isOpen ?? false,
      open: open ?? status?.open ?? '09:00 AM',
      close: close ?? status?.close ?? '09:00 PM',
    );

    setState(() {
      _operatingHours = OperatingHours(
        monday: day == 'Monday' ? newStatus : current.monday,
        tuesday: day == 'Tuesday' ? newStatus : current.tuesday,
        wednesday: day == 'Wednesday' ? newStatus : current.wednesday,
        thursday: day == 'Thursday' ? newStatus : current.thursday,
        friday: day == 'Friday' ? newStatus : current.friday,
        saturday: day == 'Saturday' ? newStatus : current.saturday,
        sunday: day == 'Sunday' ? newStatus : current.sunday,
      );
    });
  }

  void _showAddSpecialtyDialog() async {
    final result = await showAddSpecialtyDialog(context);
    if (result != null && mounted) {
      setState(() => _specialties.add(result));
    }
  }

  void _showAddBranchDialog() async {
    final result = await showAddBranchDialog(context);
    if (result != null && mounted) {
      setState(() => _branches.add(result));
    }
  }

  Widget _buildSectionHeader(
    String title, {
    bool showAdd = false,
    VoidCallback? onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
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
                GestureDetector(
                  onTap: onAdd,
                  child: Text(
                    '+Add',
                    style: kSmallTitleL.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
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

  Widget _buildRemovableChip(
    String label, {
    Widget? prefixIcon,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixIcon != null) ...[prefixIcon, const SizedBox(width: 4)],
          Text(
            label,
            style: kSmallTitleL.copyWith(
              color: const Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isEditMode && onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.close,
                size: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShopImage({String? imageUrl, String? overlayText}) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? AdvancedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                : Icon(Icons.storefront, color: Colors.grey.shade400, size: 30),
          ),
          if (overlayText != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                overlayText,
                style: const TextStyle(
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

  Widget _buildWorkingHourRow(String day) {
    final current = _operatingHours ?? const OperatingHours();
    DayStatus? status;
    switch (day) {
      case 'Monday':
        status = current.monday;
        break;
      case 'Tuesday':
        status = current.tuesday;
        break;
      case 'Wednesday':
        status = current.wednesday;
        break;
      case 'Thursday':
        status = current.thursday;
        break;
      case 'Friday':
        status = current.friday;
        break;
      case 'Saturday':
        status = current.saturday;
        break;
      case 'Sunday':
        status = current.sunday;
        break;
    }

    bool isOpen = status?.isOpen ?? false;
    String start = status?.open ?? '09:00 AM';
    String end = status?.close ?? '09:00 PM';

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
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          timePickerTheme: TimePickerThemeData(
                            backgroundColor: kWhite,
                            dialBackgroundColor: kField,
                            dialHandColor: kPrimaryColor,
                            dialTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected) ? kWhite : kTextColor,
                            ),
                            hourMinuteColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected) ? kPrimaryColor : kField,
                            ),
                            hourMinuteTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected) ? kWhite : kTextColor,
                            ),
                            dayPeriodColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected) ? kPrimaryLightColor : kField,
                            ),
                            dayPeriodTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected) ? kPrimaryColor : kSecondaryTextColor,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            entryModeIconColor: kPrimaryColor,
                          ),
                          colorScheme: const ColorScheme.light(
                            primary: kPrimaryColor,
                            onPrimary: kWhite,
                            surface: kWhite,
                            onSurface: kTextColor,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (time != null && mounted) {
                      _updateDayStatus(day, open: time.format(context));
                    }
                  },
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          timePickerTheme: TimePickerThemeData(
                            backgroundColor: kWhite,
                            dialBackgroundColor: kField,
                            dialHandColor: kPrimaryColor,
                            dialTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected) ? kWhite : kTextColor,
                            ),
                            hourMinuteColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected) ? kPrimaryColor : kField,
                            ),
                            hourMinuteTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected) ? kWhite : kTextColor,
                            ),
                            dayPeriodColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected) ? kPrimaryLightColor : kField,
                            ),
                            dayPeriodTextColor: WidgetStateColor.resolveWith(
                              (s) => s.contains(WidgetState.selected) ? kPrimaryColor : kSecondaryTextColor,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            dayPeriodShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            entryModeIconColor: kPrimaryColor,
                          ),
                          colorScheme: const ColorScheme.light(
                            primary: kPrimaryColor,
                            onPrimary: kWhite,
                            surface: kWhite,
                            onSurface: kTextColor,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (time != null && mounted) {
                      _updateDayStatus(day, close: time.format(context));
                    }
                  },
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
                onChanged: (v) => _updateDayStatus(day, isOpen: v),
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
    final partner = ref.watch(partnerProvider);

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
          if (!isEditMode)
            IconButton(
              icon: SvgPicture.asset('assets/svg/edit.svg'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PartnerAccountPage(isEditMode: true),
                  ),
                );
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: isEditMode
                                ? () => _pickAndUploadImage('cover')
                                : null,
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _pickedCover != null
                                        ? Image.file(
                                            _pickedCover!,
                                            fit: BoxFit.cover,
                                          )
                                        : partner?.businessInfo?.coverImage !=
                                              null
                                        ? AdvancedNetworkImage(
                                            imageUrl: partner!
                                                .businessInfo!
                                                .coverImage!,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.image_outlined,
                                              size: 48,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                  ),
                                  if (isEditMode)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.camera_alt_outlined,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Change Cover',
                                              style: kSmallTitleL.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

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
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                  ),
                                        ),
                                      )
                                    : partner?.businessInfo?.businessLogo !=
                                          null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: AdvancedNetworkImage(
                                          imageUrl: partner!
                                              .businessInfo!
                                              .businessLogo!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          partner?.businessDetails?.businessName
                                                  ?.toUpperCase() ??
                                              '',
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
                                  onTap: () => _pickAndUploadImage('logo'),
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
                                    label: 'Mobile Number',
                                    controller: _mobileCtrl,
                                    readOnly: true,
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
                                  ),
                                ),
                              ] else ...[
                                _buildReadOnlyRow(
                                  'Mobile Number',
                                  _mobileCtrl.text,
                                ),
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
                                    label: 'Shop Address',
                                    controller: _shopAddressCtrl,
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
                                    onTap: _showGoogleMapLocationPicker,
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

                              _buildSectionHeader(
                                'Branches',
                                showAdd: true,
                                onAdd: () => _showAddBranchDialog(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ..._branches.map(
                                        (branch) => _buildRemovableChip(
                                          branch.name ?? '',
                                          onDelete: () => setState(
                                            () => _branches.remove(branch),
                                          ),
                                        ),
                                      ),
                                      if (_branches.isEmpty)
                                        Text(
                                          'No branches added',
                                          style: kSmallTitleL.copyWith(
                                            color: kGrey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              _buildSectionHeader(
                                'Specialties',
                                showAdd: true,
                                onAdd: () => _showAddSpecialtyDialog(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ..._specialties.map(
                                        (s) => _buildRemovableChip(
                                          s,
                                          onDelete: () => setState(
                                            () => _specialties.remove(s),
                                          ),
                                        ),
                                      ),
                                      if (_specialties.isEmpty)
                                        Text(
                                          'No specialties added',
                                          style: kSmallTitleL.copyWith(
                                            color: kGrey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              _buildSectionHeader(
                                'Social Media',
                                showAdd: false,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: [
                                    if (isEditMode) ...[
                                      PrimaryTextField(
                                        label: 'Instagram',
                                        controller: _instagramCtrl,
                                        hint: 'Instagram Profile Link',
                                      ),
                                      const SizedBox(height: 12),
                                      PrimaryTextField(
                                        label: 'Facebook',
                                        controller: _facebookCtrl,
                                        hint: 'Facebook Profile Link',
                                      ),
                                      const SizedBox(height: 12),
                                      PrimaryTextField(
                                        label: 'YouTube',
                                        controller: _youtubeCtrl,
                                        hint: 'YouTube Channel Link',
                                      ),
                                      const SizedBox(height: 12),
                                      PrimaryTextField(
                                        label: 'Website',
                                        controller: _websiteUrlCtrl,
                                        hint: 'Business Website URL',
                                      ),
                                    ] else ...[
                                      if (_instagramCtrl.text.isNotEmpty)
                                        _buildReadOnlyRow(
                                          'Instagram',
                                          _instagramCtrl.text,
                                          prefixIcon: const Icon(
                                            Icons.camera_alt_outlined,
                                            color: Colors.pink,
                                            size: 16,
                                          ),
                                        ),
                                      if (_facebookCtrl.text.isNotEmpty)
                                        _buildReadOnlyRow(
                                          'Facebook',
                                          _facebookCtrl.text,
                                          prefixIcon: const Icon(
                                            Icons.facebook,
                                            color: Colors.blue,
                                            size: 16,
                                          ),
                                        ),
                                      if (_youtubeCtrl.text.isNotEmpty)
                                        _buildReadOnlyRow(
                                          'YouTube',
                                          _youtubeCtrl.text,
                                          prefixIcon: const Icon(
                                            Icons.play_circle_outline,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                        ),
                                      if (_websiteUrlCtrl.text.isNotEmpty)
                                        _buildReadOnlyRow(
                                          'Website',
                                          _websiteUrlCtrl.text,
                                          prefixIcon: const Icon(
                                            Icons.language,
                                            color: Colors.blue,
                                            size: 16,
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),

                              _buildSectionHeader(
                                'Shop Images',
                                showAdd: true,
                                onAdd: () => _pickAndUploadImage('gallery'),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    ..._businessImages.asMap().entries.map((
                                      entry,
                                    ) {
                                      return Stack(
                                        children: [
                                          _buildShopImage(
                                            imageUrl: entry.value,
                                          ),
                                          if (isEditMode)
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final confirm =
                                                      await showConfirmationDialog(
                                                        context: context,
                                                        title: 'Delete Image',
                                                        message:
                                                            'Are you sure you want to delete this shop image?',
                                                        isDestructive: true,
                                                        confirmText: 'Delete',
                                                      );
                                                  if (confirm == true) {
                                                    setState(
                                                      () => _businessImages
                                                          .removeAt(entry.key),
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    2,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    }),
                                    ..._pickedGallery.asMap().entries.map((
                                      entry,
                                    ) {
                                      return Stack(
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                              bottom: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: FileImage(entry.value),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -2,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () async {
                                                final confirm =
                                                    await showConfirmationDialog(
                                                      context: context,
                                                      title: 'Remove Image',
                                                      message:
                                                          'Are you sure you want to remove this newly added image?',
                                                      isDestructive: true,
                                                      confirmText: 'Remove',
                                                    );
                                                if (confirm == true) {
                                                  setState(
                                                    () => _pickedGallery
                                                        .removeAt(entry.key),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                    if (isEditMode)
                                      GestureDetector(
                                        onTap: () =>
                                            _pickAndUploadImage('gallery'),
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              style: BorderStyle.none,
                                            ), // dashed border not easily possible without extra package, let's just use normal
                                          ),
                                          child: const Icon(
                                            Icons.add_a_photo_outlined,
                                            color: kGrey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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
                                    _buildWorkingHourRow('Monday'),
                                    _buildWorkingHourRow('Tuesday'),
                                    _buildWorkingHourRow('Wednesday'),
                                    _buildWorkingHourRow('Thursday'),
                                    _buildWorkingHourRow('Friday'),
                                    _buildWorkingHourRow('Saturday'),
                                    _buildWorkingHourRow('Sunday'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
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
                      text: 'Save Changes',
                      isLoading: _isLoading,
                      onPressed: () async {
                        final currentPartner = ref.read(partnerProvider);
                        if (currentPartner == null) return;

                        final updatedPartner = PartnerModel(
                          id: currentPartner.id,
                          userId: currentPartner.userId,
                          businessDetails: BusinessDetails(
                            businessName: _shopNameCtrl.text,
                            businessType: _categoryCtrl.text,
                            address: _shopAddressCtrl.text,
                            pincode: _pincodeCtrl.text,
                            gstNumber: _panCtrl.text,
                            registrationNumber: currentPartner
                                .businessDetails
                                ?.registrationNumber,
                          ),
                          businessInfo: BusinessInfo(
                            ownerName: _ownerNameCtrl.text,
                            email: _emailCtrl.text,
                            contactPhone: _contactNumCtrl.text,
                            whatsappNumber: _whatsappCtrl.text,
                            businessLogo:
                                currentPartner.businessInfo?.businessLogo,
                            coverImage: currentPartner.businessInfo?.coverImage,
                            businessImages: _businessImages,
                            tagline: _taglineCtrl.text,
                            description: _descriptionCtrl.text,
                            websiteUrl: _websiteUrlCtrl.text,
                            specialties: _specialties,
                            branches: _branches,
                            socialLinks: SocialLinks(
                              instagram: _instagramCtrl.text,
                              facebook: _facebookCtrl.text,
                              youtube: _youtubeCtrl.text,
                            ),
                            storeLocation: (_lat != null && _lng != null)
                                ? LocationPoint(
                                    type: 'Point',
                                    coordinates: [_lng!, _lat!],
                                    address: _mapLocationCtrl.text,
                                  )
                                : currentPartner.businessInfo?.storeLocation,
                            operatingHours: _operatingHours,
                          ),
                          serviceCategories: currentPartner.serviceCategories,
                          coverageAreas: currentPartner.coverageAreas,
                          isActive: currentPartner.isActive,
                          isFeatured: currentPartner.isFeatured,
                          verificationStatus: currentPartner.verificationStatus,
                          createdAt: currentPartner.createdAt,
                          updatedAt: DateTime.now(),
                        );

                        setState(() => _isLoading = true);
                        try {
                          final notifier = ref.read(partnerProvider.notifier);
                          bool success = true;

                          if (_pickedLogo == null &&
                              _pickedCover == null &&
                              _pickedGallery.isEmpty) {
                            success = await notifier.updateProfile(
                              updatedPartner,
                            );
                          } else {
                            if (_pickedLogo != null) {
                              final logoFile =
                                  await http.MultipartFile.fromPath(
                                    'images',
                                    _pickedLogo!.path,
                                    contentType: MediaType.parse(
                                      lookupMimeType(_pickedLogo!.path) ??
                                          'image/jpeg',
                                    ),
                                  );
                              success =
                                  await notifier.updateProfile(
                                    updatedPartner,
                                    files: [logoFile],
                                    uploadField: 'logo',
                                  ) &&
                                  success;
                            }

                            if (_pickedCover != null) {
                              final coverFile =
                                  await http.MultipartFile.fromPath(
                                    'images',
                                    _pickedCover!.path,
                                    contentType: MediaType.parse(
                                      lookupMimeType(_pickedCover!.path) ??
                                          'image/jpeg',
                                    ),
                                  );
                              success =
                                  await notifier.updateProfile(
                                    updatedPartner,
                                    files: [coverFile],
                                    uploadField: 'cover',
                                  ) &&
                                  success;
                            }

                            if (_pickedGallery.isNotEmpty) {
                              final galleryFiles = await Future.wait(
                                _pickedGallery.map(
                                  (f) => http.MultipartFile.fromPath(
                                    'images',
                                    f.path,
                                    contentType: MediaType.parse(
                                      lookupMimeType(f.path) ?? 'image/jpeg',
                                    ),
                                  ),
                                ),
                              );
                              success =
                                  await notifier.updateProfile(
                                    updatedPartner,
                                    files: galleryFiles,
                                    uploadField: 'gallery',
                                  ) &&
                                  success;
                            }
                          }

                          if (success && context.mounted) {
                            ToastService().showToast(
                              context,
                              'Profile updated successfully',
                            );
                            Navigator.pop(context);
                          } else if (!success && context.mounted) {
                            ToastService().showToast(
                              context,
                              'Failed to update profile details',
                              type: ToastType.error,
                            );
                          }
                        } catch (e) {
                          if (context.mounted)
                            ToastService().showToast(
                              context,
                              'An error occurred: $e',
                              type: ToastType.error,
                            );
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
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
