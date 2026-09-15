import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/friend_service.dart';
import '../../data/services/expense_service.dart';
import '../../data/services/settlement_service.dart';
import '../../app/routes/app_routes.dart';

class UserBalanceItem {
  final UserModel user;
  final double netBalance; // positive = owed to me, negative = I owe them

  UserBalanceItem({required this.user, required this.netBalance});
}

class BalancesController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FriendService _friendService = Get.find<FriendService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();
  final SettlementService _settlementService = Get.find<SettlementService>();

  final RxList<UserBalanceItem> friendBalances = <UserBalanceItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    calculateBalances();
  }

  Future<void> calculateBalances() async {
    isLoading.value = true;
    try {
      final currentUserId = _authService.currentUser.value?.id ?? 'user_me';
      final friends = await _friendService.getFriends();
      List<UserBalanceItem> items = [];

      for (var friend in friends) {
        double net = 0.0;

        for (var exp in _expenseService.expenses) {
          if (exp.paidByUserId == currentUserId && exp.participantIds.contains(friend.id)) {
            net += (exp.splitDetails[friend.id] ?? 0.0);
          } else if (exp.paidByUserId == friend.id && exp.participantIds.contains(currentUserId)) {
            net -= (exp.splitDetails[currentUserId] ?? 0.0);
          }
        }

        for (var set in _settlementService.settlements) {
          if (set.payerId == currentUserId && set.payeeId == friend.id) {
            net += set.amount;
          } else if (set.payerId == friend.id && set.payeeId == currentUserId) {
            net -= set.amount;
          }
        }

        items.add(UserBalanceItem(user: friend, netBalance: net));
      }

      friendBalances.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }

  void goToSettleUp(String friendId, double amount) {
    Get.toNamed(Routes.settleUp, arguments: {
      'friendId': friendId,
      'amount': amount,
    });
  }
}
