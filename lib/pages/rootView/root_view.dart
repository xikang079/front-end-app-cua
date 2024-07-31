import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../controllers/auth_controller.dart';

class RootView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (authController.isCheckingLoginStatus.value) {
          EasyLoading.show(status: 'Đang kiểm tra trạng thái đăng nhập...');
          return const Center(child: CircularProgressIndicator());
        } else {
          EasyLoading.dismiss();
          if (authController.isLoggedIn.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed('/home');
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed('/login');
            });
          }
        }
        return Container();
      }),
    );
  }
}
