import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:task_pdf/src/base/repository/base_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:task_pdf/src/common/models/models.dart';
import 'package:task_pdf/src/common/constants/constansts.dart';
import 'package:logger/logger.dart';

part 'base_event.dart';
part 'base_state.dart';

class BaseBloc extends Bloc<BaseEvent, BaseState> {
  final log = Logger();
  final BaseRepository _repository;

  BaseBloc({required BaseRepository repository}) : _repository = repository, super(BaseState.initial) {
    on<InitializeApp>(mapInitializeAppToState);
    on<CheckAppInitialized>(mapCheckAppInitializedToState);
    on<InitMemoryCache>(mapInitMemoryCacheToState);
    on<RetryPermissionRequest>(mapRetryPermissionRequestToState);
  }

  Future<void> mapInitializeAppToState(InitializeApp event, Emitter<BaseState> emit) async {
    try {
      log.d("BaseBloc::InitializeAppToState::Triggered");

      emit(state.copyWith(status: () => BaseStatus.syncing));
      log.d("BaseBloc::InitializeAppToState::Emitted syncing status");

      final initMap = await _repository.isAppInit(event.currentUser.id, event.currentUser.email);

      final bool isAppInitialized = initMap[Constants.store.INITIALIZED] ?? false;
      final bool hasStoredPermission = initMap[Constants.store.PERMISSION] ?? false;

      log.d("BaseBloc::InitializeAppToState::App initialized: $isAppInitialized, Has stored permission: $hasStoredPermission");

      // Always request permission to ensure the user sees the permission alert
      // Only skip if the app is already initialized and has valid permission
      if (isAppInitialized && hasStoredPermission) {
        log.d("BaseBloc::InitializeAppToState::App already initialized with permission, checking if still valid");
        final currentPermissionStatus = await _repository.checkStoragePermission();
        log.d("BaseBloc::InitializeAppToState::Current permission status: $currentPermissionStatus");

        if (currentPermissionStatus) {
          log.d("BaseBloc::InitializeAppToState::Permission still valid, proceeding to completion");
          emit(state.copyWith(status: () => BaseStatus.completed));
          log.d("BaseBloc::InitializeAppToState::Emitted completed status");
          return;
        } else {
          log.w("BaseBloc::InitializeAppToState::Stored permission is no longer valid, requesting again");
          // Clear the stored permission since it's no longer valid
          await _repository.clearStoredPermission(event.currentUser.id, event.currentUser.email);
        }
      }

      // Request permissions to show the permission alert
      log.d("BaseBloc::InitializeAppToState::Requesting storage permission");

      // Add timeout to prevent UI from getting stuck
      final permissionResult = await _repository
          .ensureStoragePermission(event.currentUser.id, event.currentUser.email)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              log.w("BaseBloc::InitializeAppToState::Permission request timed out");
              return PermissionResult(granted: false, deniedMessage: 'Permission request timed out. Please try again.');
            },
          );

      log.d("BaseBloc::InitializeAppToState::Permission result: ${permissionResult.granted}");

      if (!permissionResult.granted) {
        log.w("BaseBloc::InitializeAppToState::Permission denied - ${permissionResult.deniedMessage}");
        emit(
          state.copyWith(
            status: () => BaseStatus.permissionDenied,
            isPermissionDenied: () => true,
            permissionDeniedMessage: () => permissionResult.deniedMessage ?? 'Permission denied',
          ),
        );
        log.d("BaseBloc::InitializeAppToState::Emitted permissionDenied status");
        return;
      }

      log.d("BaseBloc::InitializeAppToState::Permission granted, emitting completed status");

      // Mark app as initialized when permission is granted
      await _repository.prefRepo.savePreference(Constants.store.INITIALIZED, 'true');
      log.d("BaseBloc::InitializeAppToState::App marked as initialized");

