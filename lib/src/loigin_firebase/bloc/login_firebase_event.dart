part of 'login_firebase_bloc.dart';

abstract class LoginFirebaseEvent extends Equatable {
  const LoginFirebaseEvent();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginFirebaseEvent {
  const LoginInitial();
}

class LoginWithEmail extends LoginFirebaseEvent {
  final String email;
  final String password;

  const LoginWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterWithEmail extends LoginFirebaseEvent {
  final String email;
  final String password;
  final String fullName;
  final String phone;

  const RegisterWithEmail({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
  });

  @override
  List<Object?> get props => [email, password, fullName, phone];
}

class ToggleLoginSignupMode extends LoginFirebaseEvent {}

class ForgotPasswordWithEmail extends LoginFirebaseEvent {
  final String email;

  const ForgotPasswordWithEmail({required this.email});

  @override
  List<Object?> get props => [email];
}

class LogoutRequested extends LoginFirebaseEvent {
  const LogoutRequested();
}
