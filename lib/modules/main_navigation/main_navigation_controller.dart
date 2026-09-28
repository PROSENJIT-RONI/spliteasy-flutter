import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../home/home_controller.dart';
import '../trips/trips_controller.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 0 && Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadDashboardData();
    } else if (index == 1 && Get.isRegistered<TripsController>()) {
      Get.find<TripsController>().fetchTrips();
    }
  }

  void goToCreateTrip() {
    Get.toNamed(Routes.createTrip)?.then((_) {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDashboardData();
      }
      if (Get.isRegistered<TripsController>()) {
        Get.find<TripsController>().fetchTrips();
      }
    });
  }
}
