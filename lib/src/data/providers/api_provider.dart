import 'dart:convert';
import 'dart:developer';
import 'package:digistore/src/data/services/crashlytics_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/secure_storage_service.dart';
import 'user_type_provider.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final int? statusCode;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.statusCode,
    this.message,
  });

  factory ApiResponse.success(T data, [int? statusCode]) {
    return ApiResponse(success: true, data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

class ApiProvider {
  final String baseUrl;
  final String apiKey;
  final SecureStorageService secureStorage;
  final http.Client _client;

  ApiProvider({
    required this.baseUrl,
    required this.apiKey,
    required this.secureStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _buildHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'accept': '*/*',
      'x-api-key': apiKey,
    };

    if (requireAuth) {
      final token = await secureStorage.getBearerToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    bool requireAuth = true,
    Map<String, String>? queryParams,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      final uri = Uri.parse('$baseUrl$endpoint');
      final uriWithParams = queryParams != null && queryParams.isNotEmpty
          ? uri.replace(queryParameters: queryParams)
          : uri;

      final response = await _client.get(uriWithParams, headers: headers);

      log(name: 'API GET', '$baseUrl$endpoint');
      final decoded = json.decode(response.body);
      log(name: 'DATA', response.body);
      log(name: 'QUERY PARAMS', queryParams.toString());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to load data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'GET');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      log(name: 'API POST', '$baseUrl$endpoint');
      log(name: 'API POST body', json.encode(data));
      final decoded = json.decode(response.body);
      log(name: 'API POST data ', '${decoded['data']}');
      log(name: 'API POST message', '${decoded['message']}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to post data';
        log(name: 'API POST ERROR', '$message');
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      // await CrashlyticsService.logError(e, stackTrace);
      // await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      // await CrashlyticsService.setCustomKey('api_method', 'POST');
      log(name: 'API POST EXCEPTION', '$e');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> patch(
    String endpoint,
    Map<String, dynamic>? data, {
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      log(name: 'API PATCH', '$baseUrl$endpoint');
      final response = await _client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: data != null ? json.encode(data) : null,
      );

      final decoded = json.decode(response.body);
      log(name: 'API PATCH data ', '${decoded['data']}');
      log(name: 'API PATCH message', '${decoded['message']}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to patch data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'PATCH');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      log(name: 'API PUT', '$baseUrl$endpoint');
      log(name: 'API PUT payload', json.encode(data));
      final decoded = json.decode(response.body);

      log(name: 'API PUT', '$baseUrl$endpoint');
      log(name: 'API PUT data', '${decoded['data']}');
      log(name: 'API PUT message', '${decoded['message']}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to put data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'PUT');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> putMultipart(
    String endpoint,
    Map<String, String> body, {
    List<http.MultipartFile>? files,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      headers.remove('Content-Type');

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(headers);
      request.fields.addAll(body);

      if (files != null) {
        request.files.addAll(files);
      }

      log(name: 'API PUT MULTIPART', '$baseUrl$endpoint');

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final decoded = json.decode(responseBody);
      log(name: 'API PUT MULTIPART data ', '$decoded');
      log(name: 'API PUT MULTIPART message', '${decoded['message']}');
      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        return ApiResponse.success(decoded, streamedResponse.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to put multipart data';
        return ApiResponse.error(message, streamedResponse.statusCode);
      }
    } catch (e, stackTrace) {
      log(name: 'API PUT MULTIPART Error', '$e');
      await CrashlyticsService.logError(e, stackTrace);
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> postMultipart(
    String endpoint,
    Map<String, String> body, {
    List<http.MultipartFile>? files,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      headers.remove('Content-Type');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(headers);
      request.fields.addAll(body);

      if (files != null) {
        request.files.addAll(files);
      }

      log(name: 'API POST MULTIPART', '$baseUrl$endpoint');
      log(name: 'API POST MULTIPART fields', '${request.fields}');
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final decoded = json.decode(responseBody);

      log(name: 'API POST MULTIPART data ', '$decoded');
      log(name: 'API POST MULTIPART message', '${decoded['message']}');
      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        return ApiResponse.success(decoded, streamedResponse.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to post multipart data';
        return ApiResponse.error(message, streamedResponse.statusCode);
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e, stackTrace);
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      log(name: 'API DELETE', '$baseUrl$endpoint');
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(decoded, response.statusCode);
      } else {
        final message = decoded['message'] ?? 'Failed to delete data';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.logError(e, stackTrace);
      await CrashlyticsService.setCustomKey('api_endpoint', endpoint);
      await CrashlyticsService.setCustomKey('api_method', 'DELETE');
      return ApiResponse.error('Failed to connect to the server: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

final publicApiProvider = Provider<ApiProvider>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:5000/api';

  return ApiProvider(
    apiKey: dotenv.env['API_KEY'] ?? '',
    baseUrl: baseUrl,
    secureStorage: secureStorage,
  );
});

final apiProvider = Provider<ApiProvider>((ref) {
  final userType = ref.watch(userTypeProvider);
  final publicApi = ref.watch(publicApiProvider);

  String baseUrl = publicApi.baseUrl;

  if (userType == UserType.partner) {
    if (baseUrl.contains('/mobile')) {
      baseUrl = baseUrl.replaceFirst('/mobile', '/mobile/partner');
    } else {
      baseUrl = '$baseUrl/partner';
    }
  }

  return ApiProvider(
    apiKey: publicApi.apiKey,
    baseUrl: baseUrl,
    secureStorage: publicApi.secureStorage,
  );
});
