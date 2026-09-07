import 'package:setgo/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../components/location_selection_bottom_sheet.dart';
import 'package:flutter/services.dart';
import '../../components/confirmation_dialog.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/secure_storage_service.dart';
import '../../../data/services/toast_service.dart';

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
  String? _nameError;
  String? _emailError;
  String? _locationError;
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (trimmed.length > 30) {
      return 'Name cannot exceed 30 characters';
    }
    if (RegExp(r'[0-9]').hasMatch(trimmed)) {
      return 'Numbers are not allowed in name';
    }
    final emojiRegex = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
      unicode: true,
    );
    if (emojiRegex.hasMatch(trimmed)) {
      return 'Emojis are not allowed in name';
    }
    if (!RegExp(r"^[a-zA-Z\u00C0-\u024F\s.'-]+$").hasMatch(trimmed)) {
      return 'Special characters are not allowed';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.contains(' ')) {
      return 'Email cannot contain spaces';
    }
    if (!trimmed.contains('@')) {
      return 'Email must contain an @';
    }
    final parts = trimmed.split('@');
    if (parts.length != 2 || parts[0].isEmpty) {
      return 'Please enter a valid email prefix';
    }
    final domain = parts[1];
    if (domain.isEmpty || !domain.contains('.') || domain.split('.').last.length < 2) {
      return 'Please enter a valid domain (e.g. example.com)';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
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
              SizedBox(height: screenSize.responsivePadding(12)),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () async {
                    final confirmed = await showConfirmationDialog(
                      context: context,
                      title: 'Logout',
                      message: 'Are you sure you want to log out?',
                      confirmText: 'Logout',
                      isDestructive: true,
                      icon: Icons.logout_rounded,
                      onConfirm: () async {
                        await ref.read(authProvider.notifier).logout();
                      },
                    );

                    if (confirmed == true && context.mounted) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('login', (route) => false);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(12),
                      vertical: screenSize.responsivePadding(6),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFFFFD6D6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFE53935),
                          size: 14,
                        ),
                        SizedBox(width: screenSize.responsivePadding(4)),
                        Text(
                          'Logout',
                          style: kSmallTitleSB.copyWith(
                            color: const Color(0xFFE53935),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(8)),
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
                        maxLength: 30,
                        showCounter: false,
                        errorText: _nameError,
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
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
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        errorText: _emailError,
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),
                      SizedBox(height: screenSize.responsivePadding(24)),
                      PrimaryTextField(
                        label: 'Location',
                        hint: 'Tap to capture location',
                        controller: _locationController,
                        isRequired: true,
                        readOnly: true,
                        errorText: _locationError,
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
                                          ? '$localBody, $district'
                                          : district;
                                      _district = district;
                                      _localBody = localBody;
                                      _lat = lat;
                                      _lng = lng;
                                      _locationError = null;
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
                            style: kSmallerTitleM.copyWith(
                              color: kPrimaryColor,
                            ),
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
                    ? const Center(child: LoadingAnimation())
                    : PrimaryButton(
                        text: 'Submit',
                        onPressed: () async {
                          final nameErr = _validateName(_nameController.text);
                          final emailErr = _validateEmail(_emailController.text);
                          final locErr = _locationController.text.trim().isEmpty
                              ? 'Location is required'
                              : null;

                          setState(() {
                            _nameError = nameErr;
                            _emailError = emailErr;
                            _locationError = locErr;
                          });

                          if (nameErr != null || emailErr != null || locErr != null) {
                            if (locErr != null && nameErr == null && emailErr == null) {
                              ToastService().showToast(
                                context,
                                'Please select your location',
                                type: ToastType.warning,
                              );
                            }
                            return;
                          }

                          // Auto-trim leading/trailing spaces and normalize multiple spaces
                          final cleanedName = _nameController.text
                              .trim()
                              .replaceAll(RegExp(r'\s+'), ' ');
                          _nameController.text = cleanedName;

                          // Auto-trim spaces and convert uppercase email to lowercase
                          final rawEmail = _emailController.text
                              .trim()
                              .replaceAll(' ', '');
                          final cleanedEmail = rawEmail.toLowerCase();
                          _emailController.text = cleanedEmail;

                          setState(() {
                            _isSubmitting = true;
                          });

                          try {
                            final successProfile = await ref
                                .read(userProvider.notifier)
                                .updateProfile(
                                  name: cleanedName,
                                  email: cleanedEmail,
                                  onboardingComplete: true,
                                );

                            if (successProfile &&
                                _lat != null &&
                                _lng != null) {
                              await ref
                                  .read(userProvider.notifier)
                                  .updateLocation(
                                    lat: _lat!,
                                    lng: _lng!,
                                    district: _district ?? '',
                                    localBody: _localBody ?? '',
                                  );
                            }

                            final storage = ref.read(
                              secureStorageServiceProvider,
                            );
                            await storage.saveOnboardingComplete(true);
                            await storage.clearRegistrationData();

                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                'navbar',
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              final errorMsg =
                                  e.toString().replaceAll('Exception: ', '');
                              ToastService().showToast(
                                context,
                                errorMsg,
                                type: ToastType.error,
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
