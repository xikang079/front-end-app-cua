import 'package:dio/dio.dart';

import '../models/crabpurchase_model.dart';
import 'local_storage_service.dart';

class ApiServiceCrabPurchase {
  static const String baseUrl = 'http://192.168.1.2:3000/crabPurchases';
  final Dio _dio;

  ApiServiceCrabPurchase()
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
        return handler.next(error);
      },
    ));
  }

  Future<String?> getDepotId() async {
    return await LocalStorageService.getUserId();
  }

  Future<List<CrabPurchase>> getAllCrabPurchases() async {
    try {
      Response response = await _dio.get('/');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is List) {
          return data.map((e) => CrabPurchase.fromJson(e)).toList();
        } else {
          // print('Invalid data format: $data');
          return [];
        }
      } else {
        // print(
        //     'Failed to get crab purchases, status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // print('Failed to get crab purchases: $e');
      return [];
    }
  }

  Future<List<CrabPurchase>> getCrabPurchasesByDate(
      String depotId, DateTime date) async {
    try {
      String formattedDate = date.toIso8601String().split('T')[0];
      Response response =
          await _dio.get('/depot/$depotId/date/$formattedDate?limit=0');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is List) {
          return data.map((e) => CrabPurchase.fromJson(e)).toList();
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

  Future<bool> createCrabPurchase(CrabPurchase crabPurchase) async {
    try {
      Response response = await _dio.post('/', data: crabPurchase.toJson());
      if (response.statusCode == 201) {
        return true;
      } else {
        // print(
        //     'Failed to create crab purchase, status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // print('Failed to create crab purchase: $e');
      return false;
    }
  }

  Future<bool> updateCrabPurchase(String id, CrabPurchase crabPurchase) async {
    try {
      Response response = await _dio.put('/$id', data: crabPurchase.toJson());
      if (response.statusCode == 200) {
        return true;
      } else {
        // print(
        //     'Failed to update crab purchase, status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // print('Failed to update crab purchase: $e');
      return false;
    }
  }

  Future<bool> deleteCrabPurchase(String id) async {
    try {
      Response response = await _dio.delete('/$id');
      if (response.statusCode == 200) {
        return true;
      } else {
        // print(
        //     'Failed to delete crab purchase, status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // print('Failed to delete crab purchase: $e');
      return false;
    }
  }
}
