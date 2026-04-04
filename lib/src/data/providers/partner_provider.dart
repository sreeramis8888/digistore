import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/partner_model.dart';
import '../models/business_details.dart';
import '../models/business_info.dart';
import 'api_provider.dart';

class PartnerNotifier extends Notifier<PartnerModel?> {
  @override
  PartnerModel? build() => null;

  Future<void> savePartner(PartnerModel partner) async {
    // We can store partner data in a separate key in secure storage if needed
    // For now, let's just keep it in memory
    state = partner;
  }

  Future<void> clearPartner() async {
    state = null;
  }

  Future<int?> getPartnerProfile() async {
    final api = ref.read(apiProvider);
    final response = await api.get('/profile', requireAuth: true);

    if (response.success && response.data != null) {
      final partnerData = response.data!['data'];
      if (partnerData != null) {
        final partner = PartnerModel.fromJson(partnerData as Map<String, dynamic>);
        state = partner;
        return 200;
      }
    }
    return response.statusCode;
  }

  Future<bool> updateProfile({
    String? ownerName,
    String? email,
    String? shopName,
    String? contactPhone,
    String? whatsappNumber,
    String? address,
    String? pincode,
  }) async {
    // In a real app, we'd send a PUT/PATCH request
    // For now, we update local state to reflect changes
    if (state != null) {
      final updatedPartner = PartnerModel(
        id: state!.id,
        userId: state!.userId,
        businessDetails: BusinessDetails(
          businessName: shopName ?? state!.businessDetails?.businessName,
          address: address ?? state!.businessDetails?.address,
          pincode: pincode ?? state!.businessDetails?.pincode,
          businessType: state!.businessDetails?.businessType,
          registrationNumber: state!.businessDetails?.registrationNumber,
          gstNumber: state!.businessDetails?.gstNumber,
        ),
        businessInfo: BusinessInfo(
          contactPhone: contactPhone ?? state!.businessInfo?.contactPhone,
          whatsappNumber: whatsappNumber ?? state!.businessInfo?.whatsappNumber,
          email: email ?? state!.businessInfo?.email,
          ownerName: ownerName ?? state!.businessInfo?.ownerName,
          businessLogo: state!.businessInfo?.businessLogo,
          coverImage: state!.businessInfo?.coverImage,
          description: state!.businessInfo?.description,
          tagline: state!.businessInfo?.tagline,
          operatingHours: state!.businessInfo?.operatingHours,
          socialLinks: state!.businessInfo?.socialLinks,
          storeLocation: state!.businessInfo?.storeLocation,
        ),
        coverageAreas: state!.coverageAreas,
        serviceCategories: state!.serviceCategories,
        incomeSharingPercentage: state!.incomeSharingPercentage,
        verificationStatus: state!.verificationStatus,
        isActive: state!.isActive,
        isFeatured: state!.isFeatured,
        isPremium: state!.isPremium,
        tags: state!.tags,
        totalLeads: state!.totalLeads,
        convertedLeads: state!.convertedLeads,
        totalRevenue: state!.totalRevenue,
        paymentDetails: state!.paymentDetails,
        documents: state!.documents,
        createdAt: state!.createdAt,
        updatedAt: DateTime.now(),
      );
      state = updatedPartner;
      return true;
    }
    return false;
  }
}

final partnerProvider = NotifierProvider<PartnerNotifier, PartnerModel?>(PartnerNotifier.new);
