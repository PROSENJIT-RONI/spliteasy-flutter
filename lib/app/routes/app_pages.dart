import 'package:get/get.dart';
import 'app_routes.dart';

import '../../modules/splash/splash_screen.dart';
import '../../modules/splash/splash_binding.dart';

import '../../modules/auth/login_screen.dart';
import '../../modules/auth/login_binding.dart';

import '../../modules/main_navigation/main_navigation_screen.dart';
import '../../modules/main_navigation/main_navigation_binding.dart';

import '../../modules/trips/trips_screen.dart';
import '../../modules/trips/create_trip_screen.dart';
import '../../modules/trips/create_trip_binding.dart';

import '../../modules/trips/trip_detail_screen.dart';
import '../../modules/trips/trip_detail_binding.dart';

import '../../modules/people/manage_people_screen.dart';
import '../../modules/people/manage_people_binding.dart';

import '../../modules/expenses/add_expense_screen.dart';
import '../../modules/expenses/add_expense_binding.dart';

import '../../modules/expenses/expense_detail_screen.dart';
import '../../modules/expenses/expense_detail_binding.dart';

import '../../modules/profile/profile_screen.dart';

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
      name: Routes.main,
      page: () => const MainNavigationScreen(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: Routes.trips,
      page: () => const TripsScreen(),
    ),
    GetPage(
      name: Routes.createTrip,
      page: () => const CreateTripScreen(),
      binding: CreateTripBinding(),
    ),
    GetPage(
      name: Routes.tripDetail,
      page: () => const TripDetailScreen(),
      binding: TripDetailBinding(),
    ),
    GetPage(
      name: Routes.managePeople,
      page: () => const ManagePeopleScreen(),
      binding: ManagePeopleBinding(),
    ),
    GetPage(
      name: Routes.addExpense,
      page: () => const AddExpenseScreen(),
      binding: AddExpenseBinding(),
    ),
    GetPage(
      name: Routes.expenseDetail,
      page: () => const ExpenseDetailScreen(),
      binding: ExpenseDetailBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
    ),
  ];
}
