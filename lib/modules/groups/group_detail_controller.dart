import 'package:get/get.dart';
import '../../data/models/group_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/group_service.dart';
import '../../data/services/expense_service.dart';
import '../../app/routes/app_routes.dart';

class GroupDetailController extends GetxController {
  final GroupService _groupService = Get.find<GroupService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();

  final Rx<GroupModel?> group = Rx<GroupModel?>(null);
  final RxList<ExpenseModel> groupExpenses = <ExpenseModel>[].obs;
  final RxList<UserModel> members = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt activeTab = 0.obs; // 0 = Expenses, 1 = Balances

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

  void goToAddExpense() {
    Get.toNamed(Routes.addExpense, arguments: {'groupId': groupId});
  }

  void goToSettleUp() {
    Get.toNamed(Routes.settleUp, arguments: {'groupId': groupId});
  }
}
