part of "base_bloc.dart";

abstract class BaseEvent extends Equatable {
  const BaseEvent();

  @override
  List<Object> get props => [];
}

class InitializeApp extends BaseEvent {
  final UsersModel currentUser;

  const InitializeApp({required this.currentUser});
}

class CheckAppInitialized extends BaseEvent {
  final UsersModel currentUser;

  const CheckAppInitialized({required this.currentUser});
}

class InitMemoryCache extends BaseEvent {}

class RetryPermissionRequest extends BaseEvent {
  final UsersModel currentUser;

  const RetryPermissionRequest({required this.currentUser});
}
