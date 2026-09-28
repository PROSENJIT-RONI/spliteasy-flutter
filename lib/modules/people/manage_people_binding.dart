import 'package:get/get.dart';
import 'manage_people_controller.dart';

class ManagePeopleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagePeopleController>(() => ManagePeopleController());
  }
}
