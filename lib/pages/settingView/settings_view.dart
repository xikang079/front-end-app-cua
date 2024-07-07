// views/settings_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../apps/config/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/confirm_dialog.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: AppColors.backgroundColor,
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
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.buttonTextColor,
                backgroundColor: AppColors.buttonColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Đăng xuất', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
