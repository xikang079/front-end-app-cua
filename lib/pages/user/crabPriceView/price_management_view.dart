import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../apps/config/app_colors.dart';
import '../../../apps/config/format_vnd.dart';
import '../../../controllers/crabtype_controller.dart';
import '../../../models/crabtype_model.dart';
import '../../../widgets/confirm_dialog.dart';

class CrabTypeManagementView extends StatelessWidget {
  const CrabTypeManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final CrabTypeController crabTypeController = Get.put(CrabTypeController());

    void showCrabTypeForm([CrabType? crabType]) {
      TextEditingController nameController =
          TextEditingController(text: crabType?.name ?? '');
      TextEditingController priceController = TextEditingController(
          text: crabType != null
              ? formatInputCurrency(crabType.pricePerKg.toString())
              : '');

      priceController.addListener(() {
        String value = priceController.text.replaceAll(',', '');
        if (value.isNotEmpty) {
          priceController.value = priceController.value.copyWith(
            text: formatInputCurrency(value),
            selection: TextSelection.collapsed(
                offset: formatInputCurrency(value).length),
          );
        }
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              crabType == null ? 'Thêm loại cua' : 'Sửa loại cua',
              style: const TextStyle(color: AppColors.primaryColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên loại cua',
                    labelStyle: TextStyle(color: AppColors.textColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Giá theo kg',
                    labelStyle: TextStyle(color: AppColors.textColor),
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
                  if (nameController.text.isNotEmpty &&
                      priceController.text.isNotEmpty) {
                    CrabType newCrabType = CrabType(
                      id: crabType?.id ?? '',
                      name: nameController.text.toUpperCase(),
                      pricePerKg: double.parse(
                          priceController.text.replaceAll(',', '')),
                    );
                    if (crabType == null) {
                      crabTypeController.createCrabType(newCrabType);
                    } else {
                      crabTypeController.updateCrabType(
                          crabType.id, newCrabType);
                    }
                    Navigator.of(context).pop();
                  } else {
                    crabTypeController.showSnackbar(
                      'Lỗi',
                      'Vui lòng nhập đầy đủ thông tin',
                      AppColors.errorColor,
                    );
                  }
                },
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lí loại cua',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              crabTypeController.fetchCrabTypes();
            },
          ),
        ],
        backgroundColor: AppColors.primaryColor,
      ),
      body: Obx(() {
        if (crabTypeController.isLoading.value) {
          return _buildShimmerEffect();
        }
        if (crabTypeController.crabTypes.isEmpty) {
          return const Center(child: Text('Không có loại cua nào'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: StickyHeader(
              header: Table(
                border: TableBorder.all(color: Colors.black54, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: const [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tên loại cua',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Giá cua/KG',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Chọn',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Hành động',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              content: Table(
                border: TableBorder.all(color: Colors.black54, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(2),
                },
                children: crabTypeController.crabTypes.map((crabType) {
                  final isSelected = crabTypeController.selectedCrabTypesTemp
                      .any((selected) => selected.id == crabType.id);
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(crabType.name,
                              style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                              formatNumberWithoutSymbol(crabType.pricePerKg),
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Transform.scale(
                            scale: 2,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                if (isSelected) {
                                  crabTypeController.selectedCrabTypesTemp
                                      .removeWhere((selected) =>
                                          selected.id == crabType.id);
                                } else {
                                  crabTypeController.selectedCrabTypesTemp
                                      .add(crabType);
                                }
                              },
                              activeColor: Colors.green,
                              checkColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: AppColors.primaryColor, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                ),
                                child: const Text('Sửa',
                                    style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 16)),
                                onPressed: () {
                                  showCrabTypeForm(crabType);
                                },
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: AppColors.errorColor, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                ),
                                child: const Text('Xóa',
                                    style: TextStyle(
                                        color: AppColors.errorColor,
                                        fontSize: 16)),
                                onPressed: () async {
                                  bool confirmed =
                                      await showConfirmationDialog(() {
                                    crabTypeController
                                        .deleteCrabType(crabType.id);
                                  });
                                  if (confirmed) {
                                    // crabTypeController.deleteCrabType(crabType.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  crabTypeController.saveSelectedCrabTypesForToday();
                },
                icon: const Icon(Icons.save, color: Colors.green),
                label: const Text(
                  'Lưu cua trong ngày',
                  style: TextStyle(color: Colors.green),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey, width: 3),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Container(
              width: 20,
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: () => showCrabTypeForm(),
                icon: const Icon(Icons.add, color: AppColors.primaryColor),
                label: const Text(
                  'Thêm cua mới',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey, width: 3),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: AppColors.backgroundColor,
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              child: const ListTile(
                title: Text(''),
                subtitle: Text(''),
              ),
            ),
          );
        },
      ),
    );
  }
}
