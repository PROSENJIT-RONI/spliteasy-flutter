import 'dart:io';
import 'package:get/get.dart';
import '../models/expense_model.dart';
import 'supabase_service.dart';
import 'storage_service.dart';

class ExpenseService extends GetxService {
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final StorageService _storageService = Get.find<StorageService>();

  Future<List<ExpenseModel>> getExpenses() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final res = await supabase
          .from('expenses')
          .select()
          .order('created_at', ascending: false);

      final list = (res as List).map((e) => ExpenseModel.fromJson(e)).toList();
      expenses.assignAll(list);
      return list;
    } catch (e) {
      return expenses;
    }
  }

  Future<List<ExpenseModel>> getExpensesForGroup(String groupId) async {
    try {
      final res = await supabase
          .from('expenses')
          .select()
          .eq('group_id', groupId)
          .order('created_at', ascending: false);

      return (res as List).map((e) => ExpenseModel.fromJson(e)).toList();
    } catch (e) {
      return expenses.where((e) => e.groupId == groupId).toList();
    }
  }

  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    String? receiptUrl = expense.receiptPath;

    if (expense.receiptPath != null &&
        !expense.receiptPath!.startsWith('http') &&
        File(expense.receiptPath!).existsSync()) {
      final file = File(expense.receiptPath!);
      final filename = '${DateTime.now().millisecondsSinceEpoch}_receipt.jpg';
      final storagePath = '$userId/$filename';

      final uploadedUrl = await _storageService.uploadImage(
        file,
        'receipts',
        storagePath,
      );
      if (uploadedUrl != null) {
        receiptUrl = uploadedUrl;
      }
    }

    final insertData = {
      'group_id': expense.groupId,
      'description': expense.description,
      'amount': expense.amount,
      'paid_by': userId,
      'paid_by_user_id': userId,
      'split_type': expense.splitType.name,
      'split_details': expense.splitDetails,
      'category': expense.category,
      'receipt_path': receiptUrl,
      'participant_ids': expense.participantIds,
    };

    final res =
        await supabase.from('expenses').insert(insertData).select().single();

    final created = ExpenseModel.fromJson(res);
    expenses.insert(0, created);
    return created;
  }

  Future<void> deleteExpense(String id) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('expenses')
        .delete()
        .eq('id', id)
        .or('paid_by.eq.$userId,paid_by_user_id.eq.$userId');

    expenses.removeWhere((e) => e.id == id);
  }
}
