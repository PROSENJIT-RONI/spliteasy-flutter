import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/group_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/group_service.dart';
import '../../data/services/expense_service.dart';
import '../../app/routes/app_routes.dart';
import '../../widgets/custom_toast.dart';

class GroupDetailController extends GetxController {
  final GroupService _groupService = Get.find<GroupService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();

  final Rx<GroupModel?> group = Rx<GroupModel?>(null);
  final RxList<ExpenseModel> groupExpenses = <ExpenseModel>[].obs;
  final RxList<UserModel> members = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt activeTab = 0.obs; // 0 = Expenses, 1 = Members

  final addMemberController = TextEditingController();

  String get groupId => Get.arguments as String? ?? 'group_1';

  @override
  void onInit() {
    super.onInit();
    loadGroupData();
  }

  Future<void> loadGroupData() async {
    isLoading.value = true;
    try {
      final g = await _groupService.getGroupById(groupId);
      group.value = g;

      if (g != null) {
        final exps = await _expenseService.getExpensesForGroup(g.id);
        groupExpenses.assignAll(exps);

        final mems = await _groupService.getGroupMembers(g.id);
        members.assignAll(mems);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMemberToGroup() async {
    final input = addMemberController.text.trim();
    if (input.isEmpty) {
      CustomToast.error('Please enter email or phone number');
      return;
    }

    isLoading.value = true;
    try {
      final user = await _groupService.addMemberToGroup(groupId, input);
      if (!members.any((m) => m.id == user.id)) {
        members.add(user);
      }
      CustomToast.success('Added ${user.name} to group!');
      addMemberController.clear();
      Get.back();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception:', '').trim();
      CustomToast.error(msg.isNotEmpty ? msg : 'User not found');
    } finally {
      isLoading.value = false;
    }
  }

  void goToAddExpense() {
    Get.toNamed(Routes.addExpense, arguments: {'groupId': groupId});
  }

  void goToSettleUp() {
    Get.toNamed(Routes.settleUp, arguments: {'groupId': groupId});
  }

  @override
  void onClose() {
    addMemberController.dispose();
    super.onClose();
  }
}
