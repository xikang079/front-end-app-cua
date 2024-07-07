import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'apps/config/app_colors.dart';
import 'routes/route_custom.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng tính tiền cua',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
      ),
      initialRoute: '/',
      getPages: AppRoutes.routes,
    );
  }
}
