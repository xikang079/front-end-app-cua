// controllers/crab_purchase_controller.dart
import 'package:get/get.dart';
import 'package:project_crab_front_end/controllers/daily_summary_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../apps/config/app_colors.dart';
import '../models/crabpurchase_model.dart';
import '../models/dailysummary_model.dart';
import '../pages/user/dailySumView/daily_summary_detail_view.dart';
import '../services/api_crab_purchase_service.dart';
import '../services/api_service_daily_summary.dart';
import '../services/local_storage_service.dart';

class CrabPurchaseController extends GetxController {
  final ApiServiceCrabPurchase apiServiceCrabPurchase =
      ApiServiceCrabPurchase();
  final ApiServiceDailySummary apiServiceDailySummary =
      ApiServiceDailySummary();
  final DailySummaryController dailySummaryController =
      Get.put(DailySummaryController());

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
    fetchCrabPurchasesByDateRange();
  }

  void reloadData() {
    fetchCrabPurchasesByDateRange();
  }

  bool hasSoldCrabs(String traderId) {
    return crabPurchases.any((purchase) => purchase.trader.id == traderId);
  }

  void fetchCrabPurchasesByDateRange() async {
    EasyLoading.show(status: 'Đang tải hóa đơn...');
    isLoading.value = true;
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
        DateTime startOfToday;
        DateTime startOfTomorrow;

        if (now.hour < 6) {
          startOfToday =
              DateTime(now.year, now.month, now.day - 1, 6, 0, 0).toUtc();
          startOfTomorrow =
              DateTime(now.year, now.month, now.day, 6, 0, 0).toUtc();
        } else {
          startOfToday =
              DateTime(now.year, now.month, now.day, 6, 0, 0).toUtc();
          startOfTomorrow =
              DateTime(now.year, now.month, now.day + 1, 6, 0, 0).toUtc();
        }

        List<CrabPurchase> fetchedCrabPurchases =
            await apiServiceCrabPurchase.getCrabPurchasesByDateRange(
                depotId, startOfToday, startOfTomorrow);
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
      EasyLoading.dismiss();
    }
  }

  void fetchCrabPurchasesByDate(DateTime date) async {
    EasyLoading.show(status: 'Đang tải hóa đơn...');
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
      EasyLoading.dismiss();
    }
  }

  Future<bool> createCrabPurchase(CrabPurchase crabPurchase) async {
    EasyLoading.show(status: 'Đang tạo hóa đơn...');
    bool success =
        await apiServiceCrabPurchase.createCrabPurchase(crabPurchase);
    if (success) {
      fetchCrabPurchasesByDateRange();
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
    EasyLoading.dismiss();
    return success;
  }

  Future<bool> updateCrabPurchase(String id, CrabPurchase crabPurchase) async {
    EasyLoading.show(status: 'Đang cập nhật hóa đơn...');
    bool success =
        await apiServiceCrabPurchase.updateCrabPurchase(id, crabPurchase);
    if (success) {
      fetchCrabPurchasesByDateRange();
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
    EasyLoading.dismiss();
    return success;
  }

  Future<void> deleteCrabPurchase(String id) async {
    EasyLoading.show(status: 'Đang xóa hóa đơn...');
    bool success = await apiServiceCrabPurchase.deleteCrabPurchase(id);
    if (success) {
      fetchCrabPurchasesByDateRange();
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
    EasyLoading.dismiss();
  }

  DailySummary calculateDailySummary(List<CrabPurchase> crabPurchases) {
    Map<String, SummaryDetail> summaryMap = {};

    for (var purchase in crabPurchases) {
      for (var crab in purchase.crabs) {
        var crabTypeId = crab.crabType.name; // Thay đổi từ ID sang name
        if (!summaryMap.containsKey(crabTypeId)) {
          summaryMap[crabTypeId] = SummaryDetail(
            crabType: crabTypeId, // Chỉ lưu name của CrabType
            totalWeight: 0,
            totalCost: 0,
          );
        }
        summaryMap[crabTypeId]!.totalWeight += crab.weight;
        summaryMap[crabTypeId]!.totalCost += crab.totalCost;
      }
    }

    return DailySummary(
      id: '',
      depot: '',
      details: summaryMap.values.toList(),
      totalAmount:
          summaryMap.values.fold(0, (sum, detail) => sum + detail.totalCost),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> createDailySummary() async {
    EasyLoading.show(status: 'Đang tạo báo cáo...');
    isLoading.value = true;
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
        DateTime startOfToday;
        DateTime startOfTomorrow;

        if (now.hour < 6) {
          startOfToday =
              DateTime(now.year, now.month, now.day - 1, 6, 0, 0).toUtc();
          startOfTomorrow =
              DateTime(now.year, now.month, now.day, 6, 0, 0).toUtc();
        } else {
          startOfToday =
              DateTime(now.year, now.month, now.day, 6, 0, 0).toUtc();
          startOfTomorrow =
              DateTime(now.year, now.month, now.day + 1, 6, 0, 0).toUtc();
        }

        bool success =
            await apiServiceDailySummary.createDailySummaryByDepotToday(
                depotId, startOfToday, startOfTomorrow);
        if (success) {
          DailySummary? fetchedDailySummary =
              await apiServiceDailySummary.getDailySummaryByDepotToday(depotId);
          if (fetchedDailySummary != null) {
            dailySummary.value = fetchedDailySummary;
            reloadData();
            Get.to(() =>
                DailySummaryDetailView(dailySummary: fetchedDailySummary));
            Get.snackbar(
              'Thành công',
              'Tạo báo cáo tổng hợp trong ngày thành công',
              backgroundColor: AppColors.snackBarSuccessColor,
              colorText: AppColors.buttonTextColor,
            );
            await dailySummaryController.fetchAllDailySummariesByDepot();
          } else {
            // Sử dụng dữ liệu tạm thời để hiển thị
            DailySummary tempDailySummary =
                calculateDailySummary(crabPurchases);
            Get.to(
                () => DailySummaryDetailView(dailySummary: tempDailySummary));
            Get.snackbar(
              'Thành công',
              'Tạo báo cáo tổng hợp trong ngày thành công (tạm thời)',
              backgroundColor: AppColors.snackBarSuccessColor,
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
      EasyLoading.dismiss();
    }
  }
}
