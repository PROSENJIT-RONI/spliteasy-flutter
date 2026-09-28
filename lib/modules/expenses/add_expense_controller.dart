import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/trip_expense_model.dart';
import '../../data/models/trip_person_model.dart';
import '../../data/services/trip_service.dart';
import '../../data/services/expense_service.dart';
import '../../widgets/custom_toast.dart';

class AddExpenseController extends GetxController {
  final TripService _tripService = Get.find<TripService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();

  final formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  final RxList<TripPersonModel> tripPeople = <TripPersonModel>[].obs;
  final RxList<String> selectedParticipantIds = <String>[].obs;
  final RxString selectedPaidByPersonId = ''.obs;

  final Rx<SplitType> selectedSplitType = SplitType.equal.obs;
  final RxString selectedCategory = 'Food'.obs;
  final Rx<DateTime> expenseDate = DateTime.now().obs;

  final RxMap<String, TextEditingController> customShareControllers =
      <String, TextEditingController>{}.obs;

  final RxBool isLoading = false.obs;

  TripExpenseModel? existingExpense;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.restaurant_rounded},
    {'name': 'Travel', 'icon': Icons.flight_takeoff_rounded},
    {'name': 'Rent', 'icon': Icons.home_rounded},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded},
    {'name': 'Entertainment', 'icon': Icons.movie_rounded},
    {'name': 'Other', 'icon': Icons.receipt_rounded},
  ];

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
    _initData();
  }

  Future<void> _initData() async {
    isLoading.value = true;
    try {
      final args = Get.arguments;
      if (args != null && args is Map && args.containsKey('existingExpense')) {
        existingExpense = args['existingExpense'] as TripExpenseModel;
      }

      final peopleList = await _tripService.getTripPeople(tripId);
      tripPeople.assignAll(peopleList);

      if (existingExpense != null) {
        descriptionController.text = existingExpense!.description;
        amountController.text = existingExpense!.totalAmount.toStringAsFixed(2);
        noteController.text = existingExpense!.note;
        selectedCategory.value = existingExpense!.category;
        selectedSplitType.value = existingExpense!.splitType;
        expenseDate.value = existingExpense!.expenseDate;
        selectedPaidByPersonId.value = existingExpense!.paidByPersonId;

        final splitPersonIds =
            existingExpense!.splits.map((s) => s.personId).toList();
        selectedParticipantIds.assignAll(splitPersonIds);

        for (var s in existingExpense!.splits) {
          if (existingExpense!.splitType == SplitType.percentage &&
              s.sharePercentage != null) {
            customShareControllers[s.personId] = TextEditingController(
                text: s.sharePercentage!.toStringAsFixed(2));
          } else {
            customShareControllers[s.personId] =
                TextEditingController(text: s.shareAmount.toStringAsFixed(2));
          }
        }
      } else {
        selectedParticipantIds.assignAll(peopleList.map((p) => p.id));
        if (peopleList.isNotEmpty) {
          selectedPaidByPersonId.value = peopleList.first.id;
        }
      }

      _rebuildCustomShareControllers();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleParticipant(String personId) {
    if (selectedParticipantIds.contains(personId)) {
      if (selectedParticipantIds.length > 1) {
        selectedParticipantIds.remove(personId);
      }
    } else {
      selectedParticipantIds.add(personId);
    }
    _rebuildCustomShareControllers();
  }

  void _rebuildCustomShareControllers() {
    for (var id in selectedParticipantIds) {
      if (!customShareControllers.containsKey(id)) {
        customShareControllers[id] = TextEditingController(text: '0');
      }
    }
  }

  double get totalAmount => double.tryParse(amountController.text) ?? 0.0;

  List<Map<String, dynamic>> calculateSplitsData() {
    final count = selectedParticipantIds.length;
    if (count == 0 || totalAmount <= 0) return [];

    List<Map<String, dynamic>> result = [];

    switch (selectedSplitType.value) {
      case SplitType.equal:
        final baseShare = double.parse((totalAmount / count).toStringAsFixed(2));
        double calculatedSum = baseShare * count;
        double diff = double.parse((totalAmount - calculatedSum).toStringAsFixed(2));

        for (int i = 0; i < count; i++) {
          final id = selectedParticipantIds[i];
          double share = baseShare;
          if (i == 0) {
            share = double.parse((share + diff).toStringAsFixed(2));
          }
          result.add({
            'person_id': id,
            'share_amount': share,
            'share_percentage': null,
          });
        }
        break;

      case SplitType.unequal:
        for (var id in selectedParticipantIds) {
          final val =
              double.tryParse(customShareControllers[id]?.text ?? '0') ?? 0.0;
          result.add({
            'person_id': id,
            'share_amount': double.parse(val.toStringAsFixed(2)),
            'share_percentage': null,
          });
        }
        break;

      case SplitType.percentage:
        double totalPct = 0.0;
        for (var id in selectedParticipantIds) {
          final pct =
              double.tryParse(customShareControllers[id]?.text ?? '0') ?? 0.0;
          totalPct += pct;
        }

        double calculatedSum = 0.0;
        for (int i = 0; i < count; i++) {
          final id = selectedParticipantIds[i];
          final pct =
              double.tryParse(customShareControllers[id]?.text ?? '0') ?? 0.0;
          final rawShare =
              double.parse(((totalAmount * pct) / 100).toStringAsFixed(2));
          calculatedSum += rawShare;

          result.add({
            'person_id': id,
            'share_amount': rawShare,
            'share_percentage': pct,
          });
        }

        // Adjust penny rounding if percentages sum to 100%
        if ((totalPct - 100.0).abs() < 0.01 && count > 0) {
          double diff = double.parse((totalAmount - calculatedSum).toStringAsFixed(2));
          if (diff != 0) {
            final firstShare = result[0]['share_amount'] as double;
            result[0]['share_amount'] =
                double.parse((firstShare + diff).toStringAsFixed(2));
          }
        }
        break;
    }

    return result;
  }

  Future<void> saveExpense() async {
    if (!formKey.currentState!.validate()) return;

    if (totalAmount <= 0) {
      CustomToast.error('Expense total amount must be greater than ₹0');
      return;
    }

    if (selectedPaidByPersonId.value.isEmpty) {
      CustomToast.error('Please select who paid for this expense');
      return;
    }

    if (selectedParticipantIds.isEmpty) {
      CustomToast.error('Please select at least one expense participant');
      return;
    }

    final splits = calculateSplitsData();

    // Validation per split mode
    if (selectedSplitType.value == SplitType.unequal) {
      double sumShares = 0.0;
      for (var s in splits) {
        sumShares += (s['share_amount'] as double);
      }
      sumShares = double.parse(sumShares.toStringAsFixed(2));

      if ((sumShares - totalAmount).abs() > 0.01) {
        CustomToast.error(
            'Sum of shares (₹${sumShares.toStringAsFixed(2)}) must equal total amount (₹${totalAmount.toStringAsFixed(2)})');
        return;
      }
    } else if (selectedSplitType.value == SplitType.percentage) {
      double sumPct = 0.0;
      for (var s in splits) {
        sumPct += (s['share_percentage'] as double);
      }
      sumPct = double.parse(sumPct.toStringAsFixed(2));

      if ((sumPct - 100.0).abs() > 0.01) {
        CustomToast.error(
            'Sum of percentages (${sumPct.toStringAsFixed(2)}%) must equal 100%');
        return;
      }
    }

    isLoading.value = true;
    try {
      if (existingExpense == null) {
        await _expenseService.createExpense(
          tripId: tripId,
          description: descriptionController.text.trim(),
          totalAmount: totalAmount,
          paidByPersonId: selectedPaidByPersonId.value,
          category: selectedCategory.value,
          splitType: selectedSplitType.value,
          expenseDate: expenseDate.value,
          note: noteController.text.trim(),
          splitsData: splits,
        );
      } else {
        await _expenseService.updateExpense(
          existingExpense!.id,
          description: descriptionController.text.trim(),
          totalAmount: totalAmount,
          paidByPersonId: selectedPaidByPersonId.value,
          category: selectedCategory.value,
          splitType: selectedSplitType.value,
          expenseDate: expenseDate.value,
          note: noteController.text.trim(),
          splitsData: splits,
        );
      }

      // Close screen route first
      Get.back(result: true);

      // Show success toast
      CustomToast.success(
        existingExpense == null
            ? 'Expense recorded successfully!'
            : 'Expense updated successfully!',
      );
    } catch (e) {
      CustomToast.error('Failed to save expense');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    noteController.dispose();
    for (var c in customShareControllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}
