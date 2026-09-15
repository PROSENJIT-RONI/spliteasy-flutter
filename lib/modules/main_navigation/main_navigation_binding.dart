import 'package:get/get.dart';
import 'main_navigation_controller.dart';
import '../home/home_controller.dart';
import '../groups/groups_controller.dart';
import '../balances/balances_controller.dart';
import '../friends/friends_controller.dart';
import '../activity/activity_controller.dart';
import '../profile/profile_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<GroupsController>(() => GroupsController());
    Get.lazyPut<BalancesController>(() => BalancesController());
    Get.lazyPut<FriendsController>(() => FriendsController());
    Get.lazyPut<ActivityController>(() => ActivityController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
