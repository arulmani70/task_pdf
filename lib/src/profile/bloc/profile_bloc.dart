import 'package:task_pdf/src/profile/bloc/profile_event.dart';
import 'package:task_pdf/src/profile/bloc/profile_state.dart';
import 'package:task_pdf/src/profile/repo/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;
  final log = Logger();
  ProfileBloc({required ProfileRepository repository})
    : _repository = repository,
      super(ProfileState.initial) {
    on<InitialProfile>(_onInitProfile);
    on<LogoutProfile>(_onLogoutProfile);
  }

  Future<void> _onInitProfile(
    InitialProfile event,
    Emitter<ProfileState> emit,
  ) async {
    log.d('calling....');
    emit(state.copyWith(profileStatus: ProfileStatus.loading));
    final profile = await _repository.getUserFromPreferences();
    log.d("UserProfileBloc:::_onInitialProfileEvent::event: $profile");
    emit(
      state.copyWith(profileStatus: ProfileStatus.loaded, usersModel: profile),
    );
  }

  Future<void> _onLogoutProfile(
    LogoutProfile event,
    Emitter<ProfileState> emit,
  ) async {
    await _repository.logout();
    emit(state.copyWith(profileStatus: ProfileStatus.loggedout));
  }
}
