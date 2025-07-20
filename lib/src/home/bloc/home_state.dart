part of 'home_bloc.dart';

enum HomePageStatus {
  initial,
  loading,
  success,
  failure,
  updateMenu,
  updateContent,
}

enum DownloadStatus { idle, loading, success, failure }

enum MenuStatus { open, shrunk, closed }

final class HomePageState extends Equatable {
  final HomePageStatus status;
  final String? message;
  final List<Map<String, dynamic>> files;
  final bool isUploading;
  final DownloadStatus downloadStatus;
  final String? downloadMessage;

  const HomePageState({
    required this.status,
    required this.files,
    this.isUploading = false,
    this.downloadStatus = DownloadStatus.idle,
    this.downloadMessage,
    this.message,
  });

  static const initial = HomePageState(
    message: "",
    files: [],
    isUploading: false,
    status: HomePageStatus.initial,
    downloadStatus: DownloadStatus.idle,
    downloadMessage: '',
  );

  HomePageState copyWith({
    String Function()? message,
    bool? isUploading,
    HomePageStatus Function()? status,
    List<Map<String, dynamic>> Function()? files,
    DownloadStatus? downloadStatus,
    String Function()? downloadMessage,
  }) {
    return HomePageState(
      status: status != null ? status() : this.status,

      files: files != null ? files() : this.files,
      isUploading: isUploading ?? this.isUploading,
      message: message != null ? message() : this.message,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadMessage: downloadMessage != null
          ? downloadMessage()
          : this.downloadMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    files,
    isUploading,
    downloadStatus,
    downloadMessage,
  ];
}
