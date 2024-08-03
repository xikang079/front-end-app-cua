import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDailySummariesByDepotAndMonth(selectedMonth.value, selectedYear.value);
  }

  Future<void> fetchDailySummaryByDepotToday() async {
    isLoading.value = true;
    EasyLoading.show(status: 'Đang tải...');
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        DailySummary? fetchedDailySummary =
            await apiService.getDailySummaryByDepotToday(depotId);
        if (fetchedDailySummary != null) {
          dailySummary.value = fetchedDailySummary;
          dailySummaryIndex.value++;
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch daily summary: $e';
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> fetchAllDailySummariesByDepot() async {
    isLoading.value = true;
    EasyLoading.show(status: 'Đang tải...');
    dailySummaries.clear(); // Clear old data before fetching new data
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        List<DailySummary> fetchedDailySummaries =
            await apiService.getAllDailySummariesByDepot(depotId);
        dailySummaries.assignAll(fetchedDailySummaries);
        dailySummaryIndex.value++;
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch daily summaries: $e';
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> fetchDailySummariesByDepotAndMonth(int month, int year) async {
    isLoading.value = true;
    EasyLoading.show(status: 'đang tải...');
    dailySummaries.clear(); // Clear old data before fetching new data
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        List<DailySummary> fetchedDailySummaries = await apiService
            .getDailySummariesByDepotAndMonth(depotId, month, year);
        dailySummaries.assignAll(fetchedDailySummaries);
        dailySummaryIndex.value++;
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch daily summaries by month: $e';
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> deleteDailySummary(String summaryId) async {
    isLoading.value = true;
    EasyLoading.show(status: 'Đang tải...');
    try {
      String? depotId = await LocalStorageService.getUserId();
      if (depotId != null) {
        bool success = await apiService.deleteDailySummary(depotId, summaryId);
        if (success) {
          dailySummaries.removeWhere((summary) => summary.id == summaryId);
          dailySummaryIndex.value++;
          Get.snackbar(
            'Thành công',
            'Xóa báo cáo tổng hợp thành công',
            backgroundColor: AppColors.snackBarSuccessColor,
            colorText: AppColors.buttonTextColor,
          );
        } else {
          Get.snackbar(
            'Lỗi',
            'Xóa báo cáo tổng hợp thất bại',
            backgroundColor: AppColors.errorColor,
            colorText: AppColors.buttonTextColor,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Xóa báo cáo tổng hợp thất bại',
        backgroundColor: AppColors.errorColor,
        colorText: AppColors.buttonTextColor,
      );
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }
}
