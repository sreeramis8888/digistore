import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/global_variables.dart';
import '../services/secure_storage_service.dart';

enum UserType { customer, partner }

class UserTypeNotifier extends Notifier<UserType> {
  @override
  UserType build() {
    return GlobalVariables.isPartner ? UserType.partner : UserType.customer;
  }

  void setUserType(UserType type) {
    state = type;
    final isPartner = type == UserType.partner;
    GlobalVariables.setPartnerMode(isPartner);
    ref.read(secureStorageServiceProvider).saveIsPartner(isPartner);
  }

  void toggle() {
    final nextType = (state == UserType.customer)
        ? UserType.partner
        : UserType.customer;
    setUserType(nextType);
  }
}

final userTypeProvider = NotifierProvider<UserTypeNotifier, UserType>(
  UserTypeNotifier.new,
);
