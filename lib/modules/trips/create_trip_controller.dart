import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/trip_model.dart';
import '../../data/services/trip_service.dart';
import '../../widgets/custom_toast.dart';
import '../home/home_controller.dart';
import 'trips_controller.dart';

class CreateTripController extends GetxController {
  final TripService _tripService = Get.find<TripService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final destinationController = TextEditingController();
  final descriptionController = TextEditingController();

  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxBool isLoading = false.obs;

  TripModel? existingTrip;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is TripModel) {
      existingTrip = args;
      nameController.text = existingTrip!.name;
      destinationController.text = existingTrip!.destination;
      descriptionController.text = existingTrip!.description;
      startDate.value = existingTrip!.startDate;
      endDate.value = existingTrip!.endDate;
    }
  }

  Future<void> saveTrip() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      if (existingTrip == null) {
        await _tripService.createTrip(
          name: nameController.text.trim(),
          destination: destinationController.text.trim(),
          startDate: startDate.value,
          endDate: endDate.value,
          description: descriptionController.text.trim(),
        );
      } else {
        await _tripService.updateTrip(
          existingTrip!.id,
          name: nameController.text.trim(),
          destination: destinationController.text.trim(),
          startDate: startDate.value,
          endDate: endDate.value,
          description: descriptionController.text.trim(),
        );
      }

      // 1. Close CreateTripScreen route first!
      Get.back(result: true);

      // 2. Refresh lists on Home and Trips screens if active
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDashboardData();
      }
      if (Get.isRegistered<TripsController>()) {
        Get.find<TripsController>().fetchTrips();
      }

      // 3. Show success toast after returning to previous screen
      CustomToast.success(
        existingTrip == null ? 'Trip created successfully!' : 'Trip updated successfully!',
      );
    } catch (e) {
      CustomToast.error('Failed to save trip: ${e.toString().replaceAll("Exception:", "").trim()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    destinationController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
