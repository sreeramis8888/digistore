import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../components/location_selection_bottom_sheet.dart';

class MyAccountPage extends ConsumerStatefulWidget {
  final bool isEditMode;
  const MyAccountPage({super.key, this.isEditMode = false});

  @override
  ConsumerState<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends ConsumerState<MyAccountPage> {
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;

  double? _lat;
  double? _lng;
  String? _district;
  String? _localBody;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _mobileController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');

    _district = user?.location?.district;
    _localBody = user?.location?.localBody;
    _lat = user?.location?.coordinates?.lat;
    _lng = user?.location?.coordinates?.lng;

    _locationController = TextEditingController(
      text: (_localBody != null && _localBody!.isNotEmpty)
          ? _localBody!.split(' ').first
          : (_district != null && _district!.isNotEmpty)
              ? _district!.split(' ').first
              : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final isEditMode = widget.isEditMode;

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Account', style: kSubHeadingM.copyWith(color: kTextColor)),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenSize.responsivePadding(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isEditMode) ...[
                        PrimaryTextField(
                          label: 'Name',
                          hint: 'Enter your name',
                          controller: _nameController,
                        ),
                        SizedBox(height: screenSize.responsivePadding(24)),
                        PrimaryTextField(
                          label: 'Mobile Number',
                          hint: 'Enter mobile number',
                          controller: _mobileController,
                          readOnly: true,
                        ),
                        SizedBox(height: screenSize.responsivePadding(24)),
                        PrimaryTextField(
                          label: 'Email',
                          hint: 'Enter email',
                          controller: _emailController,
                        ),
                        SizedBox(height: screenSize.responsivePadding(24)),
                        PrimaryTextField(
                          label: 'Location',
                          hint: 'Tap to capture location',
                          controller: _locationController,
                          isRequired: true,
                          readOnly: true,
                          suffixIcon: const Icon(
                            Icons.my_location_rounded,
                            size: 20,
                            color: kPrimaryColor,
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => LocationSelectionBottomSheet(
                                initialLat: _lat,
                                initialLng: _lng,
                                initialDistrict: _district,
                                initialLocalBody: _localBody,
                                onLocationSelected:
                                    (district, localBody, lat, lng) {
                                  setState(() {
                                    _locationController.text =
                                        localBody.isNotEmpty
                                            ? localBody.split(' ').first
                                            : district.split(' ').first;
                                    _district = district;
                                    _localBody = localBody;
                                    _lat = lat;
                                    _lng = lng;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        _buildReadOnlyField('Name', _nameController.text),
                        _buildReadOnlyField('Mobile Number', _mobileController.text),
                        _buildReadOnlyField('Email', _emailController.text),
                        _buildReadOnlyField('Location', _locationController.text.split(',').first.split(' ').first),
                      ]
                    ],
                  ),
                ),
              ),
              if (isEditMode) ...[
                SizedBox(height: screenSize.responsivePadding(16)),
                PrimaryButton(
                  text: 'Save',
                  onPressed: () async {
                    final success = await ref.read(userProvider.notifier).updateProfile(
                      name: _nameController.text,
                      email: _emailController.text,
                    );

                    if (success && _lat != null && _lng != null) {
                      await ref.read(userProvider.notifier).updateLocation(
                        lat: _lat!,
                        lng: _lng!,
                        district: _district ?? '',
                        localBody: _localBody ?? '',
                      );
                    }

                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    final screenSize = ref.watch(screenSizeProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: screenSize.responsivePadding(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
             label,
             style: kSmallTitleM.copyWith(
               color: const Color(0xFF0A0A0A),
               fontWeight: FontWeight.w500,
             ),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
          Text(
            value.isNotEmpty ? value : '-',
            style: kSmallTitleL.copyWith(color: const Color(0xFF373737)),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
        ],
      ),
    );
  }
}
