import 'package:get/get.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/trip_person_model.dart';
import '../../data/models/trip_expense_model.dart';
import '../../data/models/balance_model.dart';
import '../../data/services/trip_service.dart';
import '../../data/services/expense_service.dart';
import '../../data/services/balance_service.dart';

class SharedTripController extends GetxController {
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
  final RxInt activeTab = 0.obs;
  final RxBool notFoundError = false.obs;

  String tripId = '';

  @override
  void onInit() {
    super.onInit();
    
    if (Get.parameters.containsKey('tripId')) {
      tripId = Get.parameters['tripId']!;
    }
    
    loadTripData();
  }

  Future<void> loadTripData() async {
    if (tripId.isEmpty) {
      notFoundError.value = true;
      return;
    }
    isLoading.value = true;
    notFoundError.value = false;
    try {
      final t = await _tripService.getTripById(tripId);
      
      if (t == null) {
        notFoundError.value = true;
        isLoading.value = false;
        return;
      }
      
      trip.value = t;
      final pList = await _tripService.getTripPeople(t.id);
      people.assignAll(pList);
      final expList = await _expenseService.getTripExpenses(t.id);
      expenses.assignAll(expList);

      double total = 0.0;
      for (var e in expList) {
        total += e.totalAmount;
      }
      totalExpenseAmount.value = total;

      final balances = _balanceService.calculatePersonBalances(pList, expList);
      personBalances.assignAll(balances);

      final suggestions = _balanceService.calculateSettlementSuggestions(balances);
      settlementSuggestions.assignAll(suggestions);
      
    } catch (e) {
      notFoundError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  String getPersonName(String personId) {
    final match = people.firstWhereOrNull((p) => p.id == personId);
    return match?.name ?? 'Unknown';
  }
}
