import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionManagerService {
  /// Request location permission
  Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    
    return status.isGranted;
  }

  /// Check if location permission is granted
  Future<bool> isLocationEnabled() async {
    return await Permission.locationWhenInUse.isGranted;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  /// Generic permission check
  Future<bool> checkPermission(Permission permission) async {
    return await permission.isGranted;
  }
}

final permissionManagerServiceProvider = Provider<PermissionManagerService>((ref) {
  return PermissionManagerService();
});
