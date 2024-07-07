// bindings/crab_type_binding.dart
import 'package:get/get.dart';

import '../controllers/crabtype_controller.dart';

class CrabTypeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CrabTypeController>(() => CrabTypeController());
  }
}
