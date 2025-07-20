part of 'base_bloc.dart';

enum BaseStatus {
  initial,
  syncing,
  completed,
  error,
  requestPermission,
  permissionDenied,
}

class BaseState extends Equatable {
  final BaseStatus status;

  final String? message;
  final bool isPermissionDenied;
  final String? permissionDeniedMessage;

  const BaseState({
    required this.status,
    this.message,
    this.isPermissionDenied = false,
    this.permissionDeniedMessage,
  });

  static const initial = BaseState(
    status: BaseStatus.initial,

    message: null,
    isPermissionDenied: false,
    permissionDeniedMessage: null,
  );

  BaseState copyWith({
    BaseStatus Function()? status,
    List<UserRole> Function()? userRoleList,
    String Function()? message,
    bool Function()? isPermissionDenied,
    String Function()? permissionDeniedMessage,
  }) {
    return BaseState(
      status: status != null ? status() : this.status,

      message: message != null ? message() : this.message,
      isPermissionDenied: isPermissionDenied != null
          ? isPermissionDenied()
          : this.isPermissionDenied,
      permissionDeniedMessage: permissionDeniedMessage != null
          ? permissionDeniedMessage()
          : this.permissionDeniedMessage,
    );
  }

  @override
  List<Object?> get props => [status, permissionDeniedMessage];
}
