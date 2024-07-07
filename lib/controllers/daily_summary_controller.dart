import 'package:get/get.dart';

import '../apps/config/app_colors.dart';
import '../models/dailysummary_model.dart';
import '../services/api_service_daily_summary.dart';
import '../services/local_storage_service.dart';

class DailySummaryController extends GetxController {
  final ApiServiceDailySummary apiService = ApiServiceDailySummary();
  var dailySummary = DailySummary(
    id: '',
    depot: '',
    details: [],
    totalAmount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ).obs;
  var dailySummaries = <DailySummary>[].obs;
  var isLoading = false.obs;
  var dailySummaryIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDailySummaryByDepotToday();
  }

  Future<void> fetchDailySummaryByDepotToday() async {
    isLoading.value = true;
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        DailySummary? fetchedDailySummary =
            await apiService.getDailySummaryByDepotToday(depotId);
        if (fetchedDailySummary != null) {
          dailySummary.value = fetchedDailySummary;
          dailySummaryIndex.value++;
        } else {
          print('Fetched daily summary is null');
        }
      }
    } catch (e) {
      print('Failed to fetch daily summary: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllDailySummariesByDepot() async {
    isLoading.value = true;
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        List<DailySummary> fetchedDailySummaries =
            await apiService.getAllDailySummariesByDepot(depotId);
        dailySummaries.assignAll(fetchedDailySummaries);
      }
    } catch (e) {
      print('Failed to fetch daily summaries: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createDailySummary() async {
    isLoading.value = true;
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        bool success = await apiService.createDailySummaryByDepotToday(depotId);
        if (success) {
          await fetchDailySummaryByDepotToday();
          Get.snackbar(
            'Thành công',
            'Tạo báo cáo tổng hợp trong ngày thành công',
            backgroundColor: AppColors.snackBarSuccessColor,
            colorText: AppColors.buttonTextColor,
          );
        } else {
          Get.snackbar(
            'Lỗi',
            'Không thể tạo báo cáo tổng hợp trong ngày',
            backgroundColor: AppColors.errorColor,
            colorText: AppColors.buttonTextColor,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tạo báo cáo tổng hợp trong ngày',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
