import 'package:dio/dio.dart';

import '../models/trader_model.dart';
import 'local_storage_service.dart';

class ApiServiceTrader {
  static const String baseUrl = 'https://back-end-app-cua.onrender.com/traders';
  final Dio _dio;

  ApiServiceTrader()
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
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.connectionError) {}
        return handler.next(error);
      },
    ));
  }

  Future<List<Trader>> getAllTraders() async {
    try {
      Response response = await _dio.get('/');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is List) {
          return data.map((e) => Trader.fromJson(e)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> createTrader(Trader trader) async {
    try {
      Response response = await _dio.post('/', data: trader.toJson());
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTrader(String id, Trader trader) async {
    try {
      Response response = await _dio.put('/$id', data: trader.toJson());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTrader(String id) async {
    try {
      Response response = await _dio.delete('/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
