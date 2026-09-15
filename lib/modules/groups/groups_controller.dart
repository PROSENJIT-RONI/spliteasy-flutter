import 'package:get/get.dart';
import '../../data/models/group_model.dart';
import '../../data/services/group_service.dart';
import '../../app/routes/app_routes.dart';

class GroupsController extends GetxController {
  final GroupService _groupService = Get.find<GroupService>();

  final RxList<GroupModel> groups = <GroupModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    isLoading.value = true;
    try {
      final list = await _groupService.getGroups();
      groups.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  void goToCreateGroup() => Get.toNamed(Routes.createGroup);
  void goToGroupDetail(String id) => Get.toNamed(Routes.groupDetail, arguments: id);
}
