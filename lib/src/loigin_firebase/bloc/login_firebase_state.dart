part of 'login_firebase_bloc.dart';

enum LoginFirebaseStatus {
  initial,
  loading,
  loggedIn,
  success,
  failure,
  loggedOut,
}

enum ForgotPasswordStatus { initial, sending, sent, failed }

class LoginFirebaseState extends Equatable {
  final LoginFirebaseStatus status;
  final String message;
  final UsersModel user;
  final bool isLoginMode;
  final ForgotPasswordStatus forgotPasswordStatus;
  final String forgotPasswordErrorMessage;

  const LoginFirebaseState({
    required this.status,
    required this.message,
    required this.user,
    required this.isLoginMode,
    this.forgotPasswordStatus = ForgotPasswordStatus.initial,
    this.forgotPasswordErrorMessage = '',
  });

  factory LoginFirebaseState.initial() => LoginFirebaseState(
    status: LoginFirebaseStatus.initial,
    message: "",
    user: UsersModel.empty(),
    isLoginMode: true,
    forgotPasswordStatus: ForgotPasswordStatus.initial,
    forgotPasswordErrorMessage: '',
  );

  LoginFirebaseState copyWith({
    LoginFirebaseStatus? status,
    String Function()? message,
    UsersModel Function()? user,
    bool? isLoginMode,
    ForgotPasswordStatus? forgotPasswordStatus,
    String Function()? forgotPasswordErrorMessage,
  }) {
    return LoginFirebaseState(
      status: status ?? this.status,
      message: message != null ? message() : this.message,
      user: user != null ? user() : this.user,
      isLoginMode: isLoginMode ?? this.isLoginMode,
      forgotPasswordStatus: forgotPasswordStatus ?? this.forgotPasswordStatus,
      forgotPasswordErrorMessage: forgotPasswordErrorMessage != null
          ? forgotPasswordErrorMessage()
          : this.forgotPasswordErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    isLoginMode,
    forgotPasswordStatus,
    forgotPasswordErrorMessage,
  ];
}
