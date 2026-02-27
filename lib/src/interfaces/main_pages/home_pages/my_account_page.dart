import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../components/primary_button.dart';
import '../../components/primary_text_field.dart';

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

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _mobileController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
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
                      ] else ...[
                        _buildReadOnlyField('Name', _nameController.text),
                        _buildReadOnlyField('Mobile Number', _mobileController.text),
                        _buildReadOnlyField('Email', _emailController.text),
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
                    final currUser = ref.read(userProvider);
                    if (currUser != null) {
                      final updated = currUser.copyWith(
                        name: _nameController.text,
                        email: _emailController.text,
                      );
                      await ref.read(userProvider.notifier).saveUser(updated);
                    }
                    if (context.mounted) Navigator.pop(context);
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
