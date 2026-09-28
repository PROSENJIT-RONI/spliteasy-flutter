import 'package:get/get.dart';
import 'main_navigation_controller.dart';
import '../home/home_controller.dart';
import '../trips/trips_controller.dart';
import '../profile/profile_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<TripsController>(() => TripsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
