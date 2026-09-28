import 'package:get/get.dart';
import '../../data/services/trip_service.dart';
import '../../data/services/expense_service.dart';
import '../../app/routes/app_routes.dart';
import '../home/home_controller.dart';

class TripsController extends GetxController {
  final TripService _tripService = Get.find<TripService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();

  final RxList<TripSummaryItem> tripSummaries = <TripSummaryItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    isLoading.value = true;
    try {
      final list = await _tripService.getTrips();
      List<TripSummaryItem> items = [];

      for (var trip in list) {
        final people = await _tripService.getTripPeople(trip.id);
        final expenses = await _expenseService.getTripExpenses(trip.id);

        double totalAmt = 0.0;
        for (var e in expenses) {
          totalAmt += e.totalAmount;
        }

        items.add(TripSummaryItem(
          trip: trip,
          peopleCount: people.length,
          totalExpenseAmount: totalAmt,
        ));
      }

      tripSummaries.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }

  void goToCreateTrip() =>
      Get.toNamed(Routes.createTrip)?.then((_) => fetchTrips());

  void goToTripDetail(String tripId) =>
      Get.toNamed(Routes.tripDetail, arguments: tripId)?.then((_) => fetchTrips());
}
