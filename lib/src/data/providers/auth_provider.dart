import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/secure_storage_service.dart';
import 'user_provider.dart';
import 'partner_provider.dart';
import '../utils/global_variables.dart';
import 'api_provider.dart';
import 'user_type_provider.dart';
import '../models/partner_model.dart';

class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> sendOtp(String phone) async {
    state = const AsyncLoading();
    try {
      final api = ref.read(apiProvider);
      final response = await api.post('/auth/send-otp', {
        'phone': phone,
      }, requireAuth: false);

      if (response.success && response.data?['success'] == true) {
        state = const AsyncData(null);
        if (response.data != null && response.data!['_devOtp'] != null) {
          log('DEV OTP: ${response.data!['_devOtp']}', name: 'OTP');
        }
        return true;
      } else {
        throw Exception(response.message ?? 'Failed to send OTP');
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    state = const AsyncLoading();
    try {
      final api = ref.read(apiProvider);
      final response = await api.post('/auth/verify-otp', {
        'phone': phone,
        'otp': otp,
      }, requireAuth: false);

      if (response.success && response.data?['success'] == true) {
        final responseData = response.data!;
        final token = responseData['data']?['token'];
        final userData = responseData['data']?['user'];
        final isNewUser = responseData['data']?['isNewUser'] ?? false;
        final onboardingComplete =
            responseData['data']?['onboardingComplete'] ?? false;

        final storage = ref.read(secureStorageServiceProvider);
        if (token != null) {
          await storage.saveBearerToken(token);
        }
        
        // Skip profile setup for partners by forcing onboardingComplete to true
        final userType = ref.read(userTypeProvider);
        final effectiveOnboardingComplete = (userType == UserType.partner) ? true : onboardingComplete;
        
        await storage.saveOnboardingComplete(effectiveOnboardingComplete);

        if (userType == UserType.customer && userData != null) {
          final userModel = UserModel.fromJson(userData);
          await ref.read(userProvider.notifier).saveUser(userModel);
          GlobalVariables.setUserId(userModel.id);
        } else if (userType == UserType.partner) {
          final partnerData = responseData['data']?['partner'];
          if (partnerData != null) {
            final partnerModel = PartnerModel.fromJson(partnerData);
            await ref.read(partnerProvider.notifier).savePartner(partnerModel);
            GlobalVariables.setUserId(partnerModel.id);
          }
        }

        state = const AsyncData(null);
        return {
          'success': true,
          'onboardingComplete': effectiveOnboardingComplete,
          'isNewUser': isNewUser,
        };
      } else {
        throw Exception(response.message ?? 'Invalid OTP');
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return {'success': false, 'message': e.toString()};
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<void>>(
  AuthNotifier.new,
);
