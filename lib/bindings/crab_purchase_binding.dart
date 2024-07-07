// bindings/crab_purchase_binding.dart
import 'package:get/get.dart';

import '../controllers/crab_purchase_controller.dart';

class CrabPurchaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CrabPurchaseController>(() => CrabPurchaseController());
  }
}
