import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../apps/config/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../widgets/confirm_dialog.dart';
import '../connectPrinterView/connect_printer_view.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.account_box, color: AppColors.primaryColor),
              title: const Text('Tên vựa cua',
                  style: TextStyle(color: AppColors.textColor)),
              subtitle: Text(authController.user.value?.depotName ?? 'N/A',
                  style: const TextStyle(color: AppColors.textColor)),
            ),
            ListTile(
              leading:
                  const Icon(Icons.location_on, color: AppColors.primaryColor),
              title: const Text('Địa chỉ',
                  style: TextStyle(color: AppColors.textColor)),
              subtitle: Text(authController.user.value?.address ?? 'N/A',
                  style: const TextStyle(color: AppColors.textColor)),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primaryColor),
              title: const Text('Số điện thoại',
                  style: TextStyle(color: AppColors.textColor)),
              subtitle: Text(authController.user.value?.phone ?? 'N/A',
                  style: const TextStyle(color: AppColors.textColor)),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(right: 10.0),
              child: TextButton.icon(
                onPressed: () => Get.to(() => const PrinterConnectionView()),
                icon: const Icon(Icons.print, color: Colors.green),
                label: const Text('Cài máy in',
                    style: TextStyle(color: Colors.green, fontSize: 16)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey, width: 3),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(right: 10.0),
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmationDialog(
                        title: 'Xác nhận đăng xuất',
                        content: 'Bạn có chắc chắn muốn đăng xuất không?',
                        onConfirm: () {
                          authController.logout();
                        },
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Đăng xuất', style: TextStyle(fontSize: 16)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey, width: 3),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
