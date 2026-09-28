import 'package:get/get.dart';
import '../../data/models/trip_model.dart';
import '../../data/services/trip_service.dart';
import '../../data/services/expense_service.dart';
import '../../app/routes/app_routes.dart';

class TripSummaryItem {
  final TripModel trip;
  final int peopleCount;
  final double totalExpenseAmount;

  TripSummaryItem({
    required this.trip,
    required this.peopleCount,
    required this.totalExpenseAmount,
  });
}

class HomeController extends GetxController {
  final TripService _tripService = Get.find<TripService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();

  final RxList<TripSummaryItem> recentTripSummaries = <TripSummaryItem>[].obs;
  final RxInt totalTripsCount = 0.obs;
  final RxInt totalExpensesCount = 0.obs;
  final RxDouble totalAmountAcrossTrips = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      final allTrips = await _tripService.getTrips();
      totalTripsCount.value = allTrips.length;

      double globalAmount = 0.0;
      int globalExpensesCount = 0;
      List<TripSummaryItem> summaries = [];

      for (var trip in allTrips) {
        final people = await _tripService.getTripPeople(trip.id);
        final expenses = await _expenseService.getTripExpenses(trip.id);

        double tripTotal = 0.0;
        for (var e in expenses) {
          tripTotal += e.totalAmount;
        }

        globalAmount += tripTotal;
        globalExpensesCount += expenses.length;

        summaries.add(TripSummaryItem(
          trip: trip,
          peopleCount: people.length,
          totalExpenseAmount: tripTotal,
        ));
      }

      totalExpensesCount.value = globalExpensesCount;
      totalAmountAcrossTrips.value = globalAmount;
      recentTripSummaries.assignAll(summaries.take(5));
    } finally {
      isLoading.value = false;
    }
  }

  void goToCreateTrip() =>
      Get.toNamed(Routes.createTrip)?.then((_) => loadDashboardData());

  void goToTripsList() =>
      Get.toNamed(Routes.trips)?.then((_) => loadDashboardData());

  void goToTripDetail(String tripId) =>
      Get.toNamed(Routes.tripDetail, arguments: tripId)?.then((_) => loadDashboardData());
}
