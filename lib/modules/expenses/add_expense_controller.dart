import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/group_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/expense_service.dart';
import '../../data/services/group_service.dart';
import '../../data/services/friend_service.dart';
import '../../data/services/storage_service.dart';
import '../../widgets/custom_toast.dart';

class AddExpenseController extends GetxController {
  final ExpenseService _expenseService = Get.find<ExpenseService>();
  final GroupService _groupService = Get.find<GroupService>();
  final FriendService _friendService = Get.find<FriendService>();
  final StorageService _storageService = Get.find<StorageService>();
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  final Rx<GroupModel?> selectedGroup = Rx<GroupModel?>(null);
  final RxList<GroupModel> groups = <GroupModel>[].obs;

  final RxList<UserModel> availableParticipants = <UserModel>[].obs;
  final RxList<String> selectedParticipantIds = <String>[].obs;

  final RxString selectedPaidByUserId = ''.obs;
  final Rx<SplitType> selectedSplitType = SplitType.equal.obs;
  final RxString selectedCategory = 'Food'.obs;

  final RxMap<String, TextEditingController> customShareControllers =
      <String, TextEditingController>{}.obs;

  final Rx<String?> receiptImagePath = Rx<String?>(null);
  final RxBool isLoading = false.obs;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.restaurant_rounded},
    {'name': 'Travel', 'icon': Icons.flight_takeoff_rounded},
    {'name': 'Rent', 'icon': Icons.home_rounded},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded},
    {'name': 'Entertainment', 'icon': Icons.movie_rounded},
    {'name': 'Other', 'icon': Icons.receipt_rounded},
  ];

  @override
  void onInit() {
    super.onInit();
    final currentU = _authService.currentUser.value;
    if (currentU != null) {
      selectedPaidByUserId.value = currentU.id;
    }
    _initData();
  }

  Future<void> _initData() async {
    final groupList = await _groupService.getGroups();
    groups.assignAll(groupList);

    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('groupId')) {
      final gId = args['groupId'] as String;
      final match = groups.firstWhereOrNull((g) => g.id == gId);
      if (match != null) {
        onGroupSelected(match);
      }
    } else if (groups.isNotEmpty) {
      onGroupSelected(groups.first);
    } else {
      onGroupSelected(null);
    }
  }

  void onGroupSelected(GroupModel? group) async {
    selectedGroup.value = group;
    final currentU = _authService.currentUser.value;
    if (currentU != null) {
      selectedPaidByUserId.value = currentU.id;
    }

    if (group != null) {
      final members = await _groupService.getGroupMembers(group.id);
      availableParticipants.assignAll(members);
      selectedParticipantIds.assignAll(members.map((m) => m.id));
    } else if (currentU != null) {
      final friends = await _friendService.getFriends();
      availableParticipants.assignAll([currentU, ...friends]);
      selectedParticipantIds.assignAll([currentU.id, if (friends.isNotEmpty) friends.first.id]);
    }
    _rebuildCustomShareControllers();
  }

  void toggleParticipant(String userId) {
    if (selectedParticipantIds.contains(userId)) {
      if (selectedParticipantIds.length > 1) {
        selectedParticipantIds.remove(userId);
      }
    } else {
      selectedParticipantIds.add(userId);
    }
    _rebuildCustomShareControllers();
  }

  void _rebuildCustomShareControllers() {
    for (var userId in selectedParticipantIds) {
      if (!customShareControllers.containsKey(userId)) {
        customShareControllers[userId] = TextEditingController(text: '0');
      }
    }
  }

  double get totalAmount => double.tryParse(amountController.text) ?? 0.0;

  Map<String, double> calculateSplitDetails() {
    final count = selectedParticipantIds.length;
    if (count == 0 || totalAmount <= 0) return {};

    Map<String, double> details = {};

    switch (selectedSplitType.value) {
      case SplitType.equal:
        final perPerson = (totalAmount / count);
        for (var id in selectedParticipantIds) {
          details[id] = double.parse(perPerson.toStringAsFixed(2));
        }
        break;

      case SplitType.unequal:
        for (var id in selectedParticipantIds) {
          final val = double.tryParse(customShareControllers[id]?.text ?? '0') ?? 0.0;
          details[id] = val;
        }
        break;

      case SplitType.percentage:
        for (var id in selectedParticipantIds) {
          final pct = double.tryParse(customShareControllers[id]?.text ?? '0') ?? 0.0;
          details[id] = double.parse(((totalAmount * pct) / 100).toStringAsFixed(2));
        }
        break;
    }

    return details;
  }

  Future<void> pickReceipt(ImageSource source) async {
    final path = await _storageService.pickImage(source);
    if (path != null) {
      receiptImagePath.value = path;
    }
  }

  Future<void> saveExpense() async {
    if (!formKey.currentState!.validate()) return;

    if (totalAmount <= 0) {
      CustomToast.error('Please enter a valid amount');
      return;
    }

    final splitDetails = calculateSplitDetails();

    isLoading.value = true;
    try {
      final expense = ExpenseModel(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        groupId: selectedGroup.value?.id,
        description: descriptionController.text.trim(),
        amount: totalAmount,
        paidByUserId: selectedPaidByUserId.value,
        splitType: selectedSplitType.value,
        splitDetails: splitDetails,
        category: selectedCategory.value,
        receiptPath: receiptImagePath.value,
        createdAt: DateTime.now(),
        participantIds: selectedParticipantIds,
      );

      await _expenseService.addExpense(expense);
      CustomToast.success('Expense added successfully!');
      Get.back();
    } catch (e) {
      CustomToast.error('Failed to add expense');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    for (var c in customShareControllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}
