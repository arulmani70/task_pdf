import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

/// Utility class for handling platform-specific permissions
class PermissionUtils {
  static final Logger _log = Logger();

  /// Get the appropriate storage permission for the current platform
  static Permission getStoragePermission() {
    if (Platform.isAndroid) {
      return Permission.storage;
    } else if (Platform.isIOS) {
      return Permission.photos;
    } else {
      // For desktop and web platforms, return a dummy permission
      return Permission.storage;
    }
  }

  /// Get all necessary storage permissions for Android
  static List<Permission> getAndroidStoragePermissions() {
    return [Permission.storage, Permission.manageExternalStorage, Permission.photos, Permission.videos, Permission.audio];
  }

  /// Check if storage permission is required for the current platform
  static bool isStoragePermissionRequired() {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Get platform-specific permission name for logging
  static String getStoragePermissionName() {
    if (Platform.isAndroid) {
      return 'Storage (Android)';
    } else if (Platform.isIOS) {
      return 'Photos (iOS)';
    } else {
      return 'None (Desktop/Web)';
    }
  }

  /// Check storage permission status
  static Future<bool> checkStoragePermission() async {
    _log.d('PermissionUtils::checkStoragePermission::Starting check');

    if (!isStoragePermissionRequired()) {
      _log.d('Storage permission not required for ${Platform.operatingSystem}');
      return true;
    }

    if (Platform.isAndroid) {
      _log.d('PermissionUtils::checkStoragePermission::Checking Android permissions');
      final result = await _checkAndroidStoragePermissions();
      _log.d('PermissionUtils::checkStoragePermission::Android check result: $result');
      return result;
    } else if (Platform.isIOS) {
      _log.d('PermissionUtils::checkStoragePermission::Checking iOS permissions');
      final permission = getStoragePermission();
      final status = await permission.status;
      _log.d('${getStoragePermissionName()} permission status: $status');
      final result = status.isGranted;
      _log.d('PermissionUtils::checkStoragePermission::iOS check result: $result');
      return result;
    }

    _log.d('PermissionUtils::checkStoragePermission::Default case, returning true');
    return true;
  }

  /// Check Android storage permissions comprehensively
  static Future<bool> _checkAndroidStoragePermissions() async {
    _log.d('PermissionUtils::_checkAndroidStoragePermissions::Starting comprehensive check');
    final permissions = getAndroidStoragePermissions();
    Map<Permission, PermissionStatus> statuses = {};

    _log.d('PermissionUtils::_checkAndroidStoragePermissions::Checking ${permissions.length} permissions');

    for (final permission in permissions) {
      final status = await permission.status;
      statuses[permission] = status;
      _log.d('Android ${permission.toString()} permission status: $status');
    }

    // Check if critical permissions are granted (same logic as request)
    bool storageGranted = statuses[Permission.storage]?.isGranted ?? false;
    bool photosGranted = statuses[Permission.photos]?.isGranted ?? false;
    bool manageStorageGranted = statuses[Permission.manageExternalStorage]?.isGranted ?? false;

    // For Android, we need at least storage or photos permission (same as request logic)
    bool hasCriticalPermission = storageGranted || photosGranted || manageStorageGranted;

    _log.d(
      'PermissionUtils::_checkAndroidStoragePermissions::Critical permissions - storage: $storageGranted, photos: $photosGranted, manage: $manageStorageGranted',
    );
    _log.d('PermissionUtils::_checkAndroidStoragePermissions::Final result - hasCriticalPermission: $hasCriticalPermission');

    return hasCriticalPermission;
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    if (!isStoragePermissionRequired()) {
      _log.d('Storage permission not required for ${Platform.operatingSystem}');
      return true;
    }

    if (Platform.isAndroid) {
      return await _requestAndroidStoragePermissions();
    } else if (Platform.isIOS) {
      final permission = getStoragePermission();
      final status = await permission.request();
      _log.d('${getStoragePermissionName()} permission request result: $status');
      return status.isGranted;
    }

    return true;
  }

  /// Request Android storage permissions comprehensively
  static Future<bool> _requestAndroidStoragePermissions() async {
    final permissions = getAndroidStoragePermissions();
    Map<Permission, PermissionStatus> statuses = {};

    // Request all permissions
    for (final permission in permissions) {
      final status = await permission.request();
      statuses[permission] = status;
      _log.d('Android ${permission.toString()} permission request result: $status');
    }

    // Check if all critical permissions are granted
    bool storageGranted = statuses[Permission.storage]?.isGranted ?? false;
    bool photosGranted = statuses[Permission.photos]?.isGranted ?? false;
    bool manageStorageGranted = statuses[Permission.manageExternalStorage]?.isGranted ?? false;

    // For Android, we need at least storage or photos permission
    return storageGranted || photosGranted || manageStorageGranted;
  }

  /// Get detailed permission status for debugging
  static Future<Map<String, PermissionStatus>> getDetailedPermissionStatus() async {
    if (!Platform.isAndroid) {
      return {};
    }

    final permissions = getAndroidStoragePermissions();
    Map<String, PermissionStatus> statuses = {};

    for (final permission in permissions) {
      final status = await permission.status;
      statuses[permission.toString()] = status;
    }

    return statuses;
  }

  /// Get platform information for debugging
  static String getPlatformInfo() {
    return 'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
  }

  /// Check if the device supports scoped storage (Android 10+)
  static bool supportsScopedStorage() {
    if (!Platform.isAndroid) return false;

    // This is a simplified check - in a real app, you'd check the actual API level
    // For now, we'll assume modern Android versions support scoped storage
    return true;
  }
}
