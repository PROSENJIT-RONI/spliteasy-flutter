import 'package:get/get.dart';
import '../../data/models/group_model.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/group_service.dart';
import '../../data/services/expense_service.dart';
import '../../data/services/settlement_service.dart';
import '../../data/services/supabase_service.dart';
import '../../app/routes/app_routes.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final GroupService _groupService = Get.find<GroupService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();
  final SettlementService _settlementService = Get.find<SettlementService>();

  final RxList<GroupModel> recentGroups = <GroupModel>[].obs;
  final RxList<ActivityModel> recentActivities = <ActivityModel>[].obs;
  final RxDouble youOwe = 0.0.obs;
  final RxDouble youAreOwed = 0.0.obs;
  final RxDouble totalBalance = 0.0.obs;
  final RxBool isLoading = false.obs;

  String get userName => _authService.currentUser.value?.name ?? 'User';

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      final groupsList = await _groupService.getGroups();
      recentGroups.assignAll(groupsList.take(3));

      await _expenseService.getExpenses();
      await _settlementService.getSettlements();

      try {
        final res = await supabase
            .from('activity_feed')
            .select()
            .order('created_at', ascending: false)
            .limit(5);

        final list = (res as List).map((e) => ActivityModel.fromJson(e)).toList();
        recentActivities.assignAll(list);
      } catch (_) {
        recentActivities.clear();
      }

      _calculateBalances();
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateBalances() {
    final currentUserId = _authService.currentUser.value?.id;
    if (currentUserId == null) {
      youOwe.value = 0.0;
      youAreOwed.value = 0.0;
      totalBalance.value = 0.0;
      return;
    }

    double oweSum = 0.0;
    double owedSum = 0.0;

    for (var exp in _expenseService.expenses) {
      if (exp.paidByUserId == currentUserId) {
        exp.splitDetails.forEach((userId, share) {
          if (userId != currentUserId) {
            owedSum += share;
          }
        });
      } else if (exp.participantIds.contains(currentUserId)) {
        final myShare = exp.splitDetails[currentUserId] ?? 0.0;
        oweSum += myShare;
      }
    }

    for (var s in _settlementService.settlements) {
      if (s.payerId == currentUserId) {
        oweSum = (oweSum - s.amount).clamp(0, double.infinity);
      } else if (s.payeeId == currentUserId) {
        owedSum = (owedSum - s.amount).clamp(0, double.infinity);
      }
    }

    youOwe.value = oweSum;
    youAreOwed.value = owedSum;
    totalBalance.value = owedSum - oweSum;
  }

  void goToAddExpense() => Get.toNamed(Routes.addExpense);
  void goToSettleUp() => Get.toNamed(Routes.settleUp);
  void goToCreateGroup() => Get.toNamed(Routes.createGroup);
  void goToGroupDetail(String groupId) =>
      Get.toNamed(Routes.groupDetail, arguments: groupId);
}
