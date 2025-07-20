import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_pdf/src/loigin_firebase/repo/login_firebase_repository.dart';
import 'package:task_pdf/src/common/models/models.dart';
import 'package:logger/logger.dart';
part 'login_firebase_event.dart';
part 'login_firebase_state.dart';

class LoginFirebaseBloc extends Bloc<LoginFirebaseEvent, LoginFirebaseState> {
  final LoginFirebaseRepository _repository;
  final log = Logger();
  LoginFirebaseBloc({required LoginFirebaseRepository repository})
    : _repository = repository,
      super(LoginFirebaseState.initial()) {
    on<LoginInitial>(_onLoginInitial);
    on<LoginWithEmail>(_onLoginWithEmail);
    on<ToggleLoginSignupMode>(_onToggleLoginSignupMode);
    on<RegisterWithEmail>(_onRegisterWithEmail);
    on<ForgotPasswordWithEmail>(_onForgotPasswordWithEmail);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginInitial(
    LoginInitial event,
    Emitter<LoginFirebaseState> emit,
  ) async {
    try {
      final user = await _repository.getCurrentUser();

      if (user != null && user.id.isNotEmpty) {
        emit(
          state.copyWith(
            status: LoginFirebaseStatus.loggedIn,
            user: () => user,
            message: () => '',
          ),
        );
      } else {
        emit(LoginFirebaseState.initial()); // Still keep initial state
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginFirebaseStatus.failure,
          message: () => 'Failed to load user: $e',
        ),
      );
    }
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmail event,
    Emitter<LoginFirebaseState> emit,
  ) async {
    emit(
      state.copyWith(status: LoginFirebaseStatus.loading, message: () => ''),
    );

    try {
      final user = await _repository.registerWithEmail(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phone: event.phone,
      );

      if (user != null) {
        emit(
          state.copyWith(
            status: LoginFirebaseStatus.success,
            message: () => 'Account created successfully. Please login.',
            isLoginMode: true, // 👈 Force switch to login mode
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: LoginFirebaseStatus.failure,
            message: () => 'Registration failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginFirebaseStatus.failure,
          message: () => e.toString(),
        ),
      );
    }
  }

  void _onToggleLoginSignupMode(
    ToggleLoginSignupMode event,
    Emitter<LoginFirebaseState> emit,
  ) {
    emit(
      state.copyWith(
        isLoginMode: !state.isLoginMode,
        status: LoginFirebaseStatus.initial,
        message: () => '',
      ),
    );
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmail event,
    Emitter<LoginFirebaseState> emit,
  ) async {
    emit(
      state.copyWith(status: LoginFirebaseStatus.loading, message: () => ''),
    );

    try {
      final user = await _repository.signInWithEmail(
        event.email,
        event.password,
      );

      if (user != null) {
        emit(
          state.copyWith(
            status: LoginFirebaseStatus.loggedIn,
            user: () => user,
            message: () => '',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: LoginFirebaseStatus.failure,
            message: () => 'Invalid email or password',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginFirebaseStatus.failure,
          message: () => e.toString(),
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginFirebaseState> emit,
  ) async {
    log.d("LoginFirebaseBloc :: _onLogoutRequested :: $event");
    await _repository.signOut();
    emit(
      state.copyWith(
        status: LoginFirebaseStatus.loggedOut,
        user: () => UsersModel.empty(),
        message: () => '',
      ),
    );
  }

  Future<void> _onForgotPasswordWithEmail(
    ForgotPasswordWithEmail event,
    Emitter<LoginFirebaseState> emit,
  ) async {
    emit(state.copyWith(forgotPasswordStatus: ForgotPasswordStatus.sending));

    try {
      await _repository.sendPasswordResetEmail(email: event.email);
      emit(state.copyWith(forgotPasswordStatus: ForgotPasswordStatus.sent));
    } catch (e) {
      emit(
        state.copyWith(
          forgotPasswordStatus: ForgotPasswordStatus.failed,
          forgotPasswordErrorMessage: () => e.toString(),
        ),
      );
    }
  }
}
