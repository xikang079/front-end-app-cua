import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../apps/config/app_colors.dart';
import '../models/crabtype_model.dart';
import '../services/api_crabtype_service.dart';

class CrabTypeController extends GetxController {
  final ApiServiceCrabType apiServiceCrabType = ApiServiceCrabType();
  var crabTypes = <CrabType>[].obs;
  var selectedCrabTypes = <CrabType>[].obs;
  var selectedCrabTypesTemp = <CrabType>[].obs; // Biến tạm thời để lưu lựa chọn
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCrabTypes();
    loadSelectedCrabTypesForToday();
    scheduleDailyReset();
  }

  void saveSelectedCrabTypesForToday() async {
    selectedCrabTypes.assignAll(
        selectedCrabTypesTemp); // Lưu vào selectedCrabTypes từ biến tạm thời
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> selectedCrabTypesIds =
        selectedCrabTypes.map((crabType) => crabType.id).toList();
    await prefs.setStringList(
        'selectedCrabTypesForToday', selectedCrabTypesIds);
    showSnackbar('Thành công', 'Lưu danh sách loại cua cho hôm nay thành công',
        AppColors.snackBarSuccessColor);
  }

  void loadSelectedCrabTypesForToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? selectedCrabTypesIds =
        prefs.getStringList('selectedCrabTypesForToday');
    if (selectedCrabTypesIds != null) {
      selectedCrabTypes.assignAll(crabTypes
          .where((crabType) => selectedCrabTypesIds.contains(crabType.id))
          .toList());
      selectedCrabTypesTemp.assignAll(selectedCrabTypes);
    }
  }

  void scheduleDailyReset() {
    DateTime now = DateTime.now();
    DateTime resetTime = DateTime(now.year, now.month, now.day, 6);
    if (now.isAfter(resetTime)) {
      resetTime = resetTime.add(const Duration(days: 1));
    }
    Duration timeUntilReset = resetTime.difference(now);

    Future.delayed(timeUntilReset, () {
      selectedCrabTypes.clear();
      selectedCrabTypesTemp.clear();
      saveSelectedCrabTypesForToday();
      scheduleDailyReset();
    });
  }

  String getCrabTypeNameById(String id) {
    final crabType =
        crabTypes.firstWhereOrNull((crabType) => crabType.id == id);
    return crabType?.name ?? 'Không tìm thấy loại cua';
  }

  Future<void> fetchCrabTypes() async {
    isLoading.value = true;
    EasyLoading.show(status: 'Đang tải...');
    try {
      List<CrabType> fetchedCrabTypes =
          await apiServiceCrabType.getAllCrabTypes();
      crabTypes.assignAll(fetchedCrabTypes);
      loadSelectedCrabTypesForToday();
    } catch (e) {
      print('Không thể tải danh sách loại cua: $e');
      showSnackbar(
          'Lỗi', 'Không thể tải danh sách loại cua', AppColors.errorColor);
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> createCrabType(CrabType crabType) async {
    EasyLoading.show(status: 'Đang lưu...');
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
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> updateCrabType(String id, CrabType crabType) async {
    EasyLoading.show(status: 'Đang cập nhật...');
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
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> deleteCrabType(String id) async {
    EasyLoading.show(status: 'Đang xoá...');
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
    } finally {
      EasyLoading.dismiss();
    }
  }

  void showSnackbar(String title, String message, Color backgroundColor) {
    Get.snackbar(title, message,
        backgroundColor: backgroundColor, colorText: AppColors.buttonTextColor);
  }
}
