import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/partner_model.dart';
import 'api_provider.dart';
import '../utils/map_utils.dart';

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
        final partner = PartnerModel.fromJson(
          partnerData as Map<String, dynamic>,
        );
        state = partner;
        return 200;
      }
    }
    return response.statusCode;
  }

  Future<bool> updateProfile(
    PartnerModel updatedPartner, {
    List<http.MultipartFile>? files,
    String? uploadField,
  }) async {
    final api = ref.read(apiProvider);

    ApiResponse<Map<String, dynamic>> response;

    if (files != null && files.isNotEmpty) {
      final body = <String, String>{};

      final businessDetailsMap = updatedPartner.businessDetails?.toJson();
      if (businessDetailsMap != null) {
        final cleaned = MapUtils.cleanMap(businessDetailsMap);
        if (cleaned.isNotEmpty) body['businessDetails'] = json.encode(cleaned);
      }

      final businessInfoMap = updatedPartner.businessInfo?.toJson();
      if (businessInfoMap != null) {
        final cleaned = MapUtils.cleanMap(businessInfoMap);
        if (cleaned.isNotEmpty) body['businessInfo'] = json.encode(cleaned);
      }

      if (uploadField != null) {
        body['uploadField'] = uploadField;
      }

      response = await api.putMultipart(
        '/profile',
        body,
        files: files,
        requireAuth: true,
      );
    } else {
      final cleanedData = MapUtils.cleanMap(updatedPartner.toJson());
      response = await api.put('/profile', cleanedData, requireAuth: true);
    }

    if (response.success && response.data != null) {
      final partnerData = response.data!['data'];
      if (partnerData != null) {
        state = PartnerModel.fromJson(partnerData as Map<String, dynamic>);
        return true;
      }
    }
    return false;
  }
}

final partnerProvider = NotifierProvider<PartnerNotifier, PartnerModel?>(
  PartnerNotifier.new,
);
