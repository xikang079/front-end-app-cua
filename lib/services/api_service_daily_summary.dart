import 'package:dio/dio.dart';

import '../models/dailysummary_model.dart';
import 'local_storage_service.dart';

class ApiServiceDailySummary {
  static const String baseUrl = 'http://192.168.1.2:3000/crabPurchases';
  final Dio _dio;

  ApiServiceDailySummary()
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
            error.type == DioExceptionType.connectionError) {
          // Connection error handling
        }
        return handler.next(error);
      },
    ));
  }

  Future<DailySummary?> getDailySummaryByDepotToday(String depotId) async {
    try {
      Response response = await _dio.get('/depot/$depotId/summary/today');
      if (response.statusCode == 200) {
        print(response.data); // Added to inspect full response
        var data = response.data['message']['metadata'];
        print('Fetched daily summary data: $data'); // Debugging print statement
        if (data != null && data is Map<String, dynamic>) {
          return DailySummary.fromJson(data);
        } else {
          print(
              'Data is not in the expected format'); // Debugging print statement
        }
      } else {
        print(
            'Failed to fetch daily summary: ${response.statusCode}'); // Debugging print statement
      }
      return null;
    } catch (e) {
      print(
          'Exception when fetching daily summary: $e'); // Debugging print statement
      return null;
    }
  }

  Future<List<DailySummary>> getAllDailySummariesByDepot(String depotId) async {
    try {
      Response response = await _dio.get('/depot/$depotId/summaries');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is List) {
          return data
              .map<DailySummary>((e) => DailySummary.fromJson(e))
              .toList();
        } else {
          print(
              'Data is not in the expected format'); // Debugging print statement
        }
      } else {
        print(
            'Failed to fetch all daily summaries: ${response.statusCode}'); // Debugging print statement
      }
      return [];
    } catch (e) {
      print(
          'Exception when fetching all daily summaries: $e'); // Debugging print statement
      return [];
    }
  }

  Future<bool> createDailySummaryByDepotToday(String depotId) async {
    try {
      Response response = await _dio.post('/depot/$depotId/summary/today');
      return response.statusCode == 201;
    } catch (e) {
      print(
          'Exception when creating daily summary: $e'); // Debugging print statement
      return false;
    }
  }
}
