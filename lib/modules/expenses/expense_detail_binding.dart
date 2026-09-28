import 'package:get/get.dart';
import 'expense_detail_controller.dart';

class ExpenseDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseDetailController>(() => ExpenseDetailController());
  }
}
