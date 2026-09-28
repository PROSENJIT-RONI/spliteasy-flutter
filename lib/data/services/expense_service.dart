import 'dart:async';
import 'package:get/get.dart';
import '../models/trip_expense_model.dart';
import 'supabase_service.dart';

class ExpenseService extends GetxService {
  final RxList<TripExpenseModel> expenses = <TripExpenseModel>[].obs;

  Future<List<TripExpenseModel>> getTripExpenses(String tripId) async {
    try {
      final res = await supabase
          .from('trip_expenses')
          .select('*, expense_splits(*)')
          .eq('trip_id', tripId)
          .order('expense_date', ascending: false);

      final list = (res as List).map((e) => TripExpenseModel.fromJson(e)).toList();
      expenses.assignAll(list);
      return list;
    } catch (e) {
      return expenses;
    }
  }

  Future<TripExpenseModel?> getExpenseById(String expenseId) async {
    try {
      final res = await supabase
          .from('trip_expenses')
          .select('*, expense_splits(*)')
          .eq('id', expenseId)
          .maybeSingle();

      if (res == null) return null;
      return TripExpenseModel.fromJson(res);
    } catch (e) {
      return expenses.firstWhereOrNull((e) => e.id == expenseId);
    }
  }

  Future<TripExpenseModel> createExpense({
    required String tripId,
    required String description,
    required double totalAmount,
    required String paidByPersonId,
    required String category,
    required SplitType splitType,
    required DateTime expenseDate,
    String note = '',
    required List<Map<String, dynamic>> splitsData, // person_id, share_amount, share_percentage
  }) async {
    final expenseInsert = {
      'trip_id': tripId,
      'description': description,
      'total_amount': totalAmount,
      'paid_by_person_id': paidByPersonId,
      'category': category,
      'split_type': splitType.name,
      'expense_date': expenseDate.toIso8601String(),
      'note': note,
    };

    final expRes =
        await supabase.from('trip_expenses').insert(expenseInsert).select().single();
    final expenseId = expRes['id'] as String;

    final splitsToInsert = splitsData.map((s) {
      return {
        'expense_id': expenseId,
        'person_id': s['person_id'],
        'share_amount': s['share_amount'],
        if (s['share_percentage'] != null)
          'share_percentage': s['share_percentage'],
      };
    }).toList();

    final splitsRes =
        await supabase.from('expense_splits').insert(splitsToInsert).select();

    final fullExpense = TripExpenseModel.fromJson({
      ...expRes,
      'expense_splits': splitsRes,
    });

    expenses.insert(0, fullExpense);
    return fullExpense;
  }

  Future<TripExpenseModel> updateExpense(
    String expenseId, {
    required String description,
    required double totalAmount,
    required String paidByPersonId,
    required String category,
    required SplitType splitType,
    required DateTime expenseDate,
    String note = '',
    required List<Map<String, dynamic>> splitsData,
  }) async {
    final expenseUpdate = {
      'description': description,
      'total_amount': totalAmount,
      'paid_by_person_id': paidByPersonId,
      'category': category,
      'split_type': splitType.name,
      'expense_date': expenseDate.toIso8601String(),
      'note': note,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final expRes = await supabase
        .from('trip_expenses')
        .update(expenseUpdate)
        .eq('id', expenseId)
        .select()
        .single();

    // Delete old splits
    await supabase.from('expense_splits').delete().eq('expense_id', expenseId);

    // Insert new splits
    final splitsToInsert = splitsData.map((s) {
      return {
        'expense_id': expenseId,
        'person_id': s['person_id'],
        'share_amount': s['share_amount'],
        if (s['share_percentage'] != null)
          'share_percentage': s['share_percentage'],
      };
    }).toList();

    final splitsRes =
        await supabase.from('expense_splits').insert(splitsToInsert).select();

    final updated = TripExpenseModel.fromJson({
      ...expRes,
      'expense_splits': splitsRes,
    });

    final index = expenses.indexWhere((e) => e.id == expenseId);
    if (index != -1) {
      expenses[index] = updated;
    }
    return updated;
  }

  Future<void> deleteExpense(String expenseId) async {
    await supabase.from('expense_splits').delete().eq('expense_id', expenseId);
    await supabase.from('trip_expenses').delete().eq('id', expenseId);
    expenses.removeWhere((e) => e.id == expenseId);
  }
}
