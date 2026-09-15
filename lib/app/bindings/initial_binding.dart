import 'package:get/get.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/group_service.dart';
import '../../data/services/expense_service.dart';
import '../../data/services/friend_service.dart';
import '../../data/services/settlement_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<GroupService>(GroupService(), permanent: true);
    Get.put<ExpenseService>(ExpenseService(), permanent: true);
    Get.put<FriendService>(FriendService(), permanent: true);
    Get.put<SettlementService>(SettlementService(), permanent: true);
  }
}
