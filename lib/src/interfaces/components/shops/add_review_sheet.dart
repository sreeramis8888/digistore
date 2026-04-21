import 'dart:io';
import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/models/redemption_model.dart';
import 'package:digistore/src/data/models/shop_model.dart';
import 'package:digistore/src/data/providers/api_provider.dart';
import 'package:digistore/src/data/providers/reviews_provider.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:digistore/src/interfaces/components/advanced_network_image.dart';
import 'package:digistore/src/interfaces/components/loading_indicator.dart';
import 'package:digistore/src/interfaces/components/primary_button.dart';
import 'package:digistore/src/interfaces/components/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/image_services.dart' as img_service;
import '../../../data/services/toast_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AddReviewSheet extends ConsumerStatefulWidget {
  final ShopModel shop;

  const AddReviewSheet({super.key, required this.shop});

  @override
  ConsumerState<AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends ConsumerState<AddReviewSheet> {
  int _currentStep = 0;
  List<RedemptionModel> _redemptions = [];
  RedemptionModel? _selectedRedemption;
  bool _isLoadingRedemptions = true;
  
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<File> _pickedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchRedemptions();
  }

  Future<void> _fetchRedemptions() async {
    final response = await ref.read(reviewsActionProvider.notifier).getShopRedemptions(widget.shop.id!);
    
    if (mounted) {
      setState(() {
        _redemptions = response?.data.where((r) => r.hasReview != true).toList() ?? [];
        _isLoadingRedemptions = false;
        
        if (_redemptions.length == 1) {
          _selectedRedemption = _redemptions.first;
          _currentStep = 1;
        } else if (_redemptions.isEmpty) {
          // Handle no redemptions (shouldn't happen if canSubmitReview was true)
        }
      });
    }
  }

  Future<void> _pickImages() async {
    final result = await img_service.pickMedia(
      context: context,
      allowMultiple: true,
      enableCrop: false,
      showDocument: false,
    );

    if (result is List<XFile>) {
      final newFiles = result.map((e) => File(e.path)).toList();
      for (int i = 0; i < newFiles.length; i++) {
        newFiles[i] = await img_service.compressImageIfNeeded(newFiles[i]);
      }
      setState(() {
        _pickedImages.addAll(newFiles);
      });
    } else if (result is XFile) {
      File compressedFile = await img_service.compressImageIfNeeded(File(result.path));
      setState(() {
        _pickedImages.add(compressedFile);
      });
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ToastService().showToast(context, 'Please select a rating', type: ToastType.error);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(reviewsActionProvider.notifier);
      
      final success = await notifier.submitReview(
        partnerId: widget.shop.id!,
        rating: _rating,
        comment: _commentController.text.trim(),
        images: _pickedImages,
        redemptionId: _selectedRedemption!.id!,
      );

      if (success && mounted) {
        ToastService().showToast(context, 'Review submitted successfully!');
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          Expanded(
            child: _isLoadingRedemptions 
              ? const Center(child: LoadingAnimation())
              : _redemptions.isEmpty 
                  ? _buildEmptyState()
                  : _buildContent(screenSize),
          ),
          _buildBottomButton(screenSize),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: kGreyLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.rate_review_outlined, size: 64, color: kGreyLight),
        const SizedBox(height: 16),
        Text('No eligible offers to review', style: kSmallTitleB),
        const SizedBox(height: 8),
        Text('Redeem an offer first to share your experience!', 
          style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(ScreenSizeData screenSize) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero
          ).animate(animation),
          child: child,
        ));
      },
      child: _currentStep == 0 
        ? _buildRedemptionSelection(screenSize) 
        : _buildReviewForm(screenSize),
    );
  }

  Widget _buildRedemptionSelection(ScreenSizeData screenSize) {
    return SingleChildScrollView(
      key: const ValueKey('selection'),
      padding: EdgeInsets.all(screenSize.responsivePadding(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select an Offer', style: kBodyTitleB),
          SizedBox(height: screenSize.responsivePadding(8)),
          Text('Which offer would you like to review?', 
            style: kSmallTitleR.copyWith(color: kSecondaryTextColor)),
          SizedBox(height: screenSize.responsivePadding(24)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _redemptions.length,
            separatorBuilder: (_, __) => SizedBox(height: screenSize.responsivePadding(16)),
            itemBuilder: (context, index) {
              final redemption = _redemptions[index];
              final isSelected = _selectedRedemption?.id == redemption.id;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedRedemption = redemption),
                child: Container(
                  padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryColor.withOpacity(0.05) : kWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? kPrimaryColor : kGreyLight.withOpacity(0.5),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: screenSize.responsivePadding(60),
                        height: screenSize.responsivePadding(60),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kGreyLight.withOpacity(0.2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AdvancedNetworkImage(
                          imageUrl: redemption.offerId?.images?.isNotEmpty == true 
                            ? redemption.offerId!.images!.first 
                            : '',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: screenSize.responsivePadding(16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(redemption.offerId?.title ?? 'Untitled Offer', 
                              style: kSmallTitleB),
                            SizedBox(height: screenSize.responsivePadding(4)),
                            Text('Redeemed on ${_formatDate(redemption.redeemedAt)}', 
                              style: kSmallerTitleR.copyWith(color: kSecondaryTextColor)),
                          ],
                        ),
                      ),
                      if (isSelected) 
                        const Icon(Icons.check_circle, color: kPrimaryColor),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewForm(ScreenSizeData screenSize) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: EdgeInsets.all(screenSize.responsivePadding(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_redemptions.length > 1)
                IconButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (_redemptions.length > 1) SizedBox(width: screenSize.responsivePadding(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Write a Review', style: kBodyTitleB),
                    Text(_selectedRedemption?.offerId?.title ?? 'Share your experience', 
                      style: kSmallTitleR.copyWith(color: kSecondaryTextColor)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.responsivePadding(32)),
          Center(
            child: Column(
              children: [
                Text('How was your experience?', style: kSmallTitleM),
                SizedBox(height: screenSize.responsivePadding(16)),
                _buildStarRating(screenSize),
                SizedBox(height: screenSize.responsivePadding(8)),
                Text(_getRatingText(), style: kSmallTitleB.copyWith(color: kPrimaryColor)),
              ],
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(32)),
          PrimaryTextField(
            controller: _commentController,
            label: 'Comment',
            hint: 'Describe your experience...',
            maxLines: 5,
          ),
          SizedBox(height: screenSize.responsivePadding(24)),
          Text('Add Photos', style: kSmallTitleM),
          SizedBox(height: screenSize.responsivePadding(12)),
          _buildImagePicker(screenSize),
        ],
      ),
    );
  }

  Widget _buildStarRating(ScreenSizeData screenSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final isSelected = _rating >= starValue;
        
        return GestureDetector(
          onTap: () => setState(() => _rating = starValue),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 1.0),
            duration: const Duration(milliseconds: 200),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isSelected ? const Color(0xFFFFD700) : kGreyLight,
                  size: screenSize.responsivePadding(42),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  String _getRatingText() {
    if (_rating == 0) return 'Select Rating';
    if (_rating <= 1) return 'Poor';
    if (_rating <= 2) return 'Fair';
    if (_rating <= 3) return 'Good';
    if (_rating <= 4) return 'Very Good';
    return 'Excellent!';
  }

  Widget _buildImagePicker(ScreenSizeData screenSize) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: screenSize.responsivePadding(80),
              height: screenSize.responsivePadding(80),
              decoration: BoxDecoration(
                color: kGreyLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kGreyLight.withOpacity(0.3)),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: kSecondaryTextColor),
            ),
          ),
          ...List.generate(_pickedImages.length, (index) {
            return Container(
              margin: EdgeInsets.only(left: screenSize.responsivePadding(12)),
              width: screenSize.responsivePadding(80),
              height: screenSize.responsivePadding(80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: FileImage(_pickedImages[index]),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedImages.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: kWhite, size: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomButton(ScreenSizeData screenSize) {
    final showSubmit = _currentStep == 1 || (_redemptions.length <= 1 && _redemptions.isNotEmpty);
    
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(24),
          vertical: screenSize.responsivePadding(16),
        ),
        child: PrimaryButton(
          text: showSubmit ? 'Submit Review' : 'Next',
          isLoading: _isSubmitting,
          onPressed: () {
            if (showSubmit) {
              _submitReview();
            } else {
              if (_selectedRedemption != null) {
                setState(() => _currentStep = 1);
              } else {
                ToastService().showToast(context, 'Please select an offer', type: ToastType.error);
              }
            }
          },
          backgroundColor: kPrimaryColor,
          textColor: kWhite,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day} ${_getMonth(date.month)}, ${date.year}';
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
