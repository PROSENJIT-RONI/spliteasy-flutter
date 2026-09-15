import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/settlement_service.dart';
import '../../data/services/friend_service.dart';
import '../../widgets/custom_toast.dart';

class SettleUpController extends GetxController {
  final SettlementService _settlementService = Get.find<SettlementService>();
  final FriendService _friendService = Get.find<FriendService>();
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  final Rx<UserModel?> selectedPayer = Rx<UserModel?>(null);
  final Rx<UserModel?> selectedPayee = Rx<UserModel?>(null);
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final currentU = _authService.currentUser.value;
    selectedPayer.value = currentU;

    final friends = await _friendService.getFriends();
    if (currentU != null) {
      users.assignAll([currentU, ...friends]);
    } else {
      users.assignAll(friends);
    }

    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args.containsKey('friendId')) {
        final fId = args['friendId'] as String;
        selectedPayee.value = users.firstWhereOrNull((u) => u.id == fId);
      }
      if (args.containsKey('amount')) {
        amountController.text = (args['amount'] as double).toStringAsFixed(2);
      }
    } else if (friends.isNotEmpty) {
      selectedPayee.value = friends.first;
    }
  }

  Future<void> confirmSettlement() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedPayer.value == null || selectedPayee.value == null) {
      CustomToast.error('Please select payer and payee');
      return;
    }

    if (selectedPayer.value!.id == selectedPayee.value!.id) {
      CustomToast.error('Payer and Payee cannot be the same person');
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) {
      CustomToast.error('Please enter a valid settlement amount');
      return;
    }

    isLoading.value = true;
    try {
      await _settlementService.createSettlement(
        payerId: selectedPayer.value!.id,
        payeeId: selectedPayee.value!.id,
        amount: amount,
        note: noteController.text.trim(),
      );

      CustomToast.success('Settlement recorded successfully!');
      Get.back();
    } catch (e) {
      CustomToast.error('Failed to record settlement');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
