import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/services/group_service.dart';
import '../../data/services/friend_service.dart';
import '../../widgets/custom_toast.dart';

class CreateGroupController extends GetxController {
  final GroupService _groupService = Get.find<GroupService>();
  final FriendService _friendService = Get.find<FriendService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final memberInputController = TextEditingController();

  final RxString selectedEmoji = '🏖️'.obs;
  final RxString selectedCategory = 'Trip'.obs;
  final RxList<UserModel> availableFriends = <UserModel>[].obs;
  final RxList<String> selectedMemberIds = <String>[].obs;
  final RxBool isLoading = false.obs;

  final List<String> emojiOptions = ['🏖️', '🏠', '🍕', '🚗', '🎟️', '✈️', '🛒', '🎉'];
  final List<String> categoryOptions = ['Trip', 'Home', 'Couple', 'Other'];

  @override
  void onInit() {
    super.onInit();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final friends = await _friendService.getFriends();
    availableFriends.assignAll(friends);
  }

  void toggleMember(String userId) {
    if (selectedMemberIds.contains(userId)) {
      selectedMemberIds.remove(userId);
    } else {
      selectedMemberIds.add(userId);
    }
  }

  Future<void> addMemberByInput() async {
    final input = memberInputController.text.trim();
    if (input.isEmpty) {
      CustomToast.error('Please enter email or phone number');
      return;
    }

    isLoading.value = true;
    try {
      final friend = await _friendService.addFriendByPhone(input);
      if (friend != null) {
        if (!availableFriends.any((f) => f.id == friend.id)) {
          availableFriends.add(friend);
        }
        if (!selectedMemberIds.contains(friend.id)) {
          selectedMemberIds.add(friend.id);
        }
        memberInputController.clear();
        CustomToast.success('Added ${friend.name} to group!');
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception:', '').trim();
      CustomToast.error(msg.isNotEmpty ? msg : 'User not found');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createGroup() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _groupService.createGroup(
        name: nameController.text.trim(),
        icon: selectedEmoji.value,
        category: selectedCategory.value,
        description: descriptionController.text.trim(),
        memberIds: selectedMemberIds,
      );

      CustomToast.success('Group created successfully!');
      Get.back();
    } catch (e) {
      CustomToast.error('Failed to create group');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    memberInputController.dispose();
    super.onClose();
  }
}
