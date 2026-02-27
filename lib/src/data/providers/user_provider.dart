import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/secure_storage_service.dart';

class UserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    _loadUser();
    return null;
  }

  Future<void> _loadUser() async {
    final storage = ref.read(secureStorageServiceProvider);
    state = await storage.getUserData();
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
}

final userProvider = NotifierProvider<UserNotifier, UserModel?>(UserNotifier.new);
