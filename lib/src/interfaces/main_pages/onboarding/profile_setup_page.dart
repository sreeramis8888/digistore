import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../components/location_selection_bottom_sheet.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/services/secure_storage_service.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  double? _lat;
  double? _lng;
  String? _district;
  String? _localBody;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final storage = ref.read(secureStorageServiceProvider);
    final data = await storage.getRegistrationData();
    if (data != null && data['phone'] != null) {
      if (mounted) {
        setState(() {
          _mobileController.text = data['phone'];
        });
      }
    }
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
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenSize.responsivePadding(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.responsivePadding(24)),
              // Logo and Slogan
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/png/setgo.png',
                      height: screenSize.responsivePadding(80),
                    ),
                    SizedBox(height: screenSize.responsivePadding(8)),
                    Text(
                      'Spend Local. Save Big.',
                      style: kSmallerTitleL.copyWith(
                        color: kSecondaryTextColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(40)),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryTextField(
                        label: 'Full Name',
                        hint: 'Enter full name',
                        controller: _nameController,
                        isRequired: true,
                      ),
                      SizedBox(height: screenSize.responsivePadding(24)),
                      PrimaryTextField(
                        label: 'Mobile Number',
                        hint: 'Enter mobile number',
                        controller: _mobileController,
                        isRequired: true,
                        readOnly: true,
                      ),
                      SizedBox(height: screenSize.responsivePadding(24)),
                      PrimaryTextField(
                        label: 'Email',
                        hint: 'Enter email',
                        controller: _emailController,
                        type: TextFieldType.email,
                      ),
                      SizedBox(height: screenSize.responsivePadding(24)),
                      PrimaryTextField(
                        label: 'Location',
                        hint: 'Tap to capture location',
                        controller: _locationController,
                        isRequired: true,
                        readOnly: true,
                        suffixIcon: const Icon(Icons.my_location_rounded, size: 20, color: kPrimaryColor),
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
                              onLocationSelected: (district, localBody, lat, lng) {
                                setState(() {
                                  _locationController.text = localBody.isNotEmpty 
                                      ? '$localBody, $district' 
                                      : district;
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
                      if (_lat != null && _lng != null) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Captured: ${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}',
                            style: kSmallerTitleM.copyWith(color: kPrimaryColor),
                          ),
                        ),
                      ],
                      SizedBox(height: screenSize.responsivePadding(40)),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: _isSubmitting 
                    ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                    : PrimaryButton(
                        text: 'Submit',
                        onPressed: () async {
                          if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all required fields.')),
                            );
                            return;
                          }

                          setState(() {
                            _isSubmitting = true;
                          });

                          try {
                            final successProfile = await ref
                                .read(userProvider.notifier)
                                .updateProfile(
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  onboardingComplete: true,
                                );

                            if (successProfile && _lat != null && _lng != null) {
                              await ref.read(userProvider.notifier).updateLocation(
                                lat: _lat!,
                                lng: _lng!,
                                district: _district ?? '',
                                localBody: _localBody ?? '',
                              );
                            }

                            final storage = ref.read(secureStorageServiceProvider);
                            await storage.saveOnboardingComplete(true);

                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                'navbar',
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSubmitting = false;
                              });
                            }
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
