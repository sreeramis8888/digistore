import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'api_provider.dart';

class AppVersionData {
  final String minSupportedVersion;
  final String latestVersion;
  final String? updateUrl;
  final bool isMaintenanceMode;
  final String? maintenanceMessage;

  AppVersionData({
    required this.minSupportedVersion,
    required this.latestVersion,
    this.updateUrl,
    required this.isMaintenanceMode,
    this.maintenanceMessage,
  });

  factory AppVersionData.fromJson(Map<String, dynamic> json) {
    return AppVersionData(
      minSupportedVersion: json['minSupportedVersion'] ?? '1.0.0',
      latestVersion: json['latestVersion'] ?? '1.0.0',
      updateUrl: json['updateUrl'],
      isMaintenanceMode: json['isMaintenanceMode'] ?? false,
      maintenanceMessage: json['maintenanceMessage'],
    );
  }
}

class AppVersionCheckResult {
  final bool needsHardUpdate;
  final bool needsSoftUpdate;
  final bool isMaintenanceMode;
  final AppVersionData? data;

  AppVersionCheckResult({
    required this.needsHardUpdate,
    required this.needsSoftUpdate,
    required this.isMaintenanceMode,
    this.data,
  });
}

class AppVersionNotifier extends StateNotifier<AsyncValue<AppVersionCheckResult>> {
  final ApiProvider _api;

  AppVersionNotifier(this._api) : super(const AsyncValue.loading());

  Future<AppVersionCheckResult> checkAppVersion() async {
    try {
      state = const AsyncValue.loading();
      
      String platform = Platform.isIOS ? 'ios' : 'android';
      final response = await _api.get('/app-version?platform=$platform', requireAuth: false);
      
      if (!response.success || response.data == null || response.data!['data'] == null) {
        final res = AppVersionCheckResult(
          needsHardUpdate: false, 
          needsSoftUpdate: false, 
          isMaintenanceMode: false
        );
        state = AsyncValue.data(res);
        return res;
      }

      final appVersionData = AppVersionData.fromJson(response.data!['data']);
      
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      
      log('Current App Version: $currentVersion', name: 'AppVersionProvider');

      bool needsHardUpdate = _compareVersions(currentVersion, appVersionData.minSupportedVersion) < 0;
      bool needsSoftUpdate = !needsHardUpdate && _compareVersions(currentVersion, appVersionData.latestVersion) < 0;
      
      final result = AppVersionCheckResult(
        needsHardUpdate: needsHardUpdate,
        needsSoftUpdate: needsSoftUpdate,
        isMaintenanceMode: appVersionData.isMaintenanceMode,
        data: appVersionData,
      );
      
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return AppVersionCheckResult(
        needsHardUpdate: false, 
        needsSoftUpdate: false, 
        isMaintenanceMode: false
      );
    }
  }

  int _compareVersions(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    List<int> v2Parts = v2.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      int p1 = i < v1Parts.length ? v1Parts[i] : 0;
      int p2 = i < v2Parts.length ? v2Parts[i] : 0;
      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    return 0;
  }
}

final appVersionProvider = StateNotifierProvider<AppVersionNotifier, AsyncValue<AppVersionCheckResult>>((ref) {
  final api = ref.watch(publicApiProvider);
  return AppVersionNotifier(api);
});
