import 'package:dio/dio.dart';

import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.2:3000';
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // print('Request: ${options.method} ${options.path}');
        // print('Request Data: ${options.data}');
        return handler.next(options); // continue
      },
      onResponse: (response, handler) {
        // print('Response: ${response.statusCode} ${response.statusMessage}');
        // print('Response Data: ${response.data}');
        return handler.next(response); // continue
      },
      onError: (DioException error, handler) {
        // print('Error: ${error.message}');
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.connectionError) {
          // print('Connection error: ${error.message}');
        }
        // print('Error Response Data: ${error.response?.data}');
        return handler.next(error); // continue
      },
    ));
  }

  Future<User?> login(String username, String password) async {
    try {
      Response response = await _dio.post(
        '/auths/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        var user = User.fromJson(data['user']);
        user.accessToken = data['accessToken'];
        user.refreshToken = data['refreshToken'];
        return user;
      } else {
        // print('Login failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Login failed: $e');
      return null;
    }
  }

  Future<bool> checkTokenValidity(String token, String userId) async {
    try {
      Response response = await _dio.get(
        '/auths/check-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-user-id': userId,
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      // print('Token validation failed: $e');
      return false;
    }
  }

  Future<User?> fetchUserDetails(String token, String userId) async {
    try {
      Response response = await _dio.get(
        '/auths/info',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-user-id': userId,
          },
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['message']['metadata']);
      } else {
        // print('Fetch user details failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // print('Fetching user details failed: $e');
      return null;
    }
  }
}
