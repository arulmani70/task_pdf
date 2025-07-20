// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:task_pdf/src/common/common.dart';
// import 'package:task_pdf/src/base/bloc/base_bloc.dart';
// import 'package:task_pdf/src/common/widgets/permission_alert_widget.dart';

// /// Mixin that provides permission alert functionality
// mixin PermissionAlertMixin<T extends StatefulWidget> on State<T> {
//   /// Show permission alert when permission is denied
//   void showPermissionAlert(BuildContext context, BaseState state) {
//     if (state.isPermissionDenied && state.permissionDeniedMessage != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         showDialog<void>(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return StoragePermissionAlertWidget(
//               onSettingsPressed: () {
//                 Navigator.of(context).pop();
//                 PermissionAlertUtil.openAppSettings();
//               },
//               onCancelPressed: () {
//                 Navigator.of(context).pop();
//                 // Optionally retry permission request
//                 // Note: Replace with actual user data when implementing
//               },
//             );
//           },
//         );
//       });
//     }
//   }

//   /// Show custom permission alert
//   void showCustomPermissionAlert(
//     BuildContext context, {
//     required String title,
//     required String message,
//     required String settingsMessage,
//     VoidCallback? onSettingsPressed,
//     VoidCallback? onCancelPressed,
//   }) {
//     showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return PermissionAlertWidget(
//           title: title,
//           message: message,
//           settingsMessage: settingsMessage,
//           onSettingsPressed: onSettingsPressed,
//           onCancelPressed: onCancelPressed,
//         );
//       },
//     );
//   }

//   /// Show permission status summary (for debugging)
//   void showPermissionStatusSummary(BuildContext context) {
//     PermissionAlertUtil.showPermissionStatusSummary(context);
//   }

//   /// Handle permission state changes
//   void handlePermissionStateChange(BuildContext context, BaseState state) {
//     switch (state.status) {
//       case BaseStatus.permissionDenied:
//         showPermissionAlert(context, state);
//         break;
//       case BaseStatus.error:
//         if (state.message?.contains('permission') == true) {
//           showPermissionAlert(context, state);
//         }
//         break;
//       default:
//         // Handle other states as needed
//         break;
//     }
//   }
// }

// /// Example usage in a StatefulWidget
// class ExamplePermissionView extends StatefulWidget {
//   const ExamplePermissionView({super.key});

//   @override
//   State<ExamplePermissionView> createState() => _ExamplePermissionViewState();
// }

// class _ExamplePermissionViewState extends State<ExamplePermissionView> with PermissionAlertMixin {
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<BaseBloc, BaseState>(
//       listener: (context, state) {
//         handlePermissionStateChange(context, state);
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Example View'),
//           actions: [IconButton(icon: const Icon(Icons.info), onPressed: () => showPermissionStatusSummary(context))],
//         ),
//         body: BlocBuilder<BaseBloc, BaseState>(
//           builder: (context, state) {
//             if (state.status == BaseStatus.permissionDenied) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
//                     const SizedBox(height: 16),
//                     Text('Permission Required', style: Theme.of(context).textTheme.headlineSmall),
//                     const SizedBox(height: 8),
//                     Text(
//                       state.permissionDeniedMessage ?? 'Storage permission is required',
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(onPressed: () => PermissionAlertUtil.openAppSettings(), child: const Text('Open Settings')),
//                   ],
//                 ),
//               );
//             }

//             return const Center(child: Text('App is ready!'));
//           },
//         ),
//       ),
//     );
//   }
// }
