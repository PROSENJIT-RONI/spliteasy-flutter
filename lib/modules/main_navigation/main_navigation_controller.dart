import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  void goToAddExpense() {
    Get.toNamed(Routes.addExpense);
  }
}
