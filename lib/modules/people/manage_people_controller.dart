import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/trip_person_model.dart';
import '../../data/services/trip_service.dart';
import '../../widgets/custom_toast.dart';

class ManagePeopleController extends GetxController {
  final TripService _tripService = Get.find<TripService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final RxList<TripPersonModel> people = <TripPersonModel>[].obs;
  final RxBool isLoading = false.obs;

  TripPersonModel? editingPerson;
  String tripId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      if (args is String) {
        tripId = args;
      } else if (args is Map && args.containsKey('tripId')) {
        tripId = args['tripId'] as String;
      }
    }
    loadPeople();
  }

  Future<void> loadPeople() async {
    if (tripId.isEmpty) return;
    isLoading.value = true;
    try {
      final list = await _tripService.getTripPeople(tripId);
      people.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  void openAddDialog(BuildContext context) {
    editingPerson = null;
    nameController.clear();
    phoneController.clear();
    _showPersonDialog(context, isEditing: false);
  }

  void openEditDialog(BuildContext context, TripPersonModel person) {
    editingPerson = person;
    nameController.text = person.name;
    phoneController.text = person.phone;
    _showPersonDialog(context, isEditing: true);
  }

  Future<void> savePerson() async {
    if (!formKey.currentState!.validate()) return;

    if (tripId.isEmpty) {
      CustomToast.error('Invalid Trip ID');
      return;
    }

    isLoading.value = true;
    try {
      if (editingPerson == null) {
        final person = await _tripService.addTripPerson(
          tripId,
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
        );
        people.add(person);
      } else {
        final updated = await _tripService.updateTripPerson(
          editingPerson!.id,
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
        );
        final index = people.indexWhere((p) => p.id == editingPerson!.id);
        if (index != -1) {
          people[index] = updated;
        }
      }

      // Close dialog first
      Get.back();

      // Show success toast
      CustomToast.success(
        editingPerson == null ? 'Participant added!' : 'Participant updated!',
      );
    } catch (e) {
      String msg = 'Failed to save participant';
      if (e is PostgrestException) {
        msg = e.message;
      } else {
        msg = e.toString().replaceAll('Exception:', '').trim();
      }
      CustomToast.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePerson(TripPersonModel person) async {
    try {
      await _tripService.deleteTripPerson(person.id);
      people.removeWhere((p) => p.id == person.id);
      CustomToast.success('Participant removed!');
    } catch (e) {
      String msg = 'Cannot delete participant';
      if (e is PostgrestException) {
        msg = e.message;
      } else {
        msg = e.toString().replaceAll('Exception:', '').trim();
      }
      CustomToast.error(msg);
    }
  }

  void _showPersonDialog(BuildContext context, {required bool isEditing}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Participant' : 'Add Participant'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Participant Name *',
                    hintText: 'e.g. Rahul',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    hintText: 'e.g. 9876543210',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: savePerson,
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
