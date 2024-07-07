import 'package:dio/dio.dart';

import '../models/crabtype_model.dart';
import 'local_storage_service.dart';

class ApiServiceCrabType {
  static const String baseUrl = 'http://192.168.1.2:3000/crabTypes';
  final Dio _dio;

  ApiServiceCrabType()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await LocalStorageService.getToken();
        String? userId = await LocalStorageService.getUserId();
        options.headers['Authorization'] = 'Bearer $token';
        options.headers['x-user-id'] = userId;
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
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

  Future<List<CrabType>> getAllCrabTypes() async {
    try {
      Response response = await _dio.get('/');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        // print(
        //     'Response data: $data'); // Thêm dòng này để in ra dữ liệu phản hồi
        if (data != null && data is List) {
          return data.map((e) => CrabType.fromJson(e)).toList();
        } else {
          // print('Invalid data format: $data');
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      // print('Failed to get crab types: $e');
      return [];
    }
  }

  Future<bool> createCrabType(CrabType crabType) async {
    try {
      Response response = await _dio.post('/', data: crabType.toJson());
      return response.statusCode == 201;
    } catch (e) {
      // print('Failed to create crab type: $e');
      return false;
    }
  }

  Future<bool> updateCrabType(String id, CrabType crabType) async {
    try {
      Response response = await _dio.put('/$id', data: crabType.toJson());
      return response.statusCode == 200;
    } catch (e) {
      // print('Failed to update crab type: $e');
      return false;
    }
  }

  Future<bool> deleteCrabType(String id) async {
    try {
      Response response = await _dio.delete('/$id');
      return response.statusCode == 200;
    } catch (e) {
      // print('Failed to delete crab type: $e');
      return false;
    }
  }
}
