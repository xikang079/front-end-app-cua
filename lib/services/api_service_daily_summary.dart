import 'package:dio/dio.dart';
import '../models/dailysummary_model.dart';
import 'local_storage_service.dart';

class ApiServiceDailySummary {
  static const String baseUrl =
      'https://back-end-app-cua.onrender.com/crabPurchases';
  final Dio _dio;

  ApiServiceDailySummary()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
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
        return handler.next(error);
      },
    ));
  }

  Future<DailySummary?> getDailySummaryByDepotToday(String depotId) async {
    try {
      Response response = await _dio.get('/depot/$depotId/summary/today');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is Map<String, dynamic>) {
          return DailySummary.fromJson(data);
        }
      }
      return null;
    } catch (e) {
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
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<DailySummary>> getDailySummariesByDepotAndMonth(
      String depotId, int month, int year) async {
    try {
      Response response =
          await _dio.get('/depot/$depotId/summaries/month/$month/year/$year');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is List) {
          return data
              .map<DailySummary>((e) => DailySummary.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createDailySummaryByDepotToday(
      String depotId, DateTime startDate, DateTime endDate) async {
    try {
      Response response =
          await _dio.post('/depot/$depotId/summary/today', data: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDailySummary(String depotId, String summaryId) async {
    try {
      Response response =
          await _dio.delete('/depot/$depotId/summary/$summaryId');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
