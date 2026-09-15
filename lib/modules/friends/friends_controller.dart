import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/services/friend_service.dart';
import '../../widgets/custom_toast.dart';
import '../../app/routes/app_routes.dart';

class FriendsController extends GetxController {
  final FriendService _friendService = Get.find<FriendService>();

  final RxList<UserModel> friends = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    isLoading.value = true;
    try {
      final list = await _friendService.getFriends();
      friends.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFriend() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      CustomToast.error('Please enter a phone number');
      return;
    }

    isLoading.value = true;
    try {
      final friend = await _friendService.addFriendByPhone(phone);
      if (friend != null) {
        CustomToast.success('Added ${friend.name} to friends!');
        phoneController.clear();
        Get.back();
        fetchFriends();
      }
    } catch (e) {
      CustomToast.error('Failed to add friend');
    } finally {
      isLoading.value = false;
    }
  }

  void goToAddExpenseWithFriend(UserModel friend) {
    Get.toNamed(Routes.addExpense);
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
