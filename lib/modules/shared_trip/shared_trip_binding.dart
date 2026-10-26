import 'package:get/get.dart';
import 'shared_trip_controller.dart';

class SharedTripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SharedTripController>(() => SharedTripController());
  }
}
