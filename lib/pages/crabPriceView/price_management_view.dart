import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../apps/config/app_colors.dart';
import '../../apps/config/format_vnd.dart';
import '../../controllers/crabtype_controller.dart';
import '../../models/crabtype_model.dart';
import '../../widgets/confirm_dialog.dart';

class PriceManagementView extends StatelessWidget {
  const PriceManagementView({super.key});

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
          'Quản lí giá cua',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Obx(() {
        if (crabTypeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (crabTypeController.crabTypes.isEmpty) {
          return const Center(child: Text('Không có loại cua nào'));
        }
        return RefreshIndicator(
          onRefresh: crabTypeController.fetchCrabTypes,
          child: ListView.builder(
            itemCount: crabTypeController.crabTypes.length,
            itemBuilder: (context, index) {
              final crabType = crabTypeController.crabTypes[index];
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      crabType.name,
                      style: const TextStyle(color: AppColors.textColor),
                    ),
                    subtitle: Text(
                      formatCurrency(crabType.pricePerKg),
                      style: const TextStyle(color: AppColors.textColor),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showCrabTypeForm(crabType),
                          color: AppColors.primaryColor,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            bool confirmed = await showConfirmationDialog(() {
                              crabTypeController.deleteCrabType(crabType.id);
                            });
                            if (confirmed) {
                              // crabTypeController.deleteCrabType(crabType.id);
                            }
                          },
                          color: AppColors.errorColor,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.dividerColor),
                ],
              );
            },
          ),
        );
      }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () => showCrabTypeForm(),
          backgroundColor: AppColors.primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: AppColors.backgroundColor,
    );
  }
}
