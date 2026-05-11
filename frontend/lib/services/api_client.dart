import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiException implements Exception {
  final int code;
  final String message;

  ApiException(this.code, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  String? _accessToken;
  String? _refreshToken;

  String? get refreshToken => _refreshToken;

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        final code = response.data?['code'];
        if (code != null && code != 200) {
          final message = response.data?['message'] ?? '未知错误';
          handler.reject(DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: message,
          ));
        } else {
          handler.next(response);
        }
      },
    ));
  }

  void setTokens(String access, String refresh) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return _dio.get(path, queryParameters: params, options: _authOptions());
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data, options: _authOptions());
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data, options: _authOptions());
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path, options: _authOptions());
  }

  Options _authOptions() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return Options(headers: headers);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
