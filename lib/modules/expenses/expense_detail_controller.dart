import 'package:get/get.dart';
import '../../data/models/trip_expense_model.dart';
import '../../data/models/trip_person_model.dart';
import '../../data/services/expense_service.dart';
import '../../data/services/trip_service.dart';
import '../../app/routes/app_routes.dart';
import '../../widgets/custom_toast.dart';

class ExpenseDetailController extends GetxController {
  final ExpenseService _expenseService = Get.find<ExpenseService>();
  final TripService _tripService = Get.find<TripService>();

  final Rx<TripExpenseModel?> expense = Rx<TripExpenseModel?>(null);
  final RxList<TripPersonModel> tripPeople = <TripPersonModel>[].obs;
  final RxBool isLoading = false.obs;

  String get expenseId {
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('expenseId')) {
      return args['expenseId'] as String;
    }
    return '';
  }

  String get tripId {
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('tripId')) {
      return args['tripId'] as String;
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    loadExpenseDetails();
  }

  Future<void> loadExpenseDetails() async {
    if (expenseId.isEmpty) return;
    isLoading.value = true;
    try {
      final exp = await _expenseService.getExpenseById(expenseId);
      expense.value = exp;

      if (tripId.isNotEmpty) {
        final people = await _tripService.getTripPeople(tripId);
        tripPeople.assignAll(people);
      }
    } finally {
      isLoading.value = false;
    }
  }

  String getPersonName(String personId) {
    final match = tripPeople.firstWhereOrNull((p) => p.id == personId);
    return match?.name ?? 'Unknown Participant';
  }

  void goToEditExpense() {
    if (expense.value != null && tripId.isNotEmpty) {
      Get.toNamed(Routes.addExpense, arguments: {
        'tripId': tripId,
        'existingExpense': expense.value,
      })?.then((_) => loadExpenseDetails());
    }
  }

  Future<void> deleteExpense() async {
    if (expense.value == null) return;
    try {
      await _expenseService.deleteExpense(expense.value!.id);
      Get.back();
      CustomToast.success('Expense deleted!');
    } catch (e) {
      CustomToast.error('Failed to delete expense');
    }
  }
}
