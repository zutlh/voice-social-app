import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  String? _accessToken;
  String? _refreshToken;

  String? get refreshToken => _refreshToken;

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
