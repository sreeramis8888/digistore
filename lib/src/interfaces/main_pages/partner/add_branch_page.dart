import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/business_info.dart';
import '../../../data/models/location_point.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../components/map_location_picker_page.dart';
import '../../components/operating_hours_editor.dart';
import '../../components/animated_dropdown.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class AddBranchPage extends StatefulWidget {
  final BusinessBranch? initialBranch;
  final bool isFirstBranch;

  const AddBranchPage({super.key, this.initialBranch, this.isFirstBranch = false});

  @override
  State<AddBranchPage> createState() => _AddBranchPageState();
}

class _AddBranchPageState extends State<AddBranchPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _contactNameCtrl;
  late TextEditingController _contactDesignationCtrl;
  late TextEditingController _landmarkCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _pincodeCtrl;

  OperatingHours? _operatingHours;
  LocationPoint? _location;
  bool _isActive = true;
  String? _branchType;
  bool _isPrimary = false;

  final List<Map<String, String>> _branchTypes = const [
    {'value': 'main', 'label': 'Main Branch'},
    {'value': 'franchise', 'label': 'Franchise'},
    {'value': 'outlet', 'label': 'Outlet'},
    {'value': 'service_center', 'label': 'Service Center'},
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialBranch?.name ?? '');
    _addressCtrl = TextEditingController(text: widget.initialBranch?.address ?? widget.initialBranch?.location?.address ?? '');
    _phoneCtrl = TextEditingController(text: widget.initialBranch?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.initialBranch?.email ?? '');
    _contactNameCtrl = TextEditingController(text: widget.initialBranch?.contactPersonName ?? '');
    _contactDesignationCtrl = TextEditingController(text: widget.initialBranch?.contactPersonDesignation ?? '');
    _landmarkCtrl = TextEditingController(text: widget.initialBranch?.location?.landmark ?? '');
    _cityCtrl = TextEditingController(text: widget.initialBranch?.location?.city ?? '');
    _districtCtrl = TextEditingController(text: widget.initialBranch?.location?.district ?? '');
    _stateCtrl = TextEditingController(text: widget.initialBranch?.location?.state ?? '');
    _pincodeCtrl = TextEditingController(text: widget.initialBranch?.location?.pincode ?? '');
    
    _location = widget.initialBranch?.location;
    _locationCtrl = TextEditingController(
      text: _location?.coordinates != null && _location!.coordinates!.length >= 2
          ? 'Location Selected (${_location!.coordinates![1].toStringAsFixed(4)}, ${_location!.coordinates![0].toStringAsFixed(4)})'
          : '',
    );
    
    _operatingHours = widget.initialBranch?.operatingHours;
    _isActive = widget.initialBranch?.isActive ?? true;
    _branchType = widget.initialBranch?.branchType ?? 'outlet';
    _isPrimary = widget.initialBranch?.isPrimary ?? widget.isFirstBranch;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _emailCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactDesignationCtrl.dispose();
    _landmarkCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();
    
    double? lat;
    double? lng;
    
    if (_location?.coordinates != null && _location!.coordinates!.length >= 2) {
      lng = _location!.coordinates![0];
      lat = _location!.coordinates![1];
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerPage(
          initialLat: lat,
          initialLng: lng,
          initialLocalBody: null,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        final double selectedLng = result['lng'] as double;
        final double selectedLat = result['lat'] as double;
        _location = LocationPoint(
          type: 'Point',
          coordinates: [selectedLng, selectedLat],
          address: _addressCtrl.text.trim(),
          landmark: _landmarkCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          district: _districtCtrl.text.trim(),
          state: _stateCtrl.text.trim(),
          pincode: _pincodeCtrl.text.trim(),
        );
        _locationCtrl.text = 'Location Selected (${selectedLat.toStringAsFixed(4)}, ${selectedLng.toStringAsFixed(4)})';
      });
    }
  }

  void _saveBranch() {
    if (_formKey.currentState!.validate()) {
      if (_nameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Branch Name is required')),
        );
        return;
      }

      final branch = BusinessBranch(
        id: widget.initialBranch?.id,
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        contactPersonName: _contactNameCtrl.text.trim(),
        contactPersonDesignation: _contactDesignationCtrl.text.trim(),
        location: LocationPoint(
          type: 'Point',
          coordinates: _location?.coordinates ?? [0.0, 0.0],
          address: _addressCtrl.text.trim(),
          landmark: _landmarkCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          district: _districtCtrl.text.trim(),
          state: _stateCtrl.text.trim(),
          pincode: _pincodeCtrl.text.trim(),
        ),
        operatingHours: _operatingHours,
        isActive: _isActive,
        branchType: _branchType,
        isPrimary: _isPrimary,
      );

      Navigator.pop(context, branch);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: kSmallTitleM.copyWith(
          fontWeight: FontWeight.w600,
          color: kBlack,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
        titleSpacing: 0,
        title: Text(
          widget.initialBranch != null ? 'Edit Branch' : 'Add Branch',
          style: kBodyTitleM.copyWith(
            fontWeight: FontWeight.w700,
            color: kTextColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Basic Information'),
                      PrimaryTextField(
                        label: 'Branch Name',
                        hint: 'Enter branch name',
                        controller: _nameCtrl,
                        prefixIcon: const Icon(Icons.storefront_outlined, color: kSecondaryColor, size: 18),
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Branch Type',
                              style: kSmallTitleM.copyWith(
                                color: const Color(0xFF0A0A0A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedDropdown<Map<String, String>>(
                            hint: 'Select branch type',
                            value: _branchTypes.firstWhere(
                              (opt) => opt['value'] == _branchType,
                              orElse: () => _branchTypes[2], // outlet
                            ),
                            items: _branchTypes,
                            itemLabel: (opt) => opt['label'] ?? '',
                            borderRadius: 10,
                            fillColor: const Color(0xFFF5F5F5),
                            onChanged: (opt) {
                              setState(() {
                                _branchType = opt?['value'];
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFF3F4F6), height: 1),
                      _buildSectionTitle('Contact Person'),
                      PrimaryTextField(
                        label: 'Contact Name',
                        hint: 'Manager / Owner Name',
                        controller: _contactNameCtrl,
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: kSecondaryColor, size: 18),
                      ),
                      const SizedBox(height: 16),
                      PrimaryTextField(
                        label: 'Designation',
                        hint: 'e.g. Branch Manager',
                        controller: _contactDesignationCtrl,
                        prefixIcon: const Icon(Icons.badge_outlined, color: kSecondaryColor, size: 18),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFF3F4F6), height: 1),
                      _buildSectionTitle('Contact Details'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Phone Number',
                              style: kSmallTitleM.copyWith(
                                color: const Color(0xFF0A0A0A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          IntlPhoneField(
                            disableLengthCheck: true,
                            initialCountryCode: 'IN',
                            initialValue: (widget.initialBranch?.phone != null && widget.initialBranch!.phone!.startsWith('+91') && widget.initialBranch!.phone!.length > 3)
                                ? widget.initialBranch!.phone!.substring(3)
                                : widget.initialBranch?.phone?.replaceAll('+', '') ?? '',
                            flagsButtonMargin: EdgeInsets.zero,
                            flagsButtonPadding: EdgeInsets.zero,
                            decoration: InputDecoration(
                              hintText: 'Enter phone number',
                              hintStyle: kSmallTitleL.copyWith(
                                color: const Color(0xFF808080),
                                letterSpacing: 0.1,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: kPrimaryColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (phone) {
                              _phoneCtrl.text = phone.completeNumber;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PrimaryTextField(
                        label: 'Email Address',
                        hint: 'Enter contact email',
                        controller: _emailCtrl,
                        type: TextFieldType.email,
                        prefixIcon: const Icon(Icons.email_outlined, color: kSecondaryColor, size: 18),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFF3F4F6), height: 1),
                      _buildSectionTitle('Location & Address'),
                      GestureDetector(
                        onTap: _pickLocation,
                        child: AbsorbPointer(
                          child: PrimaryTextField(
                            label: 'Map Location',
                            hint: 'Tap to pick location',
                            controller: _locationCtrl,
                            prefixIcon: const Icon(Icons.map_outlined, color: kSecondaryColor, size: 18),
                            suffixIcon: const Icon(Icons.my_location_rounded, color: kPrimaryColor, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryTextField(
                        label: 'Full Address',
                        hint: 'Complete physical address',
                        controller: _addressCtrl,
                        prefixIcon: const Icon(Icons.location_on_outlined, color: kSecondaryColor, size: 18),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryTextField(
                              label: 'Landmark',
                              hint: 'Near landmark',
                              controller: _landmarkCtrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryTextField(
                              label: 'City',
                              hint: 'City name',
                              controller: _cityCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryTextField(
                              label: 'District',
                              hint: 'District name',
                              controller: _districtCtrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryTextField(
                              label: 'State',
                              hint: 'State name',
                              controller: _stateCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PrimaryTextField(
                        label: 'Pincode',
                        hint: 'PIN / Zip Code',
                        controller: _pincodeCtrl,
                        type: TextFieldType.number,
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFF3F4F6), height: 1),
                      _buildSectionTitle('Branch Settings'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Primary Branch',
                                style: kSmallTitleM.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: kBlack,
                                ),
                              ),
                              CupertinoSwitch(
                                value: _isPrimary,
                                onChanged: widget.isFirstBranch || (widget.initialBranch?.isPrimary ?? false)
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _isPrimary = val;
                                        });
                                      },
                                activeTrackColor: kPrimaryColor,
                              ),
                            ],
                          ),
                          if (widget.isFirstBranch || (widget.initialBranch?.isPrimary ?? false)) ...[
                            const SizedBox(height: 4),
                            Text(
                              'At least one branch must be marked as primary.',
                              style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFF3F4F6), height: 1),
                      _buildSectionTitle('Operating Hours'),
                      OperatingHoursEditor(
                        operatingHours: _operatingHours,
                        isEditMode: true,
                        onChanged: (newHours) {
                          setState(() {
                            _operatingHours = newHours;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: 'Save Branch',
                onPressed: _saveBranch,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
