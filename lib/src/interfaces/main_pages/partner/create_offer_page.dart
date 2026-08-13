import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../components/animated_dropdown.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/branches.dart';
import '../../../data/services/image_services.dart' as img_service;
import '../../../data/services/toast_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/partner_provider.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/providers/offers_provider.dart';
import '../../../data/utils/map_utils.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/offer_metadata_providers.dart';
import '../../../data/models/business_info.dart';

class CreateOfferPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? offer;

  const CreateOfferPage({super.key, this.offer});

  @override
  ConsumerState<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends ConsumerState<CreateOfferPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _minDiscountController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _bgBuyQtyController;
  late TextEditingController _bgGetDescController;
  late TextEditingController _dnpDiscountController;
  late TextEditingController _comboDescController;
  late TextEditingController _ldMinPurchaseController;
  late TextEditingController _ldPrizeDescController;
  late TextEditingController _loPurchaseCountController;
  late TextEditingController _loFreeItemDescController;
  late TextEditingController _csDiscountController;
  late TextEditingController _ltoMessageController;
  late TextEditingController _rcCouponCodeController;
  late TextEditingController _tagsController;
  List<String> _tags = [];
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _validFromController;
  late TextEditingController _validToController;
  final List<TextEditingController> _termControllers = [];
  late TextEditingController _maxTotalRedemptionsController;
  late TextEditingController _maxPerUserController;
  late TextEditingController _minPurchaseAmountController;

  String _discountType = 'percentage';
  bool _isScratchCard = false;

  String _branchApplicabilityType = 'all';
  List<String> _selectedBranchIds = [];
  DateTime? _validFrom;
  DateTime? _validTo;

  List<File> _pickedImages = [];
  bool _isLoading = false;
  bool _isActive = true;

  String? _selectedSubcategory;
  List<String> _selectedSubcategories = [];
  TierModel? _selectedTier;
  String? _selectedOfferTypeCode;

  String? _selectedDealType;
  bool _isDealActive = false;
  DateTime? _dealStartDate;
  TimeOfDay? _dealStartTime;
  DateTime? _dealExpiryDate;
  TimeOfDay? _dealExpiryTime;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(branchesProvider.notifier).getBranches();
    });

    _titleController = TextEditingController(text: widget.offer?['title']);
    _descController = TextEditingController(text: widget.offer?['description']);

    final branchApp = widget.offer?['branchApplicability'];
    if (branchApp is Map) {
      _branchApplicabilityType = branchApp['type'] ?? 'all';
      final ids = branchApp['branchIds'];
      if (ids is List) {
        _selectedBranchIds = ids.map((e) => e.toString()).toList();
      }
    }

    _selectedSubcategory = widget.offer?['subcategory'] as String?;
    final initialSubs = widget.offer?['subcategories'];
    if (initialSubs is List) {
      _selectedSubcategories = initialSubs.map((e) => e.toString()).toList();
    } else if (_selectedSubcategory != null && _selectedSubcategory!.isNotEmpty) {
      _selectedSubcategories = [_selectedSubcategory!];
    }
    _selectedOfferTypeCode = widget.offer?['offerTypeCode'] as String?;

    final requiredTierData = widget.offer?['requiredTier'];
    if (requiredTierData != null) {
      if (requiredTierData is Map) {
        _selectedTier = TierModel.fromJson(
          Map<String, dynamic>.from(requiredTierData),
        );
      } else if (requiredTierData is TierModel) {
        _selectedTier = requiredTierData;
      }
    }

    _discountType = widget.offer?['discountType'] as String? ?? 'percentage';
    _isScratchCard = widget.offer?['isScratchCard'] == true || widget.offer?['isScratchCard'] == 'true';

    _minDiscountController = TextEditingController(
      text: widget.offer?['discountRange']?['min']?.toString(),
    );
    _maxDiscountController = TextEditingController(
      text: widget.offer?['discountRange']?['max']?.toString(),
    );

    final meta = widget.offer?['offerMetadata'];
    _bgBuyQtyController = TextEditingController(
      text: meta != null && meta['buyQuantity'] != null
          ? meta['buyQuantity'].toString()
          : '',
    );
    _bgGetDescController = TextEditingController(
      text: meta != null && meta['getDescription'] != null
          ? meta['getDescription'].toString()
          : '',
    );
    _dnpDiscountController = TextEditingController(
      text: meta != null && meta['nextPurchaseDiscount'] != null
          ? meta['nextPurchaseDiscount'].toString()
          : '',
    );
    _comboDescController = TextEditingController(
      text: meta != null && meta['comboDescription'] != null
          ? meta['comboDescription'].toString()
          : '',
    );
    _ldMinPurchaseController = TextEditingController(
      text: meta != null && meta['minPurchaseLimit'] != null
          ? meta['minPurchaseLimit'].toString()
          : '',
    );
    _ldPrizeDescController = TextEditingController(
      text: meta != null && meta['prizeDescription'] != null
          ? meta['prizeDescription'].toString()
          : '',
    );
    _loPurchaseCountController = TextEditingController(
      text: meta != null && meta['purchaseCount'] != null
          ? meta['purchaseCount'].toString()
          : '',
    );
    _loFreeItemDescController = TextEditingController(
      text: meta != null && meta['freeItemDescription'] != null
          ? meta['freeItemDescription'].toString()
          : '',
    );
    _csDiscountController = TextEditingController(
      text: meta != null && meta['clearanceDiscount'] != null
          ? meta['clearanceDiscount'].toString()
          : '',
    );
    _ltoMessageController = TextEditingController(
      text: meta != null && meta['timeLimitedMessage'] != null
          ? meta['timeLimitedMessage'].toString()
          : 'Hurry! Limited time offer!',
    );
    _rcCouponCodeController = TextEditingController(
      text: meta != null && meta['couponCode'] != null
          ? meta['couponCode'].toString()
          : '',
    );

    final dealObj = widget.offer?['deal'];
    if (dealObj is Map) {
      _selectedDealType = dealObj['type'] as String?;
      _isDealActive = dealObj['isActive'] == true || dealObj['isActive'] == 'true';
      final sDate = dealObj['startDate'];
      if (sDate != null && sDate.toString().isNotEmpty) {
        final dt = DateTime.tryParse(sDate.toString())?.toLocal();
        if (dt != null) {
          _dealStartDate = dt;
          _dealStartTime = TimeOfDay.fromDateTime(dt);
        }
      }
      final eDate = dealObj['expiryDate'];
      if (eDate != null && eDate.toString().isNotEmpty) {
        final dt = DateTime.tryParse(eDate.toString())?.toLocal();
        if (dt != null) {
          _dealExpiryDate = dt;
          _dealExpiryTime = TimeOfDay.fromDateTime(dt);
        }
      }
    }

    _tagsController = TextEditingController();
    final initialTags = widget.offer?['tags'];
    if (initialTags is List) {
      _tags = initialTags.map((e) => e.toString()).toList();
    }

    _minPriceController = TextEditingController(
      text: widget.offer?['priceRange']?['min']?.toString(),
    );
    _maxPriceController = TextEditingController(
      text: widget.offer?['priceRange']?['max']?.toString(),
    );

    if (widget.offer?['validFrom'] != null) {
      _validFrom = DateTime.tryParse(widget.offer!['validFrom'])?.toLocal();
      if (_validFrom != null) {
        _validFromController = TextEditingController(
          text: DateFormat('dd MMM, yyyy').format(_validFrom!),
        );
      } else {
        _validFromController = TextEditingController();
      }
    } else {
      _validFromController = TextEditingController();
    }

    if (widget.offer?['validTo'] != null) {
      _validTo = DateTime.tryParse(widget.offer!['validTo'])?.toLocal();
      if (_validTo != null) {
        _validToController = TextEditingController(
          text: DateFormat('dd MMM, yyyy').format(_validTo!),
        );
      } else {
        _validToController = TextEditingController();
      }
    } else {
      _validToController = TextEditingController();
    }

    _isActive = widget.offer?['isActive'] ?? true;

    if (widget.offer?['terms'] != null) {
      final terms = widget.offer!['terms'] as List;
      for (final term in terms) {
        _termControllers.add(TextEditingController(text: term.toString()));
      }
    }

    final rules = widget.offer?['redemptionRules'];
    String maxTotalRedemptions = '';
    String maxPerUser = '';
    String minPurchaseAmount = '';
    if (rules is Map) {
      maxTotalRedemptions = rules['maxTotalRedemptions']?.toString() ?? '';
      maxPerUser = rules['maxPerUser']?.toString() ?? '';
      minPurchaseAmount = rules['minPurchaseAmount']?.toString() ?? '';
    } else if (rules != null) {
      try {
        maxTotalRedemptions = (rules as dynamic).maxTotalRedemptions?.toString() ?? '';
        maxPerUser = (rules as dynamic).maxPerUser?.toString() ?? '';
        minPurchaseAmount = (rules as dynamic).minPurchaseAmount?.toString() ?? '';
      } catch (e) { print('Offer Error: $e'); }
    }

    _maxTotalRedemptionsController = TextEditingController(text: maxTotalRedemptions);
    _maxPerUserController = TextEditingController(text: maxPerUser);
    _minPurchaseAmountController = TextEditingController(text: minPurchaseAmount);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _minDiscountController.dispose();
    _maxDiscountController.dispose();
    _bgBuyQtyController.dispose();
    _bgGetDescController.dispose();
    _dnpDiscountController.dispose();
    _comboDescController.dispose();
    _ldMinPurchaseController.dispose();
    _ldPrizeDescController.dispose();
    _loPurchaseCountController.dispose();
    _loFreeItemDescController.dispose();
    _csDiscountController.dispose();
    _ltoMessageController.dispose();
    _rcCouponCodeController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _validFromController.dispose();
    _validToController.dispose();
    _maxTotalRedemptionsController.dispose();
    _maxPerUserController.dispose();
    _minPurchaseAmountController.dispose();
    for (final controller in _termControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_pickedImages.length >= 5) {
      ToastService().showToast(
        context,
        'Maximum limit of 5 images reached',
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

    if (result is List<XFile>) {
      final remaining = 5 - _pickedImages.length;
      if (result.length > remaining) {
        ToastService().showToast(
          context,
          'Only $remaining more image(s) can be added',
          type: ToastType.warning,
        );
      }

      List<File> newFiles = result
          .take(remaining)
          .map((e) => File(e.path))
          .toList();
      for (int i = 0; i < newFiles.length; i++) {
        newFiles[i] = await img_service.compressImageIfNeeded(newFiles[i]);
      }
      setState(() {
        _pickedImages.addAll(newFiles);
      });
    } else if (result is XFile) {
      if (_pickedImages.length < 5) {
        File compressedFile = await img_service.compressImageIfNeeded(
          File(result.path),
        );
        setState(() {
          _pickedImages.add(compressedFile);
        });
      }
    }
  }

  void _addTerm() {
    setState(() {
      _termControllers.add(TextEditingController());
    });
  }

  void _removeTerm(int index) {
    setState(() {
      _termControllers[index].dispose();
      _termControllers.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isValidFrom) async {
    FocusManager.instance.primaryFocus?.unfocus();
    DateTime initialDate =
        (isValidFrom ? _validFrom : _validTo) ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isValidFrom ? 'Offer Start Date' : 'Offer End Date',
                    style: kSmallTitleB.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: kTextColor),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: kPrimaryColor,
                    onPrimary: kWhite,
                    onSurface: kTextColor,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: initialDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 0)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (date) {
                    setState(() {
                      if (isValidFrom) {
                        _validFrom = date;
                        _validFromController.text = DateFormat(
                          'dd MMM, yyyy',
                        ).format(date);
                      } else {
                        _validTo = date;
                        _validToController.text = DateFormat(
                          'dd MMM, yyyy',
                        ).format(date);
                      }
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                onPressed: () {
                  if (isValidFrom && _validFrom == null) {
                    setState(() {
                      _validFrom = initialDate;
                      _validFromController.text = DateFormat(
                        'dd MMM, yyyy',
                      ).format(initialDate);
                    });
                  } else if (!isValidFrom && _validTo == null) {
                    setState(() {
                      _validTo = initialDate;
                      _validToController.text = DateFormat(
                        'dd MMM, yyyy',
                      ).format(initialDate);
                    });
                  }
                  Navigator.pop(context);
                },
                text: 'Confirm Date',
                backgroundColor: kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOffer() async {
    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      ToastService().showToast(
        context,
        'Offer title is required',
        type: ToastType.error,
      );
      return;
    }

    if (_descController.text.trim().isEmpty) {
      ToastService().showToast(
        context,
        'Description is required',
        type: ToastType.error,
      );
      return;
    }

    if (_selectedOfferTypeCode == null) {
      ToastService().showToast(
        context,
        'Offer type is required',
        type: ToastType.error,
      );
      return;
    }

    if (_tags.isEmpty) {
      ToastService().showToast(
        context,
        'At least one tag is required',
        type: ToastType.error,
      );
      return;
    }

    if (_validFrom == null || _validTo == null) {
      ToastService().showToast(
        context,
        'Valid From and Valid To dates are required',
        type: ToastType.error,
      );
      return;
    }

    if (_validFrom!.isAfter(_validTo!)) {
      ToastService().showToast(
        context,
        'Valid From date must be before Valid To date',
        type: ToastType.error,
      );
      return;
    }

    final maxTotal = _maxTotalRedemptionsController.text.trim();
    if (maxTotal.isNotEmpty && int.tryParse(maxTotal) == null) {
      ToastService().showToast(
        context,
        'Maximum total redemptions must be a valid integer',
        type: ToastType.error,
      );
      return;
    }

    final maxPerUser = _maxPerUserController.text.trim();
    if (maxPerUser.isNotEmpty && int.tryParse(maxPerUser) == null) {
      ToastService().showToast(
        context,
        'Maximum redemptions per customer must be a valid integer',
        type: ToastType.error,
      );
      return;
    }

    final minPurchase = _minPurchaseAmountController.text.trim();
    if (minPurchase.isNotEmpty && double.tryParse(minPurchase) == null) {
      ToastService().showToast(
        context,
        'Minimum purchase amount must be a valid number',
        type: ToastType.error,
      );
      return;
    }

    if (_pickedImages.isEmpty && widget.offer == null) {
      ToastService().showToast(
        context,
        'At least one offer image is required',
        type: ToastType.error,
      );
      return;
    }

    if (_branchApplicabilityType == 'specific' && _selectedBranchIds.isEmpty) {
      ToastService().showToast(
        context,
        'Please select at least one branch',
        type: ToastType.error,
      );
      return;
    }

    final minPrice = double.tryParse(_minPriceController.text.trim());
    final maxPrice = double.tryParse(_maxPriceController.text.trim());
    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      ToastService().showToast(
        context,
        'Minimum price cannot be greater than maximum price',
        type: ToastType.error,
      );
      return;
    }

    final minDiscount = double.tryParse(_minDiscountController.text.trim());
    final maxDiscount = double.tryParse(_maxDiscountController.text.trim());
    if (minDiscount != null &&
        maxDiscount != null &&
        minDiscount > maxDiscount) {
      ToastService().showToast(
        context,
        'Minimum discount cannot be greater than maximum discount',
        type: ToastType.error,
      );
      return;
    }

    if (_discountType == 'percentage') {
      if (maxDiscount != null && maxDiscount > 100) {
        ToastService().showToast(
          context,
          'Percentage discount cannot exceed 100%',
          type: ToastType.error,
        );
        return;
      }
      if (minDiscount != null && minDiscount < 0) {
        ToastService().showToast(
          context,
          'Percentage discount cannot be negative',
          type: ToastType.error,
        );
        return;
      }
    } else {
      if (minPrice != null && maxDiscount != null && maxDiscount > minPrice) {
        ToastService().showToast(
          context,
          'Flat discount cannot exceed the minimum price',
          type: ToastType.error,
        );
        return;
      }
    }

    if (_selectedOfferTypeCode == 'DO' && _isScratchCard) {
      if (_minDiscountController.text.trim().isEmpty ||
          _maxDiscountController.text.trim().isEmpty) {
        ToastService().showToast(
          context,
          'Discount range (min and max) is required for scratch card discount offers',
          type: ToastType.error,
        );
        return;
      }
    }

    if (_selectedDealType != null && _selectedDealType!.isNotEmpty && _isDealActive) {
      if (_dealStartDate == null || _dealStartTime == null) {
        ToastService().showToast(
          context,
          'Please select a start date and time for the deal',
          type: ToastType.error,
        );
        return;
      }
      if (_dealExpiryDate == null || _dealExpiryTime == null) {
        ToastService().showToast(
          context,
          'Please select an expiry date and time for the deal',
          type: ToastType.error,
        );
        return;
      }
      final startDt = DateTime(
        _dealStartDate!.year,
        _dealStartDate!.month,
        _dealStartDate!.day,
        _dealStartTime!.hour,
        _dealStartTime!.minute,
      );
      final expiryDt = DateTime(
        _dealExpiryDate!.year,
        _dealExpiryDate!.month,
        _dealExpiryDate!.day,
        _dealExpiryTime!.hour,
        _dealExpiryTime!.minute,
      );
      if (startDt.isBefore(DateTime.now().subtract(const Duration(minutes: 5)))) {
        ToastService().showToast(
          context,
          'Start date and time cannot be in the past',
          type: ToastType.error,
        );
        return;
      }
      if (expiryDt.isBefore(startDt) || expiryDt.isAtSameMomentAs(startDt)) {
        ToastService().showToast(
          context,
          'Expiry date and time must be after start date and time',
          type: ToastType.error,
        );
        return;
      }
      final diffHours = expiryDt.difference(startDt).inMinutes / 60.0;
      if (diffHours < 1.0) {
        ToastService().showToast(
          context,
          'Expiry must be at least 1 hour after start time',
          type: ToastType.error,
        );
        return;
      }
      double maxDuration = 24;
      String maxMsg = 'Deal duration must be between 1 and 24 hours';
      if (_selectedDealType == 'deal_of_day') {
        maxDuration = 7 * 24;
        maxMsg = 'Deal duration must be at least 1 hour and cannot exceed 7 days';
      } else if (_selectedDealType == 'deal_of_week') {
        maxDuration = 30 * 24;
        maxMsg = 'Deal duration must be at least 1 hour and cannot exceed 30 days';
      } else if (_selectedDealType == 'deal_of_month') {
        maxDuration = 90 * 24;
        maxMsg = 'Deal duration must be at least 1 hour and cannot exceed 90 days';
      }
      if (diffHours > maxDuration) {
        ToastService().showToast(
          context,
          maxMsg,
          type: ToastType.error,
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiProvider);
      final partner = ref.read(partnerProvider);
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

      if (partner == null ||
          primaryBranch == null ||
          primaryBranch.location?.coordinates == null ||
          primaryBranch.location!.coordinates!.isEmpty) {
        ToastService().showToast(
          context,
          'Primary branch location is required. Please add a branch and mark it as Primary in "Account" settings.',
          type: ToastType.error,
        );
        setState(() => _isLoading = false);
        return;
      }

      final body = <String, String>{
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'isActive': _isActive.toString(),
        'discountType': _discountType,
        'terms': json.encode(
          _termControllers
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList(),
        ),
      };

      body['redemptionRules'] = json.encode({
        'maxTotalRedemptions': _maxTotalRedemptionsController.text.trim().isNotEmpty
            ? int.tryParse(_maxTotalRedemptionsController.text.trim())
            : null,
        'maxPerUser': _maxPerUserController.text.trim().isNotEmpty
            ? int.tryParse(_maxPerUserController.text.trim())
            : null,
        'minPurchaseAmount': _minPurchaseAmountController.text.trim().isNotEmpty
            ? double.tryParse(_minPurchaseAmountController.text.trim()) ?? 0.0
            : 0.0,
      });

      body['discountRange'] = json.encode({
        if (_minDiscountController.text.trim().isNotEmpty)
          'min': double.tryParse(_minDiscountController.text.trim()),
        if (_maxDiscountController.text.trim().isNotEmpty)
          'max': double.tryParse(_maxDiscountController.text.trim()),
      });

      body['priceRange'] = json.encode({
        if (_minPriceController.text.trim().isNotEmpty)
          'min': double.tryParse(_minPriceController.text.trim()),
        if (_maxPriceController.text.trim().isNotEmpty)
          'max': double.tryParse(_maxPriceController.text.trim()),
      });

      if (_tags.isNotEmpty) {
        body['tags'] = jsonEncode(_tags);
      }

      body['branchApplicability'] = json.encode({
        'type': _branchApplicabilityType,
        'branchIds': _selectedBranchIds,
      });

      body['isScratchCard'] = _isScratchCard.toString();

      if (_selectedSubcategories.isNotEmpty) {
        body['subcategories'] = json.encode(_selectedSubcategories);
        body['subcategory'] = _selectedSubcategories.first;
      } else if (_selectedSubcategory != null && _selectedSubcategory!.isNotEmpty) {
        body['subcategory'] = _selectedSubcategory!;
        body['subcategories'] = json.encode([_selectedSubcategory!]);
      }

      if (_selectedOfferTypeCode != null) {
        body['offerTypeCode'] = _selectedOfferTypeCode!;
        Map<String, dynamic>? metaMap;
        if (_selectedOfferTypeCode == 'BG') {
          metaMap = {
            if (_bgBuyQtyController.text.trim().isNotEmpty)
              'buyQuantity': int.tryParse(_bgBuyQtyController.text.trim()),
            if (_bgGetDescController.text.trim().isNotEmpty)
              'getDescription': _bgGetDescController.text.trim(),
          };
        } else if (_selectedOfferTypeCode == 'DNP') {
          metaMap = {
            if (_dnpDiscountController.text.trim().isNotEmpty)
              'nextPurchaseDiscount': double.tryParse(_dnpDiscountController.text.trim()),
          };
        } else if (_selectedOfferTypeCode == 'CO' || _selectedOfferTypeCode == 'CP') {
          metaMap = {
            if (_comboDescController.text.trim().isNotEmpty)
              'comboDescription': _comboDescController.text.trim(),
          };
        } else if (_selectedOfferTypeCode == 'LD') {
          metaMap = {
            if (_ldMinPurchaseController.text.trim().isNotEmpty)
              'minPurchaseLimit': double.tryParse(_ldMinPurchaseController.text.trim()),
            if (_ldPrizeDescController.text.trim().isNotEmpty)
              'prizeDescription': _ldPrizeDescController.text.trim(),
          };
        } else if (_selectedOfferTypeCode == 'LO') {
          metaMap = {
            if (_loPurchaseCountController.text.trim().isNotEmpty)
              'purchaseCount': int.tryParse(_loPurchaseCountController.text.trim()),
            if (_loFreeItemDescController.text.trim().isNotEmpty)
              'freeItemDescription': _loFreeItemDescController.text.trim(),
          };
        } else if (_selectedOfferTypeCode == 'CS') {
          metaMap = {
            if (_csDiscountController.text.trim().isNotEmpty)
              'clearanceDiscount': _csDiscountController.text.trim(),
          };
        } else if (_selectedOfferTypeCode == 'LTO') {
          metaMap = {
            if (_ltoMessageController.text.trim().isNotEmpty)
              'timeLimitedMessage': _ltoMessageController.text.trim(),
          };
        } else if (_selectedOfferTypeCode == 'RC') {
          metaMap = {
            if (_rcCouponCodeController.text.trim().isNotEmpty)
              'couponCode': _rcCouponCodeController.text.trim(),
          };
        }
        if (metaMap != null && metaMap.isNotEmpty) {
          body['offerMetadata'] = json.encode(metaMap);
        } else {
          body['offerMetadata'] = json.encode({});
        }
      }

      if (_selectedDealType != null && _selectedDealType!.isNotEmpty && _isDealActive && _dealStartDate != null && _dealStartTime != null && _dealExpiryDate != null && _dealExpiryTime != null) {
        final startDt = DateTime(
          _dealStartDate!.year,
          _dealStartDate!.month,
          _dealStartDate!.day,
          _dealStartTime!.hour,
          _dealStartTime!.minute,
        );
        final expiryDt = DateTime(
          _dealExpiryDate!.year,
          _dealExpiryDate!.month,
          _dealExpiryDate!.day,
          _dealExpiryTime!.hour,
          _dealExpiryTime!.minute,
        );
        body['deal'] = json.encode({
          'type': _selectedDealType,
          'isActive': _isDealActive,
          'startDate': startDt.toUtc().toIso8601String(),
          'expiryDate': expiryDt.toUtc().toIso8601String(),
        });
      }

      if (_selectedTier != null) {
        body['requiredTier'] = json.encode(_selectedTier!.toJson());
      }

      // Category is automatically populated on the backend based on the partner's business type

      if (primaryBranch.location != null) {
        final loc = primaryBranch.location!;
        if (loc.coordinates != null && loc.coordinates!.length == 2) {
          body['location'] = json.encode({
            'type': 'Point',
            'coordinates': [loc.coordinates![0], loc.coordinates![1]],
          });
        }
      }

      if (_validFrom != null) body['validFrom'] = _validFrom!.toIso8601String();
      if (_validTo != null) body['validTo'] = _validTo!.toIso8601String();

      // Ensure all values are strings and remove any unwanted empty fields
      final cleanedBody = MapUtils.cleanMap(body);
      final finalBody = cleanedBody.map(
        (key, value) => MapEntry(key, value.toString()),
      );

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

      final isEdit = widget.offer != null;
      final response = isEdit
          ? await api.putMultipart(
              '/offers/${widget.offer!['_id'] ?? widget.offer!['id']}',
              finalBody,
              files: files,
            )
          : await api.postMultipart('/offers', finalBody, files: files);

      if (response.success && mounted) {
        final newOffer = OfferModel.fromJson(response.data!['data']);
        if (isEdit) {
          ref.read(offersProvider.notifier).updateOfferLocally(newOffer);
        } else {
          ref.read(offersProvider.notifier).addOffer(newOffer);
        }
        ToastService().showToast(
          context,
          'Offer ${isEdit ? 'updated' : 'created'} successfully',
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
          response.message ?? 'Failed to ${isEdit ? 'update' : 'create'} offer',
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
                isRequired: true,
              ),
              const SizedBox(height: 20),
              PrimaryTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Enter offer description',
                maxLines: 4,
                isRequired: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Offer Type',
                    style: kSmallTitleM.copyWith(
                      color: const Color(0xFF0A0A0A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: offerTypeLabels.entries.map((entry) {
                  final isSelected = _selectedOfferTypeCode == entry.key;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOfferTypeCode = entry.key;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? kPrimaryColor : kWhite,
                        border: Border.all(
                          color: isSelected
                              ? kPrimaryColor
                              : const Color(0xFFE5E5E5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        entry.value,
                        style: kSmallerTitleM.copyWith(
                          color: isSelected ? kWhite : kSecondaryTextColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_selectedOfferTypeCode != null && _selectedOfferTypeCode != 'DO') ...[
                const SizedBox(height: 16),
                _buildDynamicOfferFields(),
              ],
              const SizedBox(height: 20),
              Text(
                'Service Categories (Subcategories)',
                style: kSmallTitleM.copyWith(
                  color: const Color(0xFF0A0A0A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ref
                  .watch(subcategoriesProvider)
                  .when(
                    data: (list) {
                      if (list.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            'No subcategories found for your business type.',
                            style: kSmallerTitleL.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                        );
                      }
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E5E5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select applicable subcategories (Optional):',
                              style: kSmallerTitleL.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: list.map((sub) {
                                final isSelected = _selectedSubcategories.contains(sub);
                                return FilterChip(
                                  label: Text(
                                    sub,
                                    style: kSmallerTitleM.copyWith(
                                      color: isSelected ? kWhite : kSecondaryTextColor,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        if (!_selectedSubcategories.contains(sub)) {
                                          _selectedSubcategories.add(sub);
                                        }
                                        _selectedSubcategory = sub;
                                      } else {
                                        _selectedSubcategories.remove(sub);
                                        if (_selectedSubcategories.isNotEmpty) {
                                          _selectedSubcategory = _selectedSubcategories.first;
                                        } else {
                                          _selectedSubcategory = null;
                                        }
                                      }
                                    });
                                  },
                                  selectedColor: kPrimaryColor,
                                  backgroundColor: kWhite,
                                  checkmarkColor: kWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isSelected ? kPrimaryColor : const Color(0xFFE5E5E5),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'Failed to load subcategories',
                        style: kSmallerTitleL.copyWith(color: Colors.red),
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              Text(
                'Required Membership Tier',
                style: kSmallTitleM.copyWith(
                  color: const Color(0xFF0A0A0A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ref
                  .watch(membershipTiersProvider)
                  .when(
                    data: (list) {
                      return AnimatedDropdown<TierModel?>(
                        hint: 'All Tiers (default)',
                        value: _selectedTier,
                        items: [null, ...list],
                        itemLabel: (val) =>
                            val == null ? 'All Tiers' : (val.name ?? ''),
                        fillColor: const Color(0xFFF5F5F5),
                        borderRadius: 10,
                        onChanged: (val) {
                          setState(() {
                            _selectedTier = val;
                          });
                        },
                      );
                    },
                    loading: () => Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'Failed to load membership tiers',
                        style: kSmallerTitleL.copyWith(color: Colors.red),
                      ),
                    ),
                  ),
              const SizedBox(height: 20),

              _buildDealPromotionSection(context),
              const SizedBox(height: 20),

              Text(
                'Branch Applicability',
                style: kSmallTitleM.copyWith(
                  color: const Color(0xFF0A0A0A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedDropdown<String>(
                hint: 'Select Applicability',
                value: _branchApplicabilityType,
                items: const ['all', 'specific'],
                itemLabel: (val) =>
                    val == 'all' ? 'All Branches' : 'Specific Branches',
                fillColor: const Color(0xFFF5F5F5),
                borderRadius: 10,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _branchApplicabilityType = val;
                    });
                  }
                },
              ),
              if (_branchApplicabilityType == 'specific') ...[
                const SizedBox(height: 12),
                if (ref.watch(branchesProvider).isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      'No branches available. Please add branches in account settings.',
                      style: kSmallerTitleL.copyWith(
                        color: kSecondaryTextColor,
                      ),
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Text(
                      'Select Applicable Branches:',
                      style: kSmallTitleSB.copyWith(fontSize: 13),
                    ),
                  ),
                  ...ref.watch(branchesProvider).map((branch) {
                    final branchId = branch.id;
                    if (branchId == null) return const SizedBox.shrink();
                    final isChecked = _selectedBranchIds.contains(branchId);
                    return CheckboxListTile(
                      title: Text(
                        branch.name ?? 'Unnamed Branch',
                        style: kSmallTitleM.copyWith(fontSize: 14),
                      ),
                      subtitle: branch.address != null
                          ? Text(
                              branch.address!,
                              style: kSmallerTitleL.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            )
                          : null,
                      value: isChecked,
                      activeColor: kPrimaryColor,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            if (!_selectedBranchIds.contains(branchId)) {
                              _selectedBranchIds.add(branchId);
                            }
                          } else {
                            _selectedBranchIds.remove(branchId);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Price Settings',
                    style: kSmallTitleM.copyWith(
                      color: const Color(0xFF0A0A0A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _minPriceController,
                      label: 'Min Price',
                      hint: '₹ 0.00',
                      type: TextFieldType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryTextField(
                      controller: _maxPriceController,
                      label: 'Max Price',
                      hint: '₹ 0.00',
                      type: TextFieldType.number,
                    ),
                  ),
                ],
              ),
              if (_selectedOfferTypeCode == 'DO') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SwitchListTile(
                    value: _isScratchCard,
                    onChanged: (val) => setState(() => _isScratchCard = val),
                    title: Text(
                      'Use Scratch Card',
                      style: kSmallTitleM.copyWith(fontSize: 14),
                    ),
                    subtitle: Text(
                      'Random discount within min & max range when scratched',
                      style: kSmallerTitleL.copyWith(color: kSecondaryTextColor, fontSize: 12),
                    ),
                    activeThumbColor: kPrimaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount Settings',
                    style: kSmallTitleM.copyWith(
                      color: const Color(0xFF0A0A0A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _discountType = 'percentage';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _discountType == 'percentage'
                              ? kPrimaryColor
                              : kWhite,
                          border: Border.all(
                            color: _discountType == 'percentage'
                                ? kPrimaryColor
                                : const Color(0xFFE5E5E5),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Percentage (%)',
                          style: kSmallerTitleM.copyWith(
                            color: _discountType == 'percentage'
                                ? kWhite
                                : kSecondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _discountType = 'flat';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _discountType == 'flat'
                              ? kPrimaryColor
                              : kWhite,
                          border: Border.all(
                            color: _discountType == 'flat'
                                ? kPrimaryColor
                                : const Color(0xFFE5E5E5),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Flat Amount (₹)',
                          style: kSmallerTitleM.copyWith(
                            color: _discountType == 'flat'
                                ? kWhite
                                : kSecondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _minDiscountController,
                      label: 'Min Discount',
                      hint: _discountType == 'percentage'
                          ? 'e.g. 10'
                          : '₹ 0.00',
                      type: TextFieldType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryTextField(
                      controller: _maxDiscountController,
                      label: 'Max Discount',
                      hint: _discountType == 'percentage'
                          ? 'e.g. 50'
                          : '₹ 0.00',
                      type: TextFieldType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrimaryTextField(
                    controller: _tagsController,
                    label: 'Tags',
                    hint: 'Type a tag and press space',
                    isRequired: true,
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: AbsorbPointer(
                        child: PrimaryTextField(
                          controller: _validFromController,
                          label: 'Valid From',
                          hint: 'DD MMM, YYYY',
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          isRequired: true,
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
                          hint: 'DD MMM, YYYY',
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          isRequired: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Text(
                'Redemption Rules',
                style: kSmallTitleB.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _maxTotalRedemptionsController,
                      label: 'Max Total Redemptions',
                      hint: 'e.g. 100',
                      type: TextFieldType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryTextField(
                      controller: _maxPerUserController,
                      label: 'Max Per Customer',
                      hint: 'e.g. 1',
                      type: TextFieldType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryTextField(
                controller: _minPurchaseAmountController,
                label: 'Min Purchase Amount (₹)',
                hint: 'e.g. 500',
                type: TextFieldType.number,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: kSmallTitleB.copyWith(fontSize: 14),
                  ),
                  TextButton.icon(
                    onPressed: _addTerm,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Term'),
                    style: TextButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_termControllers.isEmpty)
                Text(
                  'No terms added yet.',
                  style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
                ),
              ...List.generate(_termControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PrimaryTextField(
                          controller: _termControllers[index],
                          hint: 'Enter term (e.g. Valid on weekends only)',
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeTerm(index),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        padding: const EdgeInsets.only(top: 12),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Offer Images',
                    style: kSmallTitleM.copyWith(
                      color: const Color(0xFF0A0A0A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CarouselSlider(
                options: CarouselOptions(
                  height: 100,
                  viewportFraction: 0.32,
                  enableInfiniteScroll: false,
                  padEnds: false,
                ),
                items: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ),
                  ...List.generate(_pickedImages.length, (index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(
                            _pickedImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
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
                                color: kWhite,
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
              text: widget.offer != null ? 'Update' : 'Save',
              backgroundColor: kPrimaryColor,
              textColor: kWhite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicOfferFields() {
    switch (_selectedOfferTypeCode) {
      case 'BG':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF), // purple-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD8B4FE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy X Get Y Details',
                style: kSmallTitleB.copyWith(color: const Color(0xFF6B21A8)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _bgBuyQtyController,
                      label: 'Buy Quantity *',
                      hint: 'e.g. 1',
                      type: TextFieldType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryTextField(
                      controller: _bgGetDescController,
                      label: 'Get (Free Item) *',
                      hint: 'e.g. 1 free or 50% off',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 'DNP':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF), // blue-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discount Amount on Next Purchase (₹) *',
                style: kSmallTitleB.copyWith(color: const Color(0xFF1E40AF)),
              ),
              const SizedBox(height: 12),
              PrimaryTextField(
                controller: _dnpDiscountController,
                hint: 'e.g. 500',
                type: TextFieldType.number,
              ),
            ],
          ),
        );
      case 'CO':
      case 'CP':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5), // green-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Combo Details *',
                style: kSmallTitleB.copyWith(color: const Color(0xFF065F46)),
              ),
              const SizedBox(height: 12),
              PrimaryTextField(
                controller: _comboDescController,
                hint: 'e.g. Get Pizza + Drink at ₹299',
              ),
            ],
          ),
        );
      case 'LD':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB), // amber-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lucky Draw Details',
                style: kSmallTitleB.copyWith(color: const Color(0xFF92400E)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _ldMinPurchaseController,
                      label: 'Minimum Purchase (₹)',
                      hint: 'e.g. 1000',
                      type: TextFieldType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryTextField(
                      controller: _ldPrizeDescController,
                      label: 'Prize Description *',
                      hint: 'e.g. Gift voucher worth ₹500',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 'LO':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF), // indigo-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loyalty Offer Details',
                style: kSmallTitleB.copyWith(color: const Color(0xFF3730A3)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: _loPurchaseCountController,
                      label: 'Purchase Count *',
                      hint: 'e.g. 5',
                      type: TextFieldType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryTextField(
                      controller: _loFreeItemDescController,
                      label: 'Free Item Description *',
                      hint: 'e.g. 1 service free',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 'CS':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2), // red-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clearance Discount Details *',
                style: kSmallTitleB.copyWith(color: const Color(0xFF991B1B)),
              ),
              const SizedBox(height: 12),
              PrimaryTextField(
                controller: _csDiscountController,
                hint: 'e.g. 50% off or Flat ₹100 off',
              ),
            ],
          ),
        );
      case 'LTO':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA), // teal-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF99F6E4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Urgency Message',
                style: kSmallTitleB.copyWith(color: const Color(0xFF115E59)),
              ),
              const SizedBox(height: 12),
              PrimaryTextField(
                controller: _ltoMessageController,
                hint: 'e.g. Only 24 hours left!',
              ),
            ],
          ),
        );
      case 'RC':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF2F8), // pink-50
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFBCFE8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coupon Code (Optional)',
                style: kSmallTitleB.copyWith(color: const Color(0xFF9D174D)),
              ),
              const SizedBox(height: 12),
              PrimaryTextField(
                controller: _rcCouponCodeController,
                hint: 'e.g. SAVE20',
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDealPromotionSection(BuildContext context) {
    final dealTypes = [
      {'value': 'deal_of_hour', 'label': 'Deal of the Hour', 'desc': 'Up to 24 hours', 'max': 24, 'unit': 'hours'},
      {'value': 'deal_of_day', 'label': 'Deal of the Day', 'desc': 'Up to 7 days', 'max': 7, 'unit': 'days'},
      {'value': 'deal_of_week', 'label': 'Deal of the Week', 'desc': 'Up to 30 days', 'max': 30, 'unit': 'days'},
      {'value': 'deal_of_month', 'label': 'Deal of the Month', 'desc': 'Up to 90 days', 'max': 90, 'unit': 'days'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deal Promotion (Optional)',
              style: kSmallTitleM.copyWith(
                color: const Color(0xFF0A0A0A),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_selectedDealType != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDealType = null;
                    _isDealActive = false;
                    _dealStartDate = null;
                    _dealStartTime = null;
                    _dealExpiryDate = null;
                    _dealExpiryTime = null;
                  });
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red, padding: EdgeInsets.zero),
                child: const Text('Remove Deal'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Promote your offer as a special deal. Only one deal type can be active at a time.',
          style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: dealTypes.map((deal) {
            final isSelected = _selectedDealType == deal['value'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDealType = deal['value'] as String;
                  _isDealActive = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFFBEB) : kWhite,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFE5E5E5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal['label'] as String,
                      style: kSmallerTitleM.copyWith(
                        color: isSelected ? const Color(0xFFB45309) : kTextColor,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deal['desc'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? const Color(0xFFD97706) : kSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedDealType != null && _selectedDealType!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedDealType == 'deal_of_hour')
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '⏰ Deal of the Hour lasts up to 24 hours from start time. Minimum 1 hour gap required for approval.',
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDealDateTime(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Date & Time', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text(
                                _dealStartDate != null && _dealStartTime != null
                                    ? '${DateFormat('dd MMM yyyy').format(_dealStartDate!)} at ${_dealStartTime!.format(context)}'
                                    : 'Select Start',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _dealStartDate != null ? FontWeight.w600 : FontWeight.normal,
                                  color: _dealStartDate != null ? kTextColor : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDealDateTime(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Expiry Date & Time', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text(
                                _dealExpiryDate != null && _dealExpiryTime != null
                                    ? '${DateFormat('dd MMM yyyy').format(_dealExpiryDate!)} at ${_dealExpiryTime!.format(context)}'
                                    : 'Select Expiry',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _dealExpiryDate != null ? FontWeight.w600 : FontWeight.normal,
                                  color: _dealExpiryDate != null ? kTextColor : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _isDealActive,
                  onChanged: (val) => setState(() => _isDealActive = val),
                  title: Text('Activate this deal on start date', style: kSmallTitleM.copyWith(fontSize: 14)),
                  activeThumbColor: kPrimaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                if (_isDealActive && _dealStartDate != null && _dealStartTime != null && _dealExpiryDate != null && _dealExpiryTime != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deal Schedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green[800])),
                        const SizedBox(height: 2),
                        Text('Starts: ${DateFormat('dd MMM yyyy').format(_dealStartDate!)} at ${_dealStartTime!.format(context)}', style: TextStyle(fontSize: 12, color: Colors.green[700])),
                        Text('Ends: ${DateFormat('dd MMM yyyy').format(_dealExpiryDate!)} at ${_dealExpiryTime!.format(context)}', style: TextStyle(fontSize: 12, color: Colors.green[700])),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDealDateTime(BuildContext context, bool isStart) async {
    FocusManager.instance.primaryFocus?.unfocus();
    DateTime initialDate = (isStart ? _dealStartDate : _dealExpiryDate) ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && mounted) {
      TimeOfDay initialTime = (isStart ? _dealStartTime : _dealExpiryTime) ?? TimeOfDay.now();
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (pickedTime != null && mounted) {
        setState(() {
          if (isStart) {
            _dealStartDate = pickedDate;
            _dealStartTime = pickedTime;
          } else {
            _dealExpiryDate = pickedDate;
            _dealExpiryTime = pickedTime;
          }
        });
      }
    }
  }
}
