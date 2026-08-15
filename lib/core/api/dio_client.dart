import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static const String baseUrl = 'http://127.0.0.1:8085/api';

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {'Content-Type': 'application/json'};

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 🔍 Debug: print the path
        print('Request path: ${options.path}');
        if (options.path.contains('/login')) {
          print('✅ Skipping token for login');
          return handler.next(options);
        }
        final token = await _storage.read(key: 'token');
        if (token != null) {
          print('✅ Adding token for ${options.path}');
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          print('❌ No token found');
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'token');
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}