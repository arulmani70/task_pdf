import 'package:task_pdf/src/common/models/models.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class InitialProfile extends ProfileEvent {
  final UsersModel? user;

  const InitialProfile({this.user});

  @override
  List<Object?> get props => [user];
}

class LogoutProfile extends ProfileEvent {
  @override
  List<Object?> get props => [];
}
