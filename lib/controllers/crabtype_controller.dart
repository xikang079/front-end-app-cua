import 'dart:ui';

import 'package:get/get.dart';

import '../apps/config/app_colors.dart';
import '../models/crabtype_model.dart';
import '../services/api_crabtype_service.dart';

class CrabTypeController extends GetxController {
  final ApiServiceCrabType apiServiceCrabType = ApiServiceCrabType();
  var crabTypes = <CrabType>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCrabTypes();
  }

  Future<void> fetchCrabTypes() async {
    isLoading.value = true;
    try {
      List<CrabType> fetchedCrabTypes =
          await apiServiceCrabType.getAllCrabTypes();
      crabTypes.assignAll(fetchedCrabTypes);
    } catch (e) {
      print('Không thể tải danh sách loại cua: $e');
      showSnackbar(
          'Lỗi', 'Không thể tải danh sách loại cua', AppColors.errorColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCrabType(CrabType crabType) async {
    try {
      bool success = await apiServiceCrabType.createCrabType(crabType);
      if (success) {
        fetchCrabTypes();
        showSnackbar('Thành công', 'Tạo loại cua thành công',
            AppColors.snackBarSuccessColor);
      } else {
        showSnackbar('Lỗi', 'Không thể tạo loại cua', AppColors.errorColor);
      }
    } catch (e) {
      showSnackbar('Lỗi', 'Không thể tạo loại cua', AppColors.errorColor);
    }
  }

  Future<void> updateCrabType(String id, CrabType crabType) async {
    try {
      bool success = await apiServiceCrabType.updateCrabType(id, crabType);
      if (success) {
        fetchCrabTypes();
        showSnackbar('Thành công', 'Cập nhật loại cua thành công',
            AppColors.snackBarSuccessColor);
      } else {
        showSnackbar(
            'Lỗi', 'Không thể cập nhật loại cua', AppColors.errorColor);
      }
    } catch (e) {
      showSnackbar('Lỗi', 'Không thể cập nhật loại cua', AppColors.errorColor);
    }
  }

  Future<void> deleteCrabType(String id) async {
    try {
      bool success = await apiServiceCrabType.deleteCrabType(id);
      if (success) {
        fetchCrabTypes();
        showSnackbar('Thành công', 'Xóa loại cua thành công',
            AppColors.snackBarSuccessColor);
      } else {
        showSnackbar('Lỗi', 'Không thể xóa loại cua', AppColors.errorColor);
      }
    } catch (e) {
      showSnackbar('Lỗi', 'Không thể xóa loại cua', AppColors.errorColor);
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

  // Thêm phương thức này để lấy tên loại cua theo ID
  String getCrabTypeNameById(String id) {
    final crabType =
        crabTypes.firstWhereOrNull((crabType) => crabType.id == id);
    return crabType?.name ?? 'Không tìm thấy loại cua';
  }
}
