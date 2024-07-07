import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../apps/config/app_colors.dart';
import '../../controllers/trader_controller.dart';
import '../../models/trader_model.dart';
import '../../widgets/confirm_dialog.dart';

class TraderManagementView extends StatelessWidget {
  const TraderManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final TraderController traderController = Get.put(TraderController());

    void showTraderForm([Trader? trader]) {
      TextEditingController nameController =
          TextEditingController(text: trader?.name ?? '');
      TextEditingController phoneController =
          TextEditingController(text: trader?.phone ?? '');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(trader == null ? 'Thêm thương lái' : 'Sửa thương lái',
                style: const TextStyle(color: AppColors.primaryColor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên thương lái',
                    labelStyle: TextStyle(color: AppColors.textColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    labelStyle: TextStyle(color: AppColors.textColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
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
                      phoneController.text.isNotEmpty) {
                    Trader newTrader = Trader(
                      id: trader?.id ?? '',
                      name: nameController.text,
                      phone: phoneController.text,
                    );
                    if (trader == null) {
                      traderController.createTrader(newTrader);
                    } else {
                      traderController.updateTrader(trader.id, newTrader);
                    }
                    Navigator.of(context).pop();
                  } else {
                    traderController.showSnackbar('Lỗi',
                        'Vui lòng nhập đầy đủ thông tin', AppColors.errorColor);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      );
    }

    Future<bool> showConfirmationDialog() async {
      return await showDialog(
            context: context,
            builder: (context) => ConfirmationDialog(
              title: 'Xác nhận',
              content: 'Bạn có chắc chắn muốn xóa thương lái này không?',
              onConfirm: () {
                // Navigator.of(context).pop(true);
              },
            ),
          ) ??
          false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lí thương lái',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Obx(() {
        if (traderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (traderController.traders.isEmpty) {
          return const Center(child: Text('Không có thương lái nào'));
        }
        return RefreshIndicator(
          onRefresh: traderController.fetchTraders,
          child: ListView.builder(
            itemCount: traderController.traders.length,
            itemBuilder: (context, index) {
              final trader = traderController.traders[index];
              return Column(
                children: [
                  ListTile(
                    title: Text(trader.name,
                        style: const TextStyle(color: AppColors.textColor)),
                    subtitle: Text(trader.phone,
                        style: const TextStyle(color: AppColors.textColor)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showTraderForm(trader),
                          color: AppColors.primaryColor,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            bool confirmed = await showConfirmationDialog();
                            if (confirmed) {
                              traderController.deleteTrader(trader.id);
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
          onPressed: () => showTraderForm(),
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: AppColors.backgroundColor,
    );
  }
}
