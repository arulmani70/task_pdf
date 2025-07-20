import 'package:flutter/material.dart';
import 'package:task_pdf/src/common/common.dart';

/// A widget that shows permission alerts when permissions are denied
class PermissionAlertWidget extends StatelessWidget {
  final String title;
  final String message;
  final String settingsMessage;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onCancelPressed;
  final bool showCancelButton;

  const PermissionAlertWidget({
    super.key,
    required this.title,
    required this.message,
    required this.settingsMessage,
    this.onSettingsPressed,
    this.onCancelPressed,
    this.showCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
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
        if (showCancelButton)
          TextButton(
            onPressed: onCancelPressed ?? () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onSettingsPressed?.call();
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
  }
}

/// A widget that shows storage permission denied alert
class StoragePermissionAlertWidget extends StatelessWidget {
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onCancelPressed;

  const StoragePermissionAlertWidget({super.key, this.onSettingsPressed, this.onCancelPressed});

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    String title, message, settingsMessage;

    switch (platform) {
      case TargetPlatform.android:
        title = 'Storage Permission Required';
        message =
            'This app needs access to your device storage to save and manage PDF files. Without this permission, you won\'t be able to use the file management features.';
        settingsMessage = 'Go to Settings > Apps > TaskPDF > Permissions to enable storage access.';
        break;
      case TargetPlatform.iOS:
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

    return PermissionAlertWidget(
      title: title,
      message: message,
      settingsMessage: settingsMessage,
      onSettingsPressed: onSettingsPressed ?? () => PermissionAlertUtil.openAppSettings(),
      onCancelPressed: onCancelPressed,
    );
  }
}
