import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/services/secure_storage_service.dart';
import '../../../data/models/user_model.dart';

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
                        hint: 'Enter Location',
                        controller: _locationController,
                        isRequired: true,
                      ),
                      SizedBox(height: screenSize.responsivePadding(40)),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                text: 'Submit',
                onPressed: () async {
                  final user = UserModel(
                    name: _nameController.text,
                    phone: _mobileController.text,
                    email: _emailController.text,
                    district: DistrictDetailModel(name: _locationController.text),
                  );
                  await ref.read(userProvider.notifier).saveUser(user);
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      'navbar',
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
