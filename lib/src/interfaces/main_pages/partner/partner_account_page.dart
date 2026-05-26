import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
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
import 'add_branch_page.dart';
import '../../components/map_location_picker_page.dart';
import '../../components/confirmation_dialog.dart';
import '../../components/full_screen_gallery.dart';
import '../../components/operating_hours_editor.dart';

class PartnerAccountPage extends ConsumerStatefulWidget {
  final bool isEditMode;
  const PartnerAccountPage({super.key, this.isEditMode = false});

  @override
  ConsumerState<PartnerAccountPage> createState() => _PartnerAccountPageState();
}

class _PartnerAccountPageState extends ConsumerState<PartnerAccountPage> {
  late bool isEditMode;
  File? _profileImage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey _shopNameKey = GlobalKey();
  final GlobalKey _contactNumKey = GlobalKey();
  final GlobalKey _shopAddressKey = GlobalKey();
  final GlobalKey _pincodeKey = GlobalKey();

  late TextEditingController _ownerNameCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _emailCtrl;

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
  List<String> _tags = [];
  List<BusinessBranch> _branches = [];
  List<String> _businessImages = [];
  OperatingHours? _operatingHours;

  File? _pickedLogo;
  File? _pickedCover;
  List<File> _pickedGallery = [];

  bool _deletedCover = false;
  bool _deletedLogo = false;

  bool _isLoading = false;

