import 'dart:io';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:task_pdf/src/common/common.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:file_saver/file_saver.dart';

class HomePageRepository {
  final Logger _log = Logger();
  final PreferencesRepository pref;
  final ApiRepository apiRepo;
  final Dio _dio = Dio();

  HomePageRepository({required this.pref, required this.apiRepo});

  Future<void> uploadFile() async {
    _log.i('Upload initiated');
    try {
      final result = await FilePicker.platform.pickFiles(withData: kIsWeb);
      if (result == null || result.files.isEmpty) {
        _log.w('No file selected');
        return;
      }

      final pickedFile = result.files.first;
      final fileName = pickedFile.name;
      final fileExtension = p.extension(fileName).toLowerCase();
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
      final ref = FirebaseStorage.instance.ref().child(
        'uploads/$userId/$fileName',
      );

      if (kIsWeb) {
        Uint8List bytes = pickedFile.bytes!;
        _log.i('Picked file (web): $fileName');
        _log.i('📎 Extension: $fileExtension');

        bytes = await _compressFile(bytes, fileExtension);
        _log.i('Compressed size: ${bytes.lengthInBytes} bytes');

        await ref.putData(bytes);
      } else {
        File file = File(pickedFile.path!);
        final compressed = await _compressFileMobile(file, fileExtension);
        if (compressed != null) file = File(compressed.path);

        _log.i('Uploading to Firebase Storage (Mobile)...');
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        _log.i('Mobile Upload Success: $downloadUrl');
      }
    } catch (e, st) {
      _log.e('Upload Failed', error: e, stackTrace: st);
    }
  }

  Future<Uint8List> _compressFile(Uint8List bytes, String ext) async {
    _log.i('Original size: ${bytes.lengthInBytes} bytes');

    if (['.jpg', '.jpeg', '.png'].contains(ext)) {
      _log.i('Image detected – compressing...');
      final image = img.decodeImage(bytes);
      if (image == null) {
        _log.w('Failed to decode image.');
        return bytes;
      }

      final resized = img.copyResize(image, width: 800);
      final compressed = img.encodeJpg(resized, quality: 70);

      _log.i('Compressed image size: ${compressed.length} bytes');
      return Uint8List.fromList(compressed);
    } else {
      if (kIsWeb) {
        _log.i('Web detected – skipping compression for non-image file.');
        return bytes;
      }

      _log.i('Non-image file – compressing raw bytes...');
      final compressed = ZLibEncoder().convert(bytes);
      _log.i('Compressed raw file size: ${compressed.length} bytes');
      return Uint8List.fromList(compressed);
    }
  }

  Future<XFile?> _compressFileMobile(File file, String ext) async {
    final originalBytes = await file.readAsBytes();
    _log.i('Original file size: ${originalBytes.lengthInBytes} bytes');

    if (!['.jpg', '.jpeg', '.png'].contains(ext)) {
      _log.i('Non-image file – skipping compression on mobile.');
      return null;
    }

    try {
      final outputPath = p.join(
        p.dirname(file.path),
        "compressed_${p.basename(file.path)}",
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outputPath,
        quality: 70,
        format: CompressFormat.webp,
      );

      if (result != null) {
        final compressedBytes = await result.readAsBytes();
        _log.i(
          "Compressed image file size: ${compressedBytes.lengthInBytes} bytes",
        );
        _log.i("Image compression success: ${result.path}");
      }

      return result;
    } catch (e, st) {
      _log.w("Image compression exception", error: e, stackTrace: st);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getFileData() async {
    _log.i("Fetching uploaded files metadata...");
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
      final storageRef = FirebaseStorage.instance.ref().child(
        "uploads/$userId",
      );

      final ListResult result = await storageRef.listAll();
      _log.i("Found ${result.items.length} files for user '$userId'");

      final files = await Future.wait(
        result.items.map((ref) async {
          final url = await ref.getDownloadURL();
          final meta = await ref.getMetadata();
          _log.i("Fetched: ${ref.name}");
          return {
            'name': ref.name,
            'url': url,
            'uploadedAt': meta.timeCreated?.toIso8601String() ?? '',
          };
        }),
      );

      _log.i("All files metadata fetched successfully.");
      return files;
    } catch (e, st) {
      _log.e("Fetching file list failed", error: e, stackTrace: st);
      throw Exception("Failed to fetch files: $e");
    }
  }

  Future<void> downloadPdfFile(String url, String fileName) async {
    _log.i("Downloading file: $fileName");

    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data!);
      final ext = _getFileExtension(fileName);

      if (UniversalPlatform.isWeb) {
        await FileSaver.instance.saveFile(
          name: fileName.replaceAll('.$ext', ''),
          bytes: bytes,
          mimeType: _getMimeType(ext),
        );
      } else if (UniversalPlatform.isAndroid) {
        final hasPermission = await PermissionUtils.checkStoragePermission();
        if (!hasPermission) {
          final requested = await PermissionUtils.requestStoragePermission();
          if (!requested) {
            _log.w("Storage permission denied for download");
            throw Exception("Storage permission is required to download files");
          }
        }

        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          _log.w("Downloads directory not found!");
          return;
        }

        final filePath = '${downloadsDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        _log.i("📥 File saved to Downloads: $filePath");
      } else if (UniversalPlatform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = "${directory.path}/$fileName";
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        _log.i("📥 File saved to iOS documents: $filePath");
      } else {
        throw UnsupportedError("❌ Platform not supported");
      }
    } catch (e, st) {
      _log.e("Download error", error: e, stackTrace: st);
      rethrow;
    }
  }

  String _getFileExtension(String fileName) {
    return fileName.split('.').last;
  }

  MimeType _getMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return MimeType.jpeg;
      case 'png':
        return MimeType.png;
      case 'pdf':
        return MimeType.pdf;
      case 'mp4':
      case 'avi':
        return MimeType.mp4Video;
      case 'mp3':
        return MimeType.mp3;
      case 'txt':
      case 'doc':
      case 'docx':
        return MimeType.text;
      default:
        return MimeType.other;
    }
  }
}
