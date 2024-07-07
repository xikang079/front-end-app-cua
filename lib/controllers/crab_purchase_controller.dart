import 'package:get/get.dart';

import '../apps/config/app_colors.dart';
import '../models/crabpurchase_model.dart';
import '../models/dailysummary_model.dart';
import '../services/api_crab_purchase_service.dart';
import '../services/api_service_daily_summary.dart';
import '../services/local_storage_service.dart';

class CrabPurchaseController extends GetxController {
  final ApiServiceCrabPurchase apiServiceCrabPurchase =
      ApiServiceCrabPurchase();
  final ApiServiceDailySummary apiServiceDailySummary =
      ApiServiceDailySummary();
  var crabPurchases = <CrabPurchase>[].obs;
  var isLoading = false.obs;
  var dailySummary = DailySummary(
    id: '',
    depot: '',
    details: [],
    totalAmount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchCrabPurchasesByDate(
        DateTime.now().toUtc().add(const Duration(hours: 7)));
  }

  void fetchCrabPurchasesByDate(DateTime date) async {
    isLoading.value = true;
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        List<CrabPurchase> fetchedCrabPurchases =
            await apiServiceCrabPurchase.getCrabPurchasesByDate(depotId, date);
        crabPurchases.assignAll(fetchedCrabPurchases);
      } else {
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy mã vựa',
          backgroundColor: AppColors.errorColor,
          colorText: AppColors.buttonTextColor,
        );
      }
    } catch (e) {
      print('Không thể lấy hoá đơn mua cua theo ngày: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể lấy hoá đơn mua cua',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createCrabPurchase(CrabPurchase crabPurchase) async {
    bool success =
        await apiServiceCrabPurchase.createCrabPurchase(crabPurchase);
    if (success) {
      fetchCrabPurchasesByDate(
          DateTime.now().toUtc().add(const Duration(hours: 7)));
      Get.snackbar(
        'Thành công',
        'Tạo hóa đơn mua cua thành công',
        backgroundColor: AppColors.snackBarSuccessColor,
        colorText: AppColors.buttonTextColor,
      );
    } else {
      Get.snackbar(
        'Lỗi',
        'Tạo hóa đơn mua cua thất bại',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    }
    return success;
  }

  Future<bool> updateCrabPurchase(String id, CrabPurchase crabPurchase) async {
    bool success =
        await apiServiceCrabPurchase.updateCrabPurchase(id, crabPurchase);
    if (success) {
      fetchCrabPurchasesByDate(
          DateTime.now().toUtc().add(const Duration(hours: 7)));
      Get.snackbar(
        'Thành công',
        'Cập nhật hóa đơn mua cua thành công',
        backgroundColor: AppColors.snackBarSuccessColor,
        colorText: AppColors.buttonTextColor,
      );
    } else {
      Get.snackbar(
        'Lỗi',
        'Cập nhật hóa đơn mua cua thất bại',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    }
    return success;
  }

  Future<void> deleteCrabPurchase(String id) async {
    bool success = await apiServiceCrabPurchase.deleteCrabPurchase(id);
    if (success) {
      fetchCrabPurchasesByDate(
          DateTime.now().toUtc().add(const Duration(hours: 7)));
      Get.snackbar(
        'Thành công',
        'Xóa hóa đơn mua cua thành công',
        backgroundColor: AppColors.snackBarSuccessColor,
        colorText: AppColors.buttonTextColor,
      );
    } else {
      Get.snackbar(
        'Lỗi',
        'Xóa hóa đơn mua cua thất bại',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    }
  }

  Future<void> createDailySummary() async {
    isLoading.value = true;
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        bool success = await apiServiceDailySummary
            .createDailySummaryByDepotToday(depotId);
        if (success) {
          DailySummary? fetchedDailySummary =
              await apiServiceDailySummary.getDailySummaryByDepotToday(depotId);
          if (fetchedDailySummary != null) {
            dailySummary.value = fetchedDailySummary;
            Get.toNamed('/daily-summary-detail',
                arguments: fetchedDailySummary);
            Get.snackbar(
              'Thành công',
              'Tạo báo cáo tổng hợp trong ngày thành công',
              backgroundColor: AppColors.snackBarSuccessColor,
              colorText: AppColors.buttonTextColor,
            );
          } else {
            Get.snackbar(
              'Lỗi',
              'Không thể lấy báo cáo tổng hợp',
              backgroundColor: AppColors.errorColor,
              colorText: AppColors.buttonTextColor,
            );
          }
        } else {
          Get.snackbar(
            'Lỗi',
            'Đã có 1 báo cáo trong ngày được tạo, xoá báo cáo đó đi để tạo lại',
            backgroundColor: AppColors.errorColor,
            colorText: AppColors.buttonTextColor,
          );
        }
      }
    } catch (e) {
      print(
          'Exception when creating daily summary: $e'); // Debugging print statement
      Get.snackbar(
        'Lỗi',
        'Tạo báo cáo tổng hợp trong ngày thất bại',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
