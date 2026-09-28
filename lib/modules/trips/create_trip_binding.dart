import 'package:get/get.dart';
import 'create_trip_controller.dart';

class CreateTripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateTripController>(() => CreateTripController());
  }
}
