part of "home_bloc.dart";

abstract class HomePageEvent extends Equatable {
  const HomePageEvent();

  @override
  List<Object> get props => [];
}

class InitializeHomePage extends HomePageEvent {
  const InitializeHomePage();
}

class UploadFileRequested extends HomePageEvent {
  const UploadFileRequested();
}

class DownloadFileRequested extends HomePageEvent {
  final String fileName;
  final String downloadUrl;

  const DownloadFileRequested({
    required this.fileName,
    required this.downloadUrl,
  });

  @override
  List<Object> get props => [fileName, downloadUrl];
}