  bool _isAddingTag = false;
  final TextEditingController _tagInputCtrl = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();

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
      text:
          (partner?.businessInfo?.storeLocation?.coordinates != null &&
              partner!.businessInfo!.storeLocation!.coordinates!.length >= 2)
          ? 'Location Selected'
          : 'Not Selected',
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
    _tags = List.from(partner?.tags ?? []);
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
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerPage(
          initialLat: _lat,
          initialLng: _lng,
          initialLocalBody: null,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _lat = result['lat'] as double;
        _lng = result['lng'] as double;
        _mapLocationCtrl.text = 'Location Selected';
      });
    }
  }

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();

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
    _tagInputCtrl.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(String field) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (field == 'gallery' &&
        (_businessImages.length + _pickedGallery.length) >= 10) {
      ToastService().showToast(
        context,
        'Maximum limit of 10 images reached',
        type: ToastType.warning,
      );
      return;
    }

    final result = await img_service.pickMedia(
      context: context,
      allowMultiple: field == 'gallery',
      enableCrop: field != 'gallery',
      cropRatio: field == 'logo'
          ? const CropAspectRatio(ratioX: 1, ratioY: 1)
          : field == 'cover'
          ? const CropAspectRatio(ratioX: 16, ratioY: 9)
          : null,
      showDocument: false,
    );

    if (result is XFile) {
      File originalFile = File(result.path);
      File compressedFile = await img_service.compressImageIfNeeded(
        originalFile,
      );

      setState(() {
        if (field == 'logo') {
          _pickedLogo = compressedFile;
          _profileImage = _pickedLogo;
          _deletedLogo = false;
        } else if (field == 'cover') {
          _pickedCover = compressedFile;
          _deletedCover = false;
        } else {
          _pickedGallery.add(compressedFile);
        }
      });
    } else if (result is List<XFile>) {
      // Handle multiple images for gallery
      final currentTotal = _businessImages.length + _pickedGallery.length;
      final availableSlots = 10 - currentTotal;

      if (result.length > availableSlots) {
        ToastService().showToast(
          context,
          'Only $availableSlots more image(s) can be added',
          type: ToastType.warning,
        );
      }

      final imagesToAdd = result.take(availableSlots).toList();

      for (final xFile in imagesToAdd) {
        File originalFile = File(xFile.path);
        File compressedFile = await img_service.compressImageIfNeeded(
          originalFile,
        );
        setState(() {
          _pickedGallery.add(compressedFile);
        });
      }
    }
  }

  void _showCategoryPicker() async {
    FocusManager.instance.primaryFocus?.unfocus();
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

  void _showAddSpecialtyDialog() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await showAddSpecialtyDialog(context);
    if (result != null && mounted) {
      setState(() => _specialties.add(result));
    }
  }

  void _showAddBranchDialog() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBranchPage()),
    );
    if (result != null && mounted) {
      setState(() => _branches.add(result));
    }
  }

  void _editBranch(int index, BusinessBranch branch) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBranchPage(initialBranch: branch),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _branches[index] = result;
      });
    }
  }

  void _submitTag() {
    final val = _tagInputCtrl.text.trim();
    if (val.isNotEmpty) {
      if (!_tags.contains(val)) {
        setState(() {
          _tags.add(val);
          _tagInputCtrl.clear();
        });
        _tagFocusNode.requestFocus();
      } else {
        ToastService().showToast(
          context,
          'Tag already added',
          type: ToastType.warning,
        );
        _tagInputCtrl.clear();
      }
    } else {
      setState(() {
        _isAddingTag = false;
        _tagInputCtrl.clear();
      });
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
                    child: Form(
                      key: _formKey,
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
                                          : (!_deletedCover &&
                                                partner
                                                        ?.businessInfo
                                                        ?.coverImage !=
                                                    null)
                                          ? AdvancedNetworkImage(
                                              imageUrl: partner!
                                                  .businessInfo!
                                                  .coverImage!,
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
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
                                    if (isEditMode &&
                                        (_pickedCover != null ||
                                            (!_deletedCover &&
                                                partner
                                                        ?.businessInfo
                                                        ?.coverImage !=
                                                    null)))
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () async {
                                            final confirm =
                                                await showConfirmationDialog(
                                                  context: context,
                                                  title: 'Delete Cover',
                                                  message:
                                                      'Are you sure you want to delete the cover image?',
                                                  isDestructive: true,
                                                  confirmText: 'Delete',
                                                );
                                            if (confirm == true) {
                                              setState(() {
                                                _pickedCover = null;
                                                _deletedCover = true;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: Colors.red.shade600,
                                            ),
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
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            kPrimaryColor.withOpacity(0.1),
                                            kPrimaryLightColor.withOpacity(0.2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: kPrimaryColor.withOpacity(0.2),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: kPrimaryColor.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: _profileImage != null
                                            ? Image.file(
                                                _profileImage!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.error,
                                                      color: Colors.red,
                                                    ),
                                              )
                                            : (!_deletedLogo &&
                                                  partner
                                                          ?.businessInfo
                                                          ?.businessLogo !=
                                                      null)
                                            ? AdvancedNetworkImage(
                                                imageUrl: partner!
                                                    .businessInfo!
                                                    .businessLogo!,
                                                fit: BoxFit.cover,
                                              )
                                            : Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.store_outlined,
                                                      size: 32,
                                                      color: kPrimaryColor
                                                          .withOpacity(0.5),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      partner
                                                              ?.businessDetails
                                                              ?.businessName
                                                              ?.substring(0, 2)
                                                              .toUpperCase() ??
                                                          'NA',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: kPrimaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ),
                                    if (isEditMode &&
                                        (_profileImage != null ||
                                            (!_deletedLogo &&
                                                partner
                                                        ?.businessInfo
                                                        ?.businessLogo !=
                                                    null)))
                                      Positioned(
                                        top: -8,
                                        right: -8,
                                        child: GestureDetector(
                                          onTap: () async {
                                            final confirm =
                                                await showConfirmationDialog(
                                                  context: context,
                                                  title: 'Delete Logo',
                                                  message:
                                                      'Are you sure you want to delete the business logo?',
                                                  isDestructive: true,
                                                  confirmText: 'Delete',
                                                );
                                            if (confirm == true) {
                                              setState(() {
                                                _profileImage = null;
                                                _pickedLogo = null;
                                                _deletedLogo = true;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade500,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (isEditMode)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: kPrimaryLightColor.withOpacity(
                                        0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () =>
                                            _pickAndUploadImage('logo'),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.camera_alt_outlined,
                                                size: 18,
                                                color: kPrimaryColor,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                (_profileImage != null ||
                                                        (!_deletedLogo &&
                                                            partner
                                                                    ?.businessInfo
                                                                    ?.businessLogo !=
                                                                null))
                                                    ? 'Change Logo'
                                                    : 'Upload Logo',
                                                style: kSmallTitleM.copyWith(
                                                  color: kPrimaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),

                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          (partner?.businessInfo?.rating ?? 0.0)
                                              .toStringAsFixed(1),
                                          style: kBodyTitleM.copyWith(
                                            color: Color(0xFF4E4E4E),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.star,
                                          size: 20,
                                          color: Color(0xFFFFCB2B),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'out of 5',
                                          style: kSmallerTitleL.copyWith(
                                            color: Color(0xFF4E4E4E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenSize.responsivePadding(32)),

                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
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
                                  indent: 16,
                                  endIndent: 16,
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
                                ] else ...[
                                  _buildReadOnlyRow(
                                    'Mobile Number',
                                    _mobileCtrl.text,
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
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
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
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                if (isEditMode) ...[
                                  Padding(
                                    key: _shopNameKey,
                                    padding: const EdgeInsets.all(16),
                                    child: PrimaryTextField(
                                      label: 'Shop Name',
                                      controller: _shopNameCtrl,
                                      isRequired: true,
                                      validator: (val) =>
                                          (val == null || val.trim().isEmpty)
                                          ? 'Shop Name is required'
                                          : null,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: PrimaryTextField(
                                      label: 'Category',
                                      controller: _categoryCtrl,
                                      readOnly: true,
                                      onTap: _showCategoryPicker,
                                      suffixIcon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFF808080),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    key: _contactNumKey,
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: 'Contact Number',
                                            style: kSmallTitleM.copyWith(
                                              color: const Color(0xFF373737),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            children: const [
                                              TextSpan(
                                                text: ' *',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        IntlPhoneField(
                                          disableLengthCheck: false,
                                          initialCountryCode: 'IN',
                                          flagsButtonMargin: EdgeInsets.zero,
                                          flagsButtonPadding: EdgeInsets.zero,
                                          decoration: InputDecoration(
                                            hintText: 'Enter contact number',
                                            hintStyle: kSmallTitleL.copyWith(
                                              color: kGrey,
                                              letterSpacing: .1,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF5F5F5),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 13,
                                                ),
                                            counterText: '',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: kPrimaryColor,
                                                width: 1.5,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 1.5,
                                                  ),
                                                ),
                                          ),
                                          initialValue: _contactNumCtrl.text,
                                          onChanged: (phone) {
                                            _contactNumCtrl.text =
                                                phone.completeNumber;
                                          },
                                          validator: (phone) {
                                            if (phone == null ||
                                                phone.number.trim().isEmpty) {
                                              return 'Contact Number is required';
                                            }
                                            if (phone.number.trim().length <
                                                10) {
                                              return 'Contact Number must be at least 10 digits';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'WhatsApp Number',
                                          style: kSmallTitleM.copyWith(
                                            color: const Color(0xFF373737),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        IntlPhoneField(
                                          disableLengthCheck: false,
                                          initialCountryCode: 'IN',
                                          flagsButtonMargin: EdgeInsets.zero,
                                          flagsButtonPadding: EdgeInsets.zero,
                                          decoration: InputDecoration(
                                            hintText: 'Enter WhatsApp number',
                                            hintStyle: kSmallTitleL.copyWith(
                                              color: kGrey,
                                              letterSpacing: .1,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF5F5F5),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 13,
                                                ),
                                            counterText: '',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: kPrimaryColor,
                                                width: 1.5,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 1.5,
                                                  ),
                                                ),
                                          ),
                                          initialValue: _whatsappCtrl.text,
                                          onChanged: (phone) {
                                            _whatsappCtrl.text =
                                                phone.completeNumber;
                                          },
                                          validator: (phone) {
                                            // WhatsApp is optional, but if provided, validate it
                                            if (phone != null &&
                                                phone.number
                                                    .trim()
                                                    .isNotEmpty) {
                                              if (phone.number.trim().length <
                                                  10) {
                                                return 'WhatsApp Number must be at least 10 digits';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    key: _shopAddressKey,
                                    padding: const EdgeInsets.all(16),
                                    child: PrimaryTextField(
                                      label: 'Shop Address',
                                      controller: _shopAddressCtrl,
                                      isRequired: true,
                                      validator: (val) =>
                                          (val == null || val.trim().isEmpty)
                                          ? 'Shop Address is required'
                                          : null,
                                    ),
                                  ),
                                  Padding(
                                    key: _pincodeKey,
                                    padding: const EdgeInsets.all(16),
                                    child: PrimaryTextField(
                                      label: 'Pincode',
                                      controller: _pincodeCtrl,
                                      isRequired: true,
                                      validator: (val) =>
                                          (val == null || val.trim().isEmpty)
                                          ? 'Pincode is required'
                                          : null,
                                    ),
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
                                  _buildReadOnlyRow(
                                    'Category',
                                    _categoryCtrl.text,
                                  ),
                                  _buildReadOnlyRow(
                                    'Contact Number',
                                    _contactNumCtrl.text,
                                  ),
                                  _buildReadOnlyRow(
                                    'WhatsApp Number',
                                    _whatsappCtrl.text,
                                  ),
                                  _buildReadOnlyRow(
                                    'PAN Number',
                                    _panCtrl.text,
                                  ),
                                  _buildReadOnlyRow(
                                    'Shop Address',
                                    _shopAddressCtrl.text,
                                  ),
                                  _buildReadOnlyRow(
                                    'Pincode',
                                    _pincodeCtrl.text,
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
                                  child: Column(
                                    children: [
                                      if (_branches.isEmpty)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 24,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF9FAFB),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'No branches added',
                                              style: kSmallTitleL.copyWith(
                                                color: const Color(0xFF6B7280),
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        ..._branches.asMap().entries.map((
                                          entry,
                                        ) {
                                          final index = entry.key;
                                          final branch = entry.value;
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: kWhite,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFE5E7EB),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.02),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  kPrimaryLightColor,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .store_mall_directory_outlined,
                                                              color:
                                                                  kPrimaryColor,
                                                              size: 20,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              branch.name ??
                                                                  'Branch',
                                                              style: kBodyTitleM.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    const Color(
                                                                      0xFF111827,
                                                                    ),
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            branch.isActive ==
                                                                true
                                                            ? const Color(
                                                                0xFFDEF7EC,
                                                              )
                                                            : const Color(
                                                                0xFFFDE8E8,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        branch.isActive == true
                                                            ? 'Active'
                                                            : 'Inactive',
                                                        style: kSmallTitleL.copyWith(
                                                          color:
                                                              branch.isActive ==
                                                                  true
                                                              ? const Color(
                                                                  0xFF03543F,
                                                                )
                                                              : const Color(
                                                                  0xFF9B1C1C,
                                                                ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (branch
                                                        .address
                                                        ?.isNotEmpty ==
                                                    true) ...[
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        size: 16,
                                                        color: Color(
                                                          0xFF6B7280,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          branch.address!,
                                                          style: kSmallTitleM
                                                              .copyWith(
                                                                color:
                                                                    const Color(
                                                                      0xFF4B5563,
                                                                    ),
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                if (branch.phone?.isNotEmpty ==
                                                    true) ...[
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.phone_outlined,
                                                        size: 16,
                                                        color: Color(
                                                          0xFF6B7280,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          branch.phone!,
                                                          style: kSmallTitleM
                                                              .copyWith(
                                                                color:
                                                                    const Color(
                                                                      0xFF4B5563,
                                                                    ),
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                if (isEditMode) ...[
                                                  const SizedBox(height: 16),
                                                  const Divider(
                                                    height: 1,
                                                    color: Color(0xFFF3F4F6),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () =>
                                                            _editBranch(
                                                              index,
                                                              branch,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .edit_outlined,
                                                              size: 16,
                                                              color:
                                                                  kPrimaryColor,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              'Edit',
                                                              style: kSmallTitleM
                                                                  .copyWith(
                                                                    color:
                                                                        kPrimaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 24),
                                                      GestureDetector(
                                                        onTap: () => setState(
                                                          () => _branches
                                                              .removeAt(index),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              size: 16,
                                                              color: Colors.red,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              'Delete',
                                                              style: kSmallTitleM
                                                                  .copyWith(
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          );
                                        }),
                                    ],
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
                                  'Tags',
                                  showAdd: !_isAddingTag,
                                  onAdd: () {
                                    setState(() => _isAddingTag = true);
                                    _tagFocusNode.requestFocus();
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeOutBack,
                                        child: _isAddingTag && isEditMode
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 16,
                                                ),
                                                child: PrimaryTextField(
                                                  label: 'New Tag',
                                                  controller: _tagInputCtrl,
                                                  focusNode: _tagFocusNode,
                                                  hint:
                                                      'Type and press space to add...',
                                                  onChanged: (val) {
                                                    if (val.endsWith(' ')) {
                                                      _submitTag();
                                                    }
                                                  },
                                                  onSubmitted: (val) =>
                                                      _submitTag(),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            ..._tags.map(
                                              (t) => AnimatedScale(
                                                scale: 1.0,
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                child: _buildRemovableChip(
                                                  t,
                                                  onDelete: () => setState(
                                                    () => _tags.remove(t),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (_tags.isEmpty && !_isAddingTag)
                                              Text(
                                                'No tags added',
                                                style: kSmallTitleL.copyWith(
                                                  color: kGrey,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
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
                                          validator: (val) {
                                            if (val != null &&
                                                val.trim().isNotEmpty) {
                                              final urlPattern = RegExp(
                                                r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
                                              );
                                              if (!urlPattern.hasMatch(
                                                val.trim(),
                                              )) {
                                                return 'Please enter a valid URL (e.g., https://instagram.com/username)';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        PrimaryTextField(
                                          label: 'Facebook',
                                          controller: _facebookCtrl,
                                          hint: 'Facebook Profile Link',
                                          validator: (val) {
                                            if (val != null &&
                                                val.trim().isNotEmpty) {
                                              final urlPattern = RegExp(
                                                r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
                                              );
                                              if (!urlPattern.hasMatch(
                                                val.trim(),
                                              )) {
                                                return 'Please enter a valid URL (e.g., https://facebook.com/page)';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        PrimaryTextField(
                                          label: 'YouTube',
                                          controller: _youtubeCtrl,
                                          hint: 'YouTube Channel Link',
                                          validator: (val) {
                                            if (val != null &&
                                                val.trim().isNotEmpty) {
                                              final urlPattern = RegExp(
                                                r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
                                              );
                                              if (!urlPattern.hasMatch(
                                                val.trim(),
                                              )) {
                                                return 'Please enter a valid URL (e.g., https://youtube.com/channel)';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        PrimaryTextField(
                                          label: 'Website',
                                          controller: _websiteUrlCtrl,
                                          hint: 'Business Website URL',
                                          validator: (val) {
                                            if (val != null &&
                                                val.trim().isNotEmpty) {
                                              final urlPattern = RegExp(
                                                r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
                                              );
                                              if (!urlPattern.hasMatch(
                                                val.trim(),
                                              )) {
                                                return 'Please enter a valid URL (e.g., https://example.com)';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                      ] else ...[
                                        if (_instagramCtrl.text.isNotEmpty)
                                          _buildReadOnlyRow(
                                            'Instagram',
                                            _instagramCtrl.text,
                                            prefixIcon: SvgPicture.asset(
                                              'assets/svg/instagram.svg',
                                              width: 16,
                                              height: 16,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    Color(0xFFE4405F),
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                          ),
                                        if (_facebookCtrl.text.isNotEmpty)
                                          _buildReadOnlyRow(
                                            'Facebook',
                                            _facebookCtrl.text,
                                            prefixIcon: SvgPicture.asset(
                                              'assets/svg/facebook.svg',
                                              width: 16,
                                              height: 16,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    Color(0xFF1877F2),
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                          ),
                                        if (_youtubeCtrl.text.isNotEmpty)
                                          _buildReadOnlyRow(
                                            'YouTube',
                                            _youtubeCtrl.text,
                                            prefixIcon: SvgPicture.asset(
                                              'assets/svg/youtube.svg',
                                              width: 16,
                                              height: 16,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    Color(0xFFFF0000),
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                          ),
                                        if (_websiteUrlCtrl.text.isNotEmpty)
                                          _buildReadOnlyRow(
                                            'Website',
                                            _websiteUrlCtrl.text,
                                            prefixIcon: SvgPicture.asset(
                                              'assets/svg/website.svg',
                                              width: 16,
                                              height: 16,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    Color(0xFF4285F4),
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Shop Images',
                                            style: kSmallTitleM.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: kBlack,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF3F4F6,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  child: FractionallySizedBox(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    widthFactor:
                                                        ((_businessImages
                                                                        .length +
                                                                    _pickedGallery
                                                                        .length) /
                                                                10.0)
                                                            .clamp(0.0, 1.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors:
                                                              (_businessImages
                                                                          .length +
                                                                      _pickedGallery
                                                                          .length >=
                                                                  10)
                                                              ? [
                                                                  Colors
                                                                      .red
                                                                      .shade400,
                                                                  Colors
                                                                      .red
                                                                      .shade600,
                                                                ]
                                                              : [
                                                                  kPrimaryLightColor,
                                                                  kPrimaryColor,
                                                                ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${_businessImages.length + _pickedGallery.length}/10',
                                                style: kSmallTitleL.copyWith(
                                                  color:
                                                      (_businessImages.length +
                                                              _pickedGallery
                                                                  .length >=
                                                          10)
                                                      ? Colors.red.shade600
                                                      : const Color(0xFF6B7280),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (isEditMode)
                                        GestureDetector(
                                          onTap: () {
                                            if (_businessImages.length +
                                                    _pickedGallery.length >=
                                                10) {
                                              ToastService().showToast(
                                                context,
                                                'Maximum limit of 10 images reached',
                                                type: ToastType.warning,
                                              );
                                            } else {
                                              _pickAndUploadImage('gallery');
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (_businessImages.length +
                                                          _pickedGallery
                                                              .length >=
                                                      10)
                                                  ? const Color(0xFFF3F4F6)
                                                  : kPrimaryColor.withOpacity(
                                                      0.1,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color:
                                                    (_businessImages.length +
                                                            _pickedGallery
                                                                .length >=
                                                        10)
                                                    ? Colors.transparent
                                                    : kPrimaryColor.withOpacity(
                                                        0.2,
                                                      ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .add_photo_alternate_outlined,
                                                  size: 16,
                                                  color:
                                                      (_businessImages.length +
                                                              _pickedGallery
                                                                  .length >=
                                                          10)
                                                      ? const Color(0xFF9CA3AF)
                                                      : kPrimaryColor,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Add',
                                                  style: kSmallTitleL.copyWith(
                                                    color:
                                                        (_businessImages
                                                                    .length +
                                                                _pickedGallery
                                                                    .length >=
                                                            10)
                                                        ? const Color(
                                                            0xFF9CA3AF,
                                                          )
                                                        : kPrimaryColor,
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
                                const SizedBox(height: 12),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFF3F4F6),
                                ),
                                const SizedBox(height: 16),
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
                                            if (!isEditMode)
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    PageRouteBuilder(
                                                      opaque: false,
                                                      pageBuilder: (context, _, __) {
                                                        return FullScreenGallery(
                                                          images:
                                                              _businessImages,
                                                          initialIndex:
                                                              entry.key,
                                                        );
                                                      },
                                                      transitionsBuilder:
                                                          (
                                                            context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child,
                                                          ) {
                                                            return FadeTransition(
                                                              opacity:
                                                                  animation,
                                                              child: child,
                                                            );
                                                          },
                                                    ),
                                                  );
                                                },
                                                child: Hero(
                                                  tag:
                                                      'gallery_image_${entry.value}_${entry.key}',
                                                  child: _buildShopImage(
                                                    imageUrl: entry.value,
                                                  ),
                                                ),
                                              )
                                            else
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
                                                            .removeAt(
                                                              entry.key,
                                                            ),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Colors.red,
                                                          shape:
                                                              BoxShape.circle,
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
                                      if (isEditMode)
                                        GestureDetector(
                                          onTap: () =>
                                              _pickAndUploadImage('gallery'),
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: isEditMode
                                          ? const Color(0xFFFFF7F7)
                                          : Colors.transparent,
                                    ),
                                    child: Column(
                                      children: [
                                        OperatingHoursEditor(
                                          operatingHours: _operatingHours,
                                          isEditMode: isEditMode,
                                          onChanged: (newHours) {
                                            setState(() {
                                              _operatingHours = newHours;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
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
                        // Unfocus current field to apply any pending changes
                        FocusScope.of(context).unfocus();

                        // Validate the form (this triggers the red error text)
                        bool isValid =
                            _formKey.currentState?.validate() ?? true;

                        if (!isValid) {
                          // Scroll to the first error
                          if (_shopNameCtrl.text.trim().isEmpty) {
                            Scrollable.ensureVisible(
                              _shopNameKey.currentContext!,
                              duration: const Duration(milliseconds: 300),
                              alignment: 0.1,
                            );
                          } else if (_contactNumCtrl.text.trim().isEmpty) {
                            Scrollable.ensureVisible(
                              _contactNumKey.currentContext!,
                              duration: const Duration(milliseconds: 300),
                              alignment: 0.1,
                            );
                          } else if (_shopAddressCtrl.text.trim().isEmpty) {
                            Scrollable.ensureVisible(
                              _shopAddressKey.currentContext!,
                              duration: const Duration(milliseconds: 300),
                              alignment: 0.1,
                            );
                          } else if (_pincodeCtrl.text.trim().isEmpty) {
                            Scrollable.ensureVisible(
                              _pincodeKey.currentContext!,
                              duration: const Duration(milliseconds: 300),
                              alignment: 0.1,
                            );
                          }
                          return;
                        }

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
                            businessLogo: _deletedLogo
                                ? null
                                : currentPartner.businessInfo?.businessLogo,
                            coverImage: _deletedCover
                                ? null
                                : currentPartner.businessInfo?.coverImage,
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
                                  )
                                : currentPartner.businessInfo?.storeLocation,
                            operatingHours: _operatingHours,
                          ),
                          serviceCategories: currentPartner.serviceCategories,
                          coverageAreas: currentPartner.coverageAreas,
                          tags: _tags,
                          isActive: currentPartner.isActive,
                          isFeatured: currentPartner.isFeatured,
                          verificationStatus: currentPartner.verificationStatus,
                          createdAt: currentPartner.createdAt,
                          updatedAt: DateTime.now(),
                        );

                        setState(() => _isLoading = true);

                        try {
                          final notifier = ref.read(partnerProvider.notifier);

                          // Prepare all files in a single list with proper field names
                          List<http.MultipartFile> allFiles = [];

                          // Add logo file with 'logo' field name
                          if (_pickedLogo != null) {
                            final logoFile = await http.MultipartFile.fromPath(
                              'logo', // Changed from 'images' to 'logo'
                              _pickedLogo!.path,
                              contentType: MediaType.parse(
                                lookupMimeType(_pickedLogo!.path) ??
                                    'image/jpeg',
                              ),
                            );
                            allFiles.add(logoFile);
                          }

                          // Add cover file with 'cover' field name
                          if (_pickedCover != null) {
                            final coverFile = await http.MultipartFile.fromPath(
                              'cover', // Changed from 'images' to 'cover'
                              _pickedCover!.path,
                              contentType: MediaType.parse(
                                lookupMimeType(_pickedCover!.path) ??
                                    'image/jpeg',
                              ),
                            );
                            allFiles.add(coverFile);
                          }

                          // Add gallery files with 'gallery' field name
                          if (_pickedGallery.isNotEmpty) {
                            final galleryFiles = await Future.wait(
                              _pickedGallery.map(
                                (f) => http.MultipartFile.fromPath(
                                  'gallery', // Changed from 'images' to 'gallery'
                                  f.path,
                                  contentType: MediaType.parse(
                                    lookupMimeType(f.path) ?? 'image/jpeg',
                                  ),
                                ),
                              ),
                            );
                            allFiles.addAll(galleryFiles);
                          }

                          final success = await notifier.updateProfile(
                            updatedPartner,
                            files: allFiles.isNotEmpty ? allFiles : null,
                            deleteLogo: _deletedLogo,
                            deleteCover: _deletedCover,
                          );

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
                          if (context.mounted) {
                            ToastService().showToast(
                              context,
                              'An error occurred: $e',
                              type: ToastType.error,
                            );
                          }
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
