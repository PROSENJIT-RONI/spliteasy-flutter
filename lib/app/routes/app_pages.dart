import 'package:get/get.dart';
import 'app_routes.dart';

import '../../modules/splash/splash_screen.dart';
import '../../modules/splash/splash_binding.dart';

import '../../modules/auth/login_screen.dart';
import '../../modules/auth/login_binding.dart';

import '../../modules/auth/register_screen.dart';
import '../../modules/auth/register_binding.dart';

import '../../modules/main_navigation/main_navigation_screen.dart';
import '../../modules/main_navigation/main_navigation_binding.dart';

import '../../modules/groups/group_detail_screen.dart';
import '../../modules/groups/group_detail_binding.dart';

import '../../modules/groups/create_group_screen.dart';
import '../../modules/groups/create_group_binding.dart';

import '../../modules/expenses/add_expense_screen.dart';
import '../../modules/expenses/add_expense_binding.dart';

import '../../modules/settle_up/settle_up_screen.dart';
import '../../modules/settle_up/settle_up_binding.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainNavigationScreen(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: Routes.groupDetail,
      page: () => const GroupDetailScreen(),
      binding: GroupDetailBinding(),
    ),
    GetPage(
      name: Routes.createGroup,
      page: () => const CreateGroupScreen(),
      binding: CreateGroupBinding(),
    ),
    GetPage(
      name: Routes.addExpense,
      page: () => const AddExpenseScreen(),
      binding: AddExpenseBinding(),
    ),
    GetPage(
      name: Routes.settleUp,
      page: () => const SettleUpScreen(),
      binding: SettleUpBinding(),
    ),
  ];
}
