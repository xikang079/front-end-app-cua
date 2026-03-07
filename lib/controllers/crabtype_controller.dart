import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../apps/config/app_colors.dart';
import '../models/crabtype_model.dart';
import '../services/api_crabtype_service.dart';

class CrabTypeController extends GetxController {
  final ApiServiceCrabType apiServiceCrabType = ApiServiceCrabType();

  /// Tất cả loại cua từ API
  final crabTypes = <CrabType>[].obs;

  /// Danh sách chính thức đã LƯU CHO HÔM NAY (dùng ở trang Tạo hóa đơn)
  /// — luôn theo đúng thứ tự đã chọn.
  final selectedCrabTypes = <CrabType>[].obs;

  /// Danh sách TẠM khi user đang chọn ở màn Loại cua (trước khi bấm Lưu)
  /// — cũng theo đúng thứ tự click.
  final selectedCrabTypesTemp = <CrabType>[].obs;

  final isLoading = false.obs;

  static const _prefsKey = 'selectedCrabTypesForToday';

  @override
  void onInit() {
    super.onInit();
    fetchCrabTypes(); // Sau khi fetch xong sẽ gọi loadSelectedCrabTypesForToday()
  }

  /// Tải danh sách loại cua từ backend
  Future<void> fetchCrabTypes() async {
    isLoading.value = true;
    EasyLoading.show(status: 'Đang tải...');
    try {
      final fetchedCrabTypes = await apiServiceCrabType.getAllCrabTypes();
      crabTypes.assignAll(fetchedCrabTypes);

      // Sau khi có danh sách loại cua, khôi phục lựa chọn hôm nay theo đúng thứ tự đã lưu
      await loadSelectedCrabTypesForToday();
    } catch (e) {
      showSnackbar(
          'Lỗi', 'Không thể tải danh sách loại cua', AppColors.errorColor);
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  /// ======= PHẦN CHỌN TẠM Ở TRANG “LOẠI CUA” =======

  /// Kiểm tra 1 loại cua đang được chọn tạm hay chưa (để hiển thị trạng thái checkbox)
  bool isTempSelected(String? id) {
    if (id == null) return false;
    return selectedCrabTypesTemp.any((x) => x.id == id);
  }

  /// Toggle chọn/ bỏ chọn tạm — GIỮ THỨ TỰ CLICK
  /// Gọi hàm này khi user tick/untick checkbox ở trang “Loại cua”.
  void toggleTempSelection(CrabType t) {
    final idx = selectedCrabTypesTemp.indexWhere((x) => x.id == t.id);
    if (idx >= 0) {
      // đang chọn → bỏ chọn
      selectedCrabTypesTemp.removeAt(idx);
    } else {
      // chưa chọn → thêm CUỐI LIST để bảo toàn THỨ TỰ CHỌN
      selectedCrabTypesTemp.add(t);
    }
  }

  /// Xóa hết lựa chọn tạm
  void clearTempSelection() {
    selectedCrabTypesTemp.clear();
  }

  /// ======= LƯU/LOAD “CHO HÔM NAY” (PERSIST) =======

  /// Nhấn nút “Lưu cua trong ngày”
  /// → ghi danh sách đã chọn tạm sang danh sách “chính thức” và lưu SharedPreferences theo đúng thứ tự
  Future<void> saveSelectedCrabTypesForToday() async {
    // Đồng bộ danh sách chính thức bằng đúng thứ tự tạm thời
    selectedCrabTypes.assignAll(selectedCrabTypesTemp);

    // Lưu danh sách ID theo THỨ TỰ hiện tại
    final prefs = await SharedPreferences.getInstance();
    final idsOrdered = selectedCrabTypes
        .map((crabType) => crabType.id)
        .whereType<String>()
        .toList();
    await prefs.setStringList(_prefsKey, idsOrdered);

    showSnackbar('Thành công', 'Lưu danh sách loại cua cho hôm nay thành công',
        AppColors.snackBarSuccessColor);
  }

  /// Khôi phục danh sách đã lưu cho hôm nay (giữ THỨ TỰ)
  Future<void> loadSelectedCrabTypesForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final idsOrdered = prefs.getStringList(_prefsKey);

    if (idsOrdered == null || idsOrdered.isEmpty) {
      selectedCrabTypes.clear();
      selectedCrabTypesTemp.clear();
      return;
    }

    // Tạo map id -> CrabType để tra nhanh
    final byId = <String, CrabType>{};
    for (final ct in crabTypes) {
      byId[ct.id] = ct;
    }

    // Duyệt THEO THỨ TỰ ID đã lưu để build list đúng thứ tự
    final restored = <CrabType>[];
    for (final id in idsOrdered) {
      final m = byId[id];
      if (m != null) restored.add(m);
    }

    selectedCrabTypes.assignAll(restored);
    selectedCrabTypesTemp.assignAll(restored); // đồng bộ về màn chọn
  }

  /// ======= CRUD LOẠI CUA (không đổi logic) =======

  Future<void> createCrabType(CrabType crabType) async {
    EasyLoading.show(status: 'Đang lưu...');
    try {
      final success = await apiServiceCrabType.createCrabType(crabType);
      if (success) {
        await fetchCrabTypes();
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
      final success = await apiServiceCrabType.updateCrabType(id, crabType);
      if (success) {
        await fetchCrabTypes();
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
      final success = await apiServiceCrabType.deleteCrabType(id);
      if (success) {
        await fetchCrabTypes();
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

  /// ======= TIỆN ÍCH =======

  String getCrabTypeNameById(String id) {
    final crabType = crabTypes.firstWhereOrNull((x) => x.id == id);
    return crabType?.name ?? 'Không tìm thấy loại cua';
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
