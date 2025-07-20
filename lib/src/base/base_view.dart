import 'package:task_pdf/src/common/constants/constansts.dart';

import 'package:task_pdf/src/loigin_firebase/bloc/login_firebase_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_pdf/src/base/bloc/base_bloc.dart';
import 'package:task_pdf/src/app/route_names.dart';
import 'package:task_pdf/src/base/repository/base_repository.dart';
import 'package:task_pdf/src/common/common.dart';
import 'package:task_pdf/src/common/models/models.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'dart:async';

class BaseView extends StatefulWidget {
  const BaseView({super.key});

  @override
  State<BaseView> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  final log = Logger();
  Timer? _timeoutTimer;
  bool _hasTimedOut = false;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(const Duration(seconds: 45), () {
      if (mounted) {
        setState(() {
          _hasTimedOut = true;
        });
        log.w("BaseView::Timeout reached, showing fallback UI");
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UsersModel currentUser = context.select(
      (LoginFirebaseBloc bloc) => bloc.state.user,
    );

    log.d("BaseView::: In Build method::currentUser::${currentUser.toJson()}");

    return Scaffold(
      body: BlocProvider(
        create: (_) => BaseBloc(
          repository: BaseRepository(
            apiRepo: context.read<ApiRepository>(),
            prefRepo: context.read<PreferencesRepository>(),
          ),
        )..add(InitializeApp(currentUser: currentUser)),
        child: BlocConsumer<BaseBloc, BaseState>(
          listener: (context, state) {
            log.d("BaseView::Listener::Status changed to: ${state.status}");
            log.d(
              "BaseView::Listener::Permission denied: ${state.isPermissionDenied}",
            );
            log.d(
              "BaseView::Listener::Permission message: ${state.permissionDeniedMessage}",
            );

            if (state.status == BaseStatus.completed) {
              if (state.isPermissionDenied) {
                log.w(
                  "BaseView::Listener::Status is completed but permission is denied, not navigating",
                );
                return;
              }

              log.d(
                "BaseView::Listener::Permission check completed, navigating to dashboard",
              );
              _timeoutTimer?.cancel();

              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  log.d(
                    "BaseView::Listener::Executing navigation to dashboard",
                  );
                  try {
                    context.goNamed(RouteNames.dashboard);
                    log.d(
                      "BaseView::Listener::Navigation to dashboard executed successfully",
                    );
                  } catch (e) {
                    log.e(
                      "BaseView::Listener::Error navigating to dashboard: $e",
                    );
                  }
                } else {
                  log.w(
                    "BaseView::Listener::Widget not mounted, skipping navigation",
                  );
                }
              });
            } else if (state.status == BaseStatus.permissionDenied) {
              log.d(
                "BaseView::Listener::Permission denied detected, staying on permission page",
              );
              _timeoutTimer?.cancel();
            } else if (state.status == BaseStatus.error) {
              log.d(
                "BaseView::Listener::Error detected, staying on error page",
              );
              _timeoutTimer?.cancel();
            }
          },
          builder: (context, state) {
            log.d("BaseView::Builder::Current status: ${state.status}");

            if (_hasTimedOut) {
              log.d("BaseView::Builder::Showing timeout fallback UI");
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 64,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Permission Required',
                      style: TextStyle(
                        fontFamily: Constants.app.FONT_POPPINS,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'The app initialization is taking longer than expected. This might be due to permission issues.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: Constants.app.FONT_POPPINS,
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => PermissionAlertUtil.openAppSettings(),
                      icon: Icon(Icons.settings),
                      label: Text('Open Settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _hasTimedOut = false;
                        });
                        _timeoutTimer?.cancel();
                        context.read<BaseBloc>().add(
                          RetryPermissionRequest(currentUser: currentUser),
                        );
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontFamily: Constants.app.FONT_POPPINS,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.status == BaseStatus.syncing) {
              log.d("BaseView::Builder::Showing syncing UI");
              return Center(
                child: Text(
                  'Syncing App Data...',
                  style: TextStyle(
                    fontFamily: Constants.app.FONT_POPPINS,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            } else if (state.status == BaseStatus.initial) {
              log.d("BaseView::Builder::Showing initial UI");
              return Center(
                child: Text(
                  'Initialising App...',
                  style: TextStyle(
                    fontFamily: Constants.app.FONT_POPPINS,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            } else if (state.status == BaseStatus.permissionDenied) {
              log.d("BaseView::Builder::Showing permission denied UI");
              _timeoutTimer?.cancel();
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 64,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Permission Required',
                      style: TextStyle(
                        fontFamily: Constants.app.FONT_POPPINS,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.permissionDeniedMessage ??
                            'Storage permission is required for this app to function properly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: Constants.app.FONT_POPPINS,
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => PermissionAlertUtil.openAppSettings(),
                      icon: Icon(Icons.settings),
                      label: Text('Open Settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          _retryPermissionRequest(context, currentUser),
                      child: Text(
                        'Retry Permission Request',
                        style: TextStyle(
                          fontFamily: Constants.app.FONT_POPPINS,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state.status == BaseStatus.error) {
              log.d("BaseView::Builder::Showing error UI");
              _timeoutTimer?.cancel(); // Cancel timeout on error
              return Center(
                child: Text(
                  'Error initializing App Data',
                  style: TextStyle(
                    fontFamily: Constants.app.FONT_POPPINS,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            } else if (state.status == BaseStatus.completed) {
              if (state.isPermissionDenied) {
                log.w(
                  "BaseView::Builder::Status is completed but permission is denied, showing permission denied UI",
                );
                _timeoutTimer?.cancel();
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 64,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Permission Required',
                        style: TextStyle(
                          fontFamily: Constants.app.FONT_POPPINS,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          state.permissionDeniedMessage ??
                              'Storage permission is required for this app to function properly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: Constants.app.FONT_POPPINS,
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => PermissionAlertUtil.openAppSettings(),
                        icon: Icon(Icons.settings),
                        label: Text('Open Settings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            _retryPermissionRequest(context, currentUser),
                        child: Text(
                          'Retry Permission Request',
                          style: TextStyle(
                            fontFamily: Constants.app.FONT_POPPINS,
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              log.d(
                "BaseView::Builder::Showing completed UI - navigation might have failed",
              );
              _timeoutTimer?.cancel();
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      'App Initialized Successfully',
                      style: TextStyle(
                        fontFamily: Constants.app.FONT_POPPINS,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Your app is ready to use. If you\'re not automatically redirected, please tap the button below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: Constants.app.FONT_POPPINS,
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        log.d(
                          "BaseView::Builder::Manual navigation to dashboard",
                        );
                        context.goNamed(RouteNames.dashboard);
                      },
                      icon: Icon(Icons.dashboard),
                      label: Text('Go to Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              log.d("BaseView::Builder::Showing loading UI (default case)");
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  void _retryPermissionRequest(BuildContext context, UsersModel currentUser) {
    context.read<BaseBloc>().add(
      RetryPermissionRequest(currentUser: currentUser),
    );
  }
}
