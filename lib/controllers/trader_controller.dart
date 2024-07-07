import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../apps/config/app_colors.dart';
import '../models/trader_model.dart';
import '../services/api_trader_service.dart';

class TraderController extends GetxController {
  final ApiServiceTrader apiServiceTrader = ApiServiceTrader();
  var traders = <Trader>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTraders();
  }

  Future<void> fetchTraders() async {
    isLoading.value = true;
    try {
      List<Trader> fetchedTraders = await apiServiceTrader.getAllTraders();
      traders.assignAll(fetchedTraders);
    } catch (e) {
      print('Failed to fetch traders: $e');
      showSnackbar(
          'Lỗi', 'Không thể tải danh sách thương lái', AppColors.errorColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTrader(Trader trader) async {
    bool success = await apiServiceTrader.createTrader(trader);
    if (success) {
      fetchTraders();
      showSnackbar('Thành công', 'Tạo thương lái thành công',
          AppColors.snackBarSuccessColor);
    } else {
      showSnackbar('Lỗi', 'Không thể tạo thương lái', AppColors.errorColor);
    }
  }

  Future<void> updateTrader(String id, Trader trader) async {
    bool success = await apiServiceTrader.updateTrader(id, trader);
    if (success) {
      fetchTraders();
      showSnackbar('Thành công', 'Cập nhật thương lái thành công',
          AppColors.snackBarSuccessColor);
    } else {
      showSnackbar(
          'Lỗi', 'Không thể cập nhật thương lái', AppColors.errorColor);
    }
  }

  Future<void> deleteTrader(String id) async {
    bool success = await apiServiceTrader.deleteTrader(id);
    if (success) {
      fetchTraders();
      showSnackbar('Thành công', 'Xóa thương lái thành công',
          AppColors.snackBarSuccessColor);
    } else {
      showSnackbar('Lỗi', 'Không thể xóa thương lái', AppColors.errorColor);
    }
  }

  void showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: AppColors.buttonTextColor,
    );
  }
}
