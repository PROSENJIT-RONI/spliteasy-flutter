import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/trip_service.dart';
import '../../data/services/expense_service.dart';
import '../../data/services/balance_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<TripService>(TripService(), permanent: true);
    Get.put<ExpenseService>(ExpenseService(), permanent: true);
    Get.put<BalanceService>(BalanceService(), permanent: true);
  }
}
