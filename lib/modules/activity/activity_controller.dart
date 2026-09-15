import 'package:get/get.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/supabase_service.dart';

class ActivityController extends GetxController {
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadActivities();
  }

  Future<void> loadActivities() async {
    isLoading.value = true;
    try {
      final res = await supabase
          .from('activity_feed')
          .select()
          .order('created_at', ascending: false);

      final list = (res as List).map((e) => ActivityModel.fromJson(e)).toList();
      activities.assignAll(list);
    } catch (e) {
      activities.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
