import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shimmer/shimmer.dart';

import '../../../apps/config/app_colors.dart';
import '../../../apps/config/format_vnd.dart';
import '../../../controllers/crabtype_controller.dart';
import '../../../models/crabtype_model.dart';
import '../../../widgets/confirm_dialog.dart';

class CrabTypeManagementView extends StatelessWidget {
  const CrabTypeManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    // Nếu đã put ở nơi khác (main/home), dùng Get.find; nếu chưa, Get.put sẽ khởi tạo.
    final crabTypeController = Get.isRegistered<CrabTypeController>()
        ? Get.find<CrabTypeController>()
        : Get.put(CrabTypeController());

    void showCrabTypeForm([CrabType? crabType]) {
      final nameController = TextEditingController(text: crabType?.name ?? '');
      final priceController = TextEditingController(
        text: crabType != null
            ? formatInputCurrency(crabType.pricePerKg.toString())
            : '',
      );

      priceController.addListener(() {
        final raw = priceController.text.replaceAll(',', '');
        if (raw.isNotEmpty) {
          final formatted = formatInputCurrency(raw);
          priceController.value = priceController.value.copyWith(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              crabType == null ? 'Thêm loại cua' : 'Sửa loại cua',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên loại cua',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Giá theo kg',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      priceController.text.isEmpty) {
                    crabTypeController.showSnackbar(
                      'Lỗi',
                      'Vui lòng nhập đầy đủ thông tin',
                      AppColors.errorColor,
                    );
                    return;
                  }
                  final model = CrabType(
                    id: crabType?.id ?? '',
                    name: nameController.text.toUpperCase(),
                    pricePerKg: double.parse(
                      priceController.text.replaceAll(',', ''),
                    ),
                    createdAt: DateTime.now(),
                  );
                  if (crabType == null) {
                    crabTypeController.createCrabType(model);
                  } else {
                    crabTypeController.updateCrabType(crabType.id, model);
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      );
    }

    Future<bool> showConfirmationDialog(VoidCallback onConfirm) async {
      return await showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Xác nhận',
              content: 'Bạn có chắc chắn muốn xóa loại cua này không?',
              onConfirm: onConfirm,
            ),
          ) ??
          false;
    }

    Widget buildHeaderBar() {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Obx(() {
          final total = crabTypeController.crabTypes.length;
          final selected = crabTypeController.selectedCrabTypesTemp.length;
          return Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chọn theo thứ tự bấm để sắp xếp khi tạo hóa đơn.\n'
                  'Đã chọn: $selected / $total',
                  style: const TextStyle(
                    height: 1.25,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: crabTypeController.clearTempSelection,
                icon: const Icon(
                  Icons.clear_all,
                  color: Colors.orange,
                ),
                label: const Text(
                  'Bỏ chọn hết',
                  style: TextStyle(
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          );
        }),
      );
    }

    Widget buildSelectedPreviewChips() {
      return Obx(() {
        final ordered = crabTypeController.selectedCrabTypesTemp;
        if (ordered.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Thứ tự đã chọn (tạm):',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(ordered.length, (i) {
                final ct = ordered[i];
                return Chip(
                  label: Text('${i + 1}. ${ct.name ?? ''}'),
                  backgroundColor: Colors.grey.shade200,
                );
              }),
            ),
          ],
        );
      });
    }

    TableRow buildTableHeaderRow() {
      Widget cell(String text) => Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Text(
              text,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          );

      return TableRow(
        children: [
          cell('Tên loại cua'),
          cell('Giá cua/KG'),
          cell('Chọn'),
          cell('Hành động'),
        ],
      );
    }

    TableRow buildCrabTypeRow(CrabType crabType) {
      return TableRow(
        decoration: const BoxDecoration(color: Colors.white),
        children: [
          _td(Text(
            crabType.name ?? '(Không tên)',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          )),
          _td(Text(
            formatNumberWithoutSymbol(crabType.pricePerKg),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          )),
          _td(
            Center(
              child: Obx(() {
                final checked = crabTypeController.isTempSelected(crabType.id);
                return Transform.scale(
                  scale: 1.4,
                  child: Checkbox(
                    value: checked,
                    onChanged: (_) =>
                        crabTypeController.toggleTempSelection(crabType),
                    activeColor: AppColors.primaryColor,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          _td(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => showCrabTypeForm(crabType),
                  child: const Text(
                    'Sửa',
                    style:
                        TextStyle(color: AppColors.primaryColor, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final confirmed = await showConfirmationDialog(() {
                      crabTypeController.deleteCrabType(crabType.id);
                    });
                    if (confirmed) {
                      // Đã gọi xóa trong onConfirm của dialog
                    }
                  },
                  child: const Text(
                    'Xóa',
                    style: TextStyle(color: AppColors.errorColor, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Quản lí loại cua',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: crabTypeController.fetchCrabTypes,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: Obx(() {
        if (crabTypeController.isLoading.value) {
          return _buildShimmerEffect();
        }
        if (crabTypeController.crabTypes.isEmpty) {
          return const Center(child: Text('Không có loại cua nào'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              buildHeaderBar(),
              buildSelectedPreviewChips(),
              const SizedBox(height: 12),

              // Sticky header cho bảng
              StickyHeader(
                header: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black26, width: 1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(2.8),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(3.5),
                    },
                    border: const TableBorder(
                      horizontalInside:
                          BorderSide(color: Colors.black26, width: 0.5),
                      verticalInside:
                          BorderSide(color: Colors.black26, width: 0.5),
                      top: BorderSide(color: Colors.black26, width: 1),
                      left: BorderSide(color: Colors.black26, width: 1),
                      right: BorderSide(color: Colors.black26, width: 1),
                    ),
                    children: [buildTableHeaderRow()],
                  ),
                ),
                content: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26, width: 1),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(2.8),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(3.5),
                    },
                    border: const TableBorder(
                      horizontalInside:
                          BorderSide(color: Colors.black12, width: 0.5),
                      verticalInside:
                          BorderSide(color: Colors.black12, width: 0.5),
                    ),
                    children: crabTypeController.crabTypes
                        .map(buildCrabTypeRow)
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 50), // chừa chỗ cho bottom bar
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: Colors.black12, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: crabTypeController.saveSelectedCrabTypesForToday,
                  icon: const Icon(Icons.save),
                  label: const Text('Lưu cua trong ngày'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showCrabTypeForm(),
                  icon: const Icon(Icons.add, color: AppColors.primaryColor),
                  label: const Text(
                    'Thêm cua mới',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.primaryColor, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helpers =====

  Widget _td(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Align(alignment: Alignment.centerLeft, child: child),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: 10,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.black12),
            ),
          );
        },
      ),
    );
  }
}
