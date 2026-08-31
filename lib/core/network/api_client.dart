import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final int statusCode;

  ApiException({
    required this.code,
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiException(code: $code, message: $message, status: $statusCode)';
}

class ApiClient {
  final http.Client _client = http.Client();
  String? _token;

  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _headers({bool requiresAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {bool requiresAuth = true}) async {
    final uri = Uri.parse('${Env.apiBaseUrl}$path');
    try {
      final response = await _client.get(
        uri,
        headers: _headers(requiresAuth: requiresAuth),
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to the server: $e',
        statusCode: 0,
      );
    }
  }

  Future<dynamic> post(String path, {dynamic body, bool requiresAuth = true}) async {
    final uri = Uri.parse('${Env.apiBaseUrl}$path');
    try {
      final response = await _client.post(
        uri,
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to the server: $e',
        statusCode: 0,
      );
    }
  }

  Future<dynamic> put(String path, {dynamic body, bool requiresAuth = true}) async {
    final uri = Uri.parse('${Env.apiBaseUrl}$path');
    try {
      final response = await _client.put(
        uri,
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to the server: $e',
        statusCode: 0,
      );
    }
  }

  Future<dynamic> delete(String path, {bool requiresAuth = true}) async {
    final uri = Uri.parse('${Env.apiBaseUrl}$path');
    try {
      final response = await _client.delete(
        uri,
        headers: _headers(requiresAuth: requiresAuth),
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to the server: $e',
        statusCode: 0,
      );
    }
  }

  dynamic _processResponse(http.Response response) {
    final int status = response.statusCode;
    final String bodyString = response.body;

    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(bodyString);
    } catch (_) {
      throw ApiException(
        code: 'PARSE_ERROR',
        message: 'Failed to parse response body',
        statusCode: status,
      );
    }

    if (status >= 200 && status < 300) {
      dynamic data = jsonBody;
      if (jsonBody is Map<String, dynamic> && jsonBody['success'] == true) {
        data = jsonBody['data'];
      }

      if (data is Map<String, dynamic>) {
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null && (data['accessToken'] == null && data['token'] == null)) {
          final match = RegExp(r'access_token=([^;]+)').firstMatch(setCookie);
          if (match != null) {
            data['accessToken'] = match.group(1);
          }
        }
      }
      return data;
    } else {
      String code = 'API_ERROR';
      String message = 'Something went wrong';
      if (jsonBody is Map<String, dynamic> && jsonBody['error'] != null) {
        final error = jsonBody['error'];
        if (error is Map<String, dynamic>) {
          code = error['code'] ?? 'API_ERROR';
          message = error['message'] ?? 'Something went wrong';
        } else if (error is String) {
          message = error;
        }
      }
      throw ApiException(
        code: code,
        message: message,
        statusCode: status,
      );
    }
  }
}
