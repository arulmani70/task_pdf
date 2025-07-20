import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:task_pdf/src/home/repo/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final HomePageRepository _repository;
  final log = Logger();

  HomePageBloc({required HomePageRepository repository})
    : _repository = repository,
      super(HomePageState.initial) {
    on<InitializeHomePage>(_onInitializeHomePageToState);
    on<UploadFileRequested>(_onUploadFile);
    on<DownloadFileRequested>(_onDownloadFile);
  }

  Future<void> _onInitializeHomePageToState(
    InitializeHomePage event,
    Emitter<HomePageState> emit,
  ) async {
    try {
      log.d("HomePageBloc:::_onInitializeHomePageToState::event: $event");
      emit(state.copyWith(status: () => HomePageStatus.loading));

      final homePageData = await _repository.getFileData();

      emit(
        state.copyWith(
          status: () => HomePageStatus.success,
          files: () => homePageData,
        ),
      );
    } catch (error) {
      log.e("HomePageBloc:::_onInitializeHomePageToState::error: $error");
      emit(
        state.copyWith(
          status: () => HomePageStatus.failure,
          message: () => error.toString(),
        ),
      );
    }
  }

  Future<void> _onUploadFile(
    UploadFileRequested event,
    Emitter<HomePageState> emit,
  ) async {
    try {
      log.d("HomePageBloc::_onUploadFile::event: $event");

      // Show progress indicator
      emit(
        state.copyWith(isUploading: true, status: () => HomePageStatus.loading),
      );

      // Upload the file
      await _repository.uploadFile();

      // Get uploaded file list
      final files = await _repository.getFileData();

      // Hide progress and update state
      emit(
        state.copyWith(
          isUploading: false,
          status: () => HomePageStatus.success,
          files: () => files,
        ),
      );
    } catch (error) {
      log.e("HomePageBloc::_onUploadFile::error: $error");

      // Hide progress and show error
      emit(
        state.copyWith(
          isUploading: false,
          status: () => HomePageStatus.failure,
          message: () => error.toString(),
        ),
      );
    }
  }

  Future<void> _onDownloadFile(
    DownloadFileRequested event,
    Emitter<HomePageState> emit,
  ) async {
    try {
      log.d("HomePageBloc::_onDownloadFile::event: ${event.fileName}");

      emit(state.copyWith(downloadStatus: DownloadStatus.loading));

      await _repository.downloadPdfFile(event.downloadUrl, event.fileName);

      emit(
        state.copyWith(
          downloadStatus: DownloadStatus.success,
          downloadMessage: () => 'Download completed successfully!',
        ),
      );
    } catch (error) {
      log.e("HomePageBloc::_onDownloadFile::error: $error");

      emit(
        state.copyWith(
          downloadStatus: DownloadStatus.failure,
          downloadMessage: () => error.toString(),
        ),
      );
    }
  }
}
