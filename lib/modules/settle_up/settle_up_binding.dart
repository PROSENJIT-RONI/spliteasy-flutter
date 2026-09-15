import 'package:get/get.dart';
import 'settle_up_controller.dart';

class SettleUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettleUpController>(() => SettleUpController());
  }
}
