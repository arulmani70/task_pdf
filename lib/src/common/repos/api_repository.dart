import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:task_pdf/src/common/common.dart';
import 'package:task_pdf/src/common/constants/constansts.dart';
import 'package:logger/logger.dart';

class ApiRepository {
  final Logger log = Logger();
  final Dio _dio;
  final PreferencesRepository prefRepo;

  ApiRepository(this._dio, this.prefRepo) {
    _dio.options.headers["Authorization"] =
        "Bearer ${prefRepo.getPreference(Constants.store.AUTH_TOKEN)}";
  }

  String buildRequest({required Map<String, dynamic> data}) {
    try {
      final Map<String, dynamic> requestJson = {
        "requester": {
          "name": Constants.app.APP_NAME,
          "version": "1.0",
          "timestamp": DateTime.now().toUtc().toIso8601String(),
          "requestedby": prefRepo.getPreference(Constants.store.USER_ID),
        },
      };

      data.forEach((key, value) {
        log.d("ApiRepository::buildRequest::$key - $value");
        requestJson[key] = value;
      });

      log.d("ApiRepository::buildRequest::Final JSON: $requestJson");
      return json.encode(requestJson);
    } catch (error) {
      log.e("ApiRepository::buildRequest::Error: $error");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postRequest({
    required String url,
    required Map<String, dynamic> data,
  }) async {
    try {
      log.d("ApiRepository::postRequest::URL: $url, Data: $data");

      String? authToken = prefRepo.getPreference(Constants.store.AUTH_TOKEN);
      log.d("ApiRepository::postRequest::AuthToken: $authToken");

      _dio.options.headers['Authorization'] = 'Bearer $authToken';

      final fullUrl = Constants.api.API_BASE_URL + url;
      final requestBody = buildRequest(data: data);

      log.d(
        "ApiRepository::postRequest::Posting to $fullUrl with body: $requestBody",
      );

      final response = await _dio.post(fullUrl, data: json.decode(requestBody));

      return _handleResponse(response) as Map<String, dynamic>;
    } on DioException catch (dioError) {
      log.e("ApiRepository::postRequest::DioException: ${dioError.message}");
      throw _handleError(dioError);
    }
  }

  Future<dynamic> getRequest(String url) async {
    try {
      print('comes to URL');
      final fullUrl = Constants.api.API_BASE_URL + url;
      final response = await _dio.get(fullUrl);

      return _handleResponse(response);
    } on DioException catch (dioError) {
      log.e("ApiRepository::getRequest::DioException: ${dioError.message}");
      throw _handleError(dioError);
    }
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;
      if (data is Map) {
        return data;
      } else if (data is String) {
        try {
          return jsonDecode(data);
        } catch (error) {
          log.e("ApiRepository::_handleResponse::JSON decode error: $error");
          throw Exception("Failed to decode response JSON: $error");
        }
      } else {
        return data;
      }
    } else {
      log.e(
        "ApiRepository::_handleResponse::HTTP error ${response.statusCode} - ${response.statusMessage}",
      );
      throw Exception(
        "HTTP error: ${response.statusCode} - ${response.statusMessage}",
      );
    }
  }

  Exception _handleError(DioException error) {
    log.e("ApiRepository::_handleError::Error message: ${error.message}");
    String errorMessage;
    switch (error.type) {
      case DioExceptionType.connectionError:
        errorMessage = "Connection error.";
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage = "Connection timed out.";
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = "Receive timeout.";
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = "Send timeout.";
        break;
      case DioExceptionType.cancel:
        errorMessage = "Request cancelled.";
        break;
      case DioExceptionType.badResponse:
        errorMessage =
            "Response error: ${error.response?.statusCode} - ${error.response?.statusMessage}";
        break;
      case DioExceptionType.unknown:
      default:
        errorMessage = "Unknown error: ${error.message}";
    }
    return Exception(errorMessage);
  }
}
