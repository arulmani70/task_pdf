import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:logger/logger.dart';

/// Utility class for handling permission denial alerts and navigation
class PermissionAlertUtil {
  static final Logger _log = Logger();

  /// Show permission denied alert with option to open settings
  static Future<void> showPermissionDeniedAlert(
    BuildContext context, {
    required String title,
    required String message,
    required String settingsMessage,
    required VoidCallback onSettingsPressed,
    VoidCallback? onCancelPressed,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(settingsMessage, style: TextStyle(color: Colors.blue.shade700, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: onCancelPressed ?? () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onSettingsPressed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Open Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// Show platform-specific storage permission denied alert
  static Future<void> showStoragePermissionDeniedAlert(BuildContext context) async {
    final platform = Platform.operatingSystem;
    String title, message, settingsMessage;

    switch (platform) {
      case 'android':
        title = 'Storage Permission Required';
        message =
            'This app needs access to your device storage to save and manage PDF files. Without this permission, you won\'t be able to use the file management features.';
        settingsMessage = 'Go to Settings > Apps > TaskPDF > Permissions to enable storage access.';
        break;
      case 'ios':
        title = 'Photo Library Access Required';
        message =
            'This app needs access to your photo library to save and manage PDF files. Without this permission, you won\'t be able to use the file management features.';
        settingsMessage = 'Go to Settings > Privacy & Security > Photos to enable access for TaskPDF.';
        break;
      default:
        title = 'Permission Required';
        message = 'This app needs storage access to function properly.';
        settingsMessage = 'Please check your system settings.';
    }

    await showPermissionDeniedAlert(
      context,
      title: title,
      message: message,
      settingsMessage: settingsMessage,
      onSettingsPressed: () => openAppSettings(),
    );
  }

  /// Show specific permission denied alert with custom messages
  static Future<void> showSpecificPermissionDeniedAlert(BuildContext context, String permissionName, String permissionDescription) async {
    final platform = Platform.operatingSystem;
    String settingsMessage;

    switch (platform) {
      case 'android':
        settingsMessage = 'Go to Settings > Apps > TaskPDF > Permissions to enable $permissionName.';
        break;
      case 'ios':
        settingsMessage = 'Go to Settings > Privacy & Security to enable $permissionName for TaskPDF.';
        break;
      default:
        settingsMessage = 'Please check your system settings for $permissionName.';
    }

    await showPermissionDeniedAlert(
      context,
      title: '$permissionName Permission Required',
      message: permissionDescription,
      settingsMessage: settingsMessage,
      onSettingsPressed: () => openAppSettings(),
    );
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    try {
      _log.d('Opening app settings...');
      await AppSettings.openAppSettings();
    } catch (e) {
      _log.e('Failed to open app settings: $e');
      // Fallback: try to open general settings
      try {
        await AppSettings.openAppSettings(type: AppSettingsType.settings);
      } catch (e) {
        _log.e('Failed to open general settings: $e');
      }
    }
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// Get permission status description
  static String getPermissionStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.provisional:
        return 'Provisional';
      default:
        return 'Unknown';
    }
  }

  /// Show permission status summary
  static Future<void> showPermissionStatusSummary(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final permissions = [Permission.storage, Permission.manageExternalStorage, Permission.photos, Permission.videos, Permission.audio];

    Map<String, PermissionStatus> statuses = {};
    for (final permission in permissions) {
      statuses[permission.toString()] = await permission.status;
    }

    String statusText = 'Permission Status:\n\n';
    statuses.forEach((permission, status) {
      statusText += '${permission.split('.').last}: ${getPermissionStatusDescription(status)}\n';
    });

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Status'),
          content: SingleChildScrollView(child: Text(statusText)),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
        );
      },
    );
  }
}
