import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/trip_person_model.dart';
import '../../data/models/trip_expense_model.dart';
import '../../data/models/balance_model.dart';
import '../../data/services/trip_service.dart';
import '../../data/services/expense_service.dart';
import '../../data/services/balance_service.dart';
import '../../app/routes/app_routes.dart';
import '../../widgets/custom_toast.dart';
import '../home/home_controller.dart';
import 'trips_controller.dart';

class TripDetailController extends GetxController {
  final TripService _tripService = Get.find<TripService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();
  final BalanceService _balanceService = Get.find<BalanceService>();

  final Rx<TripModel?> trip = Rx<TripModel?>(null);
  final RxList<TripPersonModel> people = <TripPersonModel>[].obs;
  final RxList<TripExpenseModel> expenses = <TripExpenseModel>[].obs;
  final RxList<PersonBalanceModel> personBalances = <PersonBalanceModel>[].obs;
  final RxList<SettlementSuggestionModel> settlementSuggestions =
      <SettlementSuggestionModel>[].obs;

  final RxDouble totalExpenseAmount = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxInt activeTab = 0.obs; // 0 = Balances & People, 1 = Expenses

  String tripId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      if (args is String) {
        tripId = args;
      } else if (args is Map && args.containsKey('tripId')) {
        tripId = args['tripId'] as String;
      }
    }
    loadTripData();
  }

  Future<void> loadTripData() async {
    if (tripId.isEmpty) return;
    isLoading.value = true;
    try {
      final t = await _tripService.getTripById(tripId);
      trip.value = t;

      if (t != null) {
        final pList = await _tripService.getTripPeople(t.id);
        people.assignAll(pList);

        final expList = await _expenseService.getTripExpenses(t.id);
        expenses.assignAll(expList);

        double total = 0.0;
        for (var e in expList) {
          total += e.totalAmount;
        }
        totalExpenseAmount.value = total;

        // Run Balance Engine & Debt Simplification Algorithm
        final balances = _balanceService.calculatePersonBalances(pList, expList);
        personBalances.assignAll(balances);

        final suggestions =
            _balanceService.calculateSettlementSuggestions(balances);
        settlementSuggestions.assignAll(suggestions);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void goToEditTrip() {
    if (trip.value != null) {
      Get.toNamed(Routes.createTrip, arguments: trip.value)?.then((_) => loadTripData());
    }
  }

  Future<void> deleteTrip() async {
    if (trip.value == null) return;
    try {
      await _tripService.deleteTrip(trip.value!.id);
      Get.back();

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDashboardData();
      }
      if (Get.isRegistered<TripsController>()) {
        Get.find<TripsController>().fetchTrips();
      }

      CustomToast.success('Trip deleted successfully!');
    } catch (e) {
      String msg = 'Failed to delete trip';
      if (e is PostgrestException) {
        msg = e.message;
      } else {
        msg = e.toString().replaceAll('Exception:', '').trim();
      }
      CustomToast.error(msg);
    }
  }

  void goToManagePeople() {
    final tId = trip.value?.id ?? tripId;
    Get.toNamed(Routes.managePeople, arguments: tId)?.then((_) => loadTripData());
  }

  void goToAddExpense() {
    final tId = trip.value?.id ?? tripId;
    Get.toNamed(Routes.addExpense, arguments: {'tripId': tId})
        ?.then((_) => loadTripData());
  }

  void goToExpenseDetail(String expenseId) {
    final tId = trip.value?.id ?? tripId;
    Get.toNamed(Routes.expenseDetail, arguments: {
      'expenseId': expenseId,
      'tripId': tId,
    })?.then((_) => loadTripData());
  }
}
