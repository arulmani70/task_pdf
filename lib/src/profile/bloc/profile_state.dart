import 'package:task_pdf/src/common/models/models.dart';
import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, loaded, success, error, loggedout }

class ProfileState extends Equatable {
  final ProfileStatus profileStatus;
  final UsersModel usersModel;

  const ProfileState({required this.profileStatus, required this.usersModel});

  static final initial = ProfileState(
    profileStatus: ProfileStatus.initial,
    usersModel: UsersModel.empty(),
  );

  ProfileState copyWith({
    ProfileStatus? profileStatus,
    UsersModel? usersModel,
  }) {
    return ProfileState(
      profileStatus: profileStatus ?? this.profileStatus,
      usersModel: usersModel ?? this.usersModel,
    );
  }

  @override
  List<Object?> get props => [profileStatus, usersModel];
}
