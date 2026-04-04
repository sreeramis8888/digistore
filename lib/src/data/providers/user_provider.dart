import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/secure_storage_service.dart';
import 'api_provider.dart';

class UserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;

  Future<int?> getProfile() async {
    final api = ref.read(apiProvider);
    final response = await api.get('/profile', requireAuth: true);

    if (response.success && response.data != null) {
      final userData = response.data!['data'];
      if (userData != null) {
        final user = UserModel.fromJson(userData as Map<String, dynamic>);
        state = user;
        await saveUser(user);
        return 200;
      }
    }
    return response.statusCode;
  }

  Future<void> saveUser(UserModel user) async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveUserData(user);
    state = user;
  }

  Future<void> clearUser() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.clearAll();
    state = null;
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    bool? onboardingComplete,
  }) async {
    final api = ref.read(apiProvider);

    final Map<String, dynamic> payload = {
      'name': name,
      'email': email,
    };

    if (onboardingComplete != null) {
      payload['onboardingComplete'] = onboardingComplete;
    }

    final response = await api.put(
      '/profile',
      payload,
      requireAuth: true,
    );
    
    if (response.success && response.data != null) {
      final userData = response.data!['data'];
      if (userData != null) {
        final user = UserModel.fromJson(userData as Map<String, dynamic>);
        await saveUser(user);
      } else if (state != null) {
        final updatedUser = state!.copyWith(
          name: name,
          email: email,
          onboardingComplete: onboardingComplete,
        );
        await saveUser(updatedUser);
      }
      return true;
    }
    return false;
  }

  Future<bool> updateLocation({
    required double lat,
    required double lng,
    required String district,
    required String localBody,
  }) async {
    final api = ref.read(apiProvider);
    final response = await api.put(
      '/profile/location',
      {
        'lat': lat,
        'lng': lng,
        'district': district,
        'localBody': localBody,
      },
      requireAuth: true,
    );

    if (response.success && response.data != null) {
      final userData = response.data!['data'];
      if (userData != null) {
        final user = UserModel.fromJson(userData as Map<String, dynamic>);
        await saveUser(user);
      } else if (state != null) {
        final updatedUser = state!.copyWith(
          location: LocationModel(
            district: district,
            localBody: localBody,
            coordinates: CoordinatesModel(coordinates: [lng, lat]),
          ),
        );
        await saveUser(updatedUser);
      }
      return true;
    }
    return false;
  }
}

final userProvider = NotifierProvider<UserNotifier, UserModel?>(UserNotifier.new);