      emit(state.copyWith(status: () => BaseStatus.completed));
      log.d("BaseBloc::InitializeAppToState::Emitted completed status");
    } catch (error, stacktrace) {
      log.e("BaseBloc::InitializeAppToState: $error", error: error, stackTrace: stacktrace);
      emit(state.copyWith(status: () => BaseStatus.error, message: () => error.toString()));
      log.d("BaseBloc::InitializeAppToState::Emitted error status");
    }
  }

  Future<void> mapCheckAppInitializedToState(CheckAppInitialized event, Emitter<BaseState> emit) async {
    try {
      log.d("BaseBloc::CheckAppInitialized::Triggered");

      emit(state.copyWith(status: () => BaseStatus.syncing));

      final initMap = await _repository.isAppInit(event.currentUser.id, event.currentUser.email);
      log.d("BaseBloc::CheckAppInitialized::App is Initialized::$initMap");

      emit(state.copyWith(status: () => BaseStatus.completed));
    } catch (error, stacktrace) {
      log.e("BaseBloc::CheckAppInitialized: $error", error: error, stackTrace: stacktrace);
      emit(state.copyWith(status: () => BaseStatus.error, message: () => error.toString()));
    }
  }

  Future<void> mapInitMemoryCacheToState(InitMemoryCache event, Emitter<BaseState> emit) async {
    log.d("BaseBloc::InitMemoryCacheToState::Triggered");

    emit(state.copyWith(status: () => BaseStatus.syncing));
    try {
      List<UserRole> userRoleList = [];

      emit(state.copyWith(status: () => BaseStatus.completed, userRoleList: () => userRoleList));
    } catch (error, stacktrace) {
      log.e("BaseBloc::InitMemoryCacheToState: $error", error: error, stackTrace: stacktrace);
      emit(state.copyWith(status: () => BaseStatus.error, message: () => error.toString()));
    }
  }

  Future<void> mapRetryPermissionRequestToState(RetryPermissionRequest event, Emitter<BaseState> emit) async {
    try {
      log.d("BaseBloc::RetryPermissionRequest::Triggered");

      emit(state.copyWith(status: () => BaseStatus.syncing));

      // Check if app is already initialized with valid permission
      final initMap = await _repository.isAppInit(event.currentUser.id, event.currentUser.email);
      final bool isAppInitialized = initMap[Constants.store.INITIALIZED] ?? false;
      final bool hasStoredPermission = initMap[Constants.store.PERMISSION] ?? false;

      if (isAppInitialized && hasStoredPermission) {
        log.d("BaseBloc::RetryPermissionRequest::App already initialized with permission, checking if still valid");
        final currentPermissionStatus = await _repository.checkStoragePermission();
        if (currentPermissionStatus) {
          log.d("BaseBloc::RetryPermissionRequest::Permission still valid, proceeding to completion");
          emit(state.copyWith(status: () => BaseStatus.completed));
          return;
        } else {
          log.w("BaseBloc::RetryPermissionRequest::Stored permission is no longer valid, requesting again");
          await _repository.clearStoredPermission(event.currentUser.id, event.currentUser.email);
        }
      }

      // Always request permission to show the permission alert
      log.d("BaseBloc::RetryPermissionRequest::Requesting storage permission");
      final permissionResult = await _repository
          .ensureStoragePermission(event.currentUser.id, event.currentUser.email)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              log.w("BaseBloc::RetryPermissionRequest::Permission request timed out");
              return PermissionResult(granted: false, deniedMessage: 'Permission request timed out. Please try again.');
            },
          );

      if (!permissionResult.granted) {
        log.w("BaseBloc::RetryPermissionRequest::Permission still denied - ${permissionResult.deniedMessage}");
        emit(
          state.copyWith(
            status: () => BaseStatus.permissionDenied,
            isPermissionDenied: () => true,
            permissionDeniedMessage: () => permissionResult.deniedMessage ?? 'Permission denied',
          ),
        );
        return;
      }

      // Permission granted, proceed with app initialization
      final updatedInitMap = await _repository.isAppInit(event.currentUser.id, event.currentUser.email);
      log.d("BaseBloc::RetryPermissionRequest::App initialization completed: $updatedInitMap");

      // Mark app as initialized when permission is granted
      await _repository.prefRepo.savePreference(Constants.store.INITIALIZED, 'true');
      log.d("BaseBloc::RetryPermissionRequest::App marked as initialized");

      emit(state.copyWith(status: () => BaseStatus.completed));
    } catch (error, stacktrace) {
      log.e("BaseBloc::RetryPermissionRequest: $error", error: error, stackTrace: stacktrace);
      emit(state.copyWith(status: () => BaseStatus.error, message: () => error.toString()));
    }
  }
}
