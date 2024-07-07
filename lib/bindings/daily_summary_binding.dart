import 'package:get/get.dart';

import '../controllers/daily_summary_controller.dart';

class DailySummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailySummaryController>(() => DailySummaryController());
  }
}
