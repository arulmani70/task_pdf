import 'dart:io';

import 'package:task_pdf/src/common/common.dart';
import 'package:task_pdf/src/common/constants/constansts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class PermissionResult {
  final bool granted;
  final bool permanentlyDenied;
  final String? deniedMessage;
  final Map<String, dynamic>? detailedStatus;

  PermissionResult({
    required this.granted,
    this.permanentlyDenied = false,
    this.deniedMessage,
    this.detailedStatus,
  });
}

class BaseRepository {
  final log = Logger();
  final ApiRepository apiRepo;
  final PreferencesRepository prefRepo;

  BaseRepository({required this.apiRepo, required this.prefRepo});

  String _permissionKey(String userId, String email) {
    return 'storage_permission_${userId}_$email';
  }

  /// Platform-specific storage permission check
  Future<bool> checkStoragePermission() async {
    log.d('BaseRepository::checkStoragePermission::Starting permission check');
    final result = await PermissionUtils.checkStoragePermission();
    log.d(
      'BaseRepository::checkStoragePermission::Permission check result: $result',
    );
    return result;
  }

  /// Platform-specific storage permission request
  Future<bool> requestStoragePermission() async {
    return await PermissionUtils.requestStoragePermission();
  }

  /// Platform-specific storage permission ensure method with detailed result
  Future<PermissionResult> ensureStoragePermission(
    String userId,
    String email,
  ) async {
    log.d(
      'BaseRepository::ensureStoragePermission::Starting permission check: ${PermissionUtils.getPlatformInfo()}',
    );

    final hasPermission = await checkStoragePermission();
    log.d(
      'BaseRepository::ensureStoragePermission::Current permission status: $hasPermission',
    );

    if (hasPermission) {
      await prefRepo.savePreference(_permissionKey(userId, email), 'true');
      log.d(
        'BaseRepository::ensureStoragePermission::Storage permission already granted, returning success',
      );
      return PermissionResult(granted: true);
    }

    log.d(
      'BaseRepository::ensureStoragePermission::Permission not granted, requesting permission',
    );
    final requested = await requestStoragePermission();
    log.d(
      'BaseRepository::ensureStoragePermission::Permission request completed: $requested',
    );

    // Log detailed permission status for debugging
    Map<String, dynamic>? detailedStatus;
    if (Platform.isAndroid) {
      detailedStatus = await PermissionUtils.getDetailedPermissionStatus();
      log.d(
        'BaseRepository::ensureStoragePermission::Detailed Android permission status: $detailedStatus',
      );
    }

    if (!requested) {
      log.w(
        'BaseRepository::ensureStoragePermission::Permission request failed, checking if permanently denied',
      );

      // Check if permission is permanently denied
      bool permanentlyDenied = false;
      String deniedMessage =
          'Storage permission is required for this app to function properly.';

      if (Platform.isAndroid) {
        final permissions = PermissionUtils.getAndroidStoragePermissions();
        for (final permission in permissions) {
          final status = await permission.status;
          if (status.isPermanentlyDenied) {
            permanentlyDenied = true;
            break;
          }
        }

        if (permanentlyDenied) {
          deniedMessage =
              'Storage permission has been permanently denied. Please enable it in app settings to use file management features.';
        } else {
          deniedMessage =
              'Storage permission was denied. Please grant permission to use file management features.';
        }
      } else if (Platform.isIOS) {
        final photosStatus = await Permission.photos.status;
        if (photosStatus.isPermanentlyDenied) {
          permanentlyDenied = true;
          deniedMessage =
              'Photo library access has been permanently denied. Please enable it in Settings > Privacy & Security > Photos to use file management features.';
        } else {
          deniedMessage =
              'Photo library access was denied. Please grant permission to use file management features.';
        }
      }

      await prefRepo.savePreference(_permissionKey(userId, email), 'false');
      log.w(
        'BaseRepository::ensureStoragePermission::Permission denied, permanently denied: $permanentlyDenied, message: $deniedMessage',
      );

      return PermissionResult(
        granted: false,
        permanentlyDenied: permanentlyDenied,
        deniedMessage: deniedMessage,
        detailedStatus: detailedStatus,
      );
    }

    await prefRepo.savePreference(_permissionKey(userId, email), 'true');
    log.d(
      'BaseRepository::ensureStoragePermission::Permission granted successfully',
    );
    return PermissionResult(granted: true, detailedStatus: detailedStatus);
  }

  Future<Map<String, bool>> isAppInit(String userId, String email) async {
    Map<String, bool> initMap = {};
    try {
      log.d("BaseRepository:::isAppInit for user $userId, $email");

      final permissionString =
          await prefRepo.getPreference(_permissionKey(userId, email)) ??
          "false";
      final initializedString =
          await prefRepo.getPreference(Constants.store.INITIALIZED) ?? "false";

      initMap[Constants.store.PERMISSION] =
          permissionString.toLowerCase() == 'true';
      initMap[Constants.store.INITIALIZED] =
          initializedString.toLowerCase() == 'true';

      log.d(
        "BaseRepository::isAppInit: permission=${initMap[Constants.store.PERMISSION]}, initialized=${initMap[Constants.store.INITIALIZED]}",
      );
    } catch (error) {
      log.e("BaseRepository:::isAppInit:Error::$error");
    }

    return initMap;
  }

  /// Clear stored permission for a user
  Future<void> clearStoredPermission(String userId, String email) async {
    await prefRepo.savePreference(_permissionKey(userId, email), 'false');
    log.d(
      "BaseRepository::clearStoredPermission: Cleared permission for user $userId",
    );
  }

  /// Clear all stored app initialization data for a user (for testing)
  Future<void> clearAllStoredData(String userId, String email) async {
    await prefRepo.savePreference(_permissionKey(userId, email), 'false');
    await prefRepo.savePreference(Constants.store.INITIALIZED, 'false');
    log.d(
      "BaseRepository::clearAllStoredData: Cleared all stored data for user $userId",
    );
  }
}
