import 'dart:async';
import 'package:get/get.dart';
import '../models/trip_model.dart';
import '../models/trip_person_model.dart';
import 'supabase_service.dart';

class TripService extends GetxService {
  final RxList<TripModel> trips = <TripModel>[].obs;

  Future<List<TripModel>> getTrips() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final res = await supabase
          .from('trips')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      final list = (res as List).map((e) => TripModel.fromJson(e)).toList();
      trips.assignAll(list);
      return list;
    } catch (e) {
      return trips;
    }
  }

  Future<TripModel?> getTripById(String id) async {
    try {
      final res = await supabase
          .from('trips')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (res == null) return null;
      return TripModel.fromJson(res);
    } catch (e) {
      return trips.firstWhereOrNull((t) => t.id == id);
    }
  }

  Future<TripModel> createTrip({
    required String name,
    String destination = '',
    DateTime? startDate,
    DateTime? endDate,
    String description = '',
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final insertData = {
      'owner_id': userId,
      'name': name,
      'destination': destination,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      'description': description,
    };

    final res = await supabase.from('trips').insert(insertData).select().single();
    final created = TripModel.fromJson(res);
    trips.insert(0, created);
    return created;
  }

  Future<TripModel> updateTrip(
    String id, {
    required String name,
    String destination = '',
    DateTime? startDate,
    DateTime? endDate,
    String description = '',
  }) async {
    final updateData = {
      'name': name,
      'destination': destination,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final res =
        await supabase.from('trips').update(updateData).eq('id', id).select().single();

    final updated = TripModel.fromJson(res);
    final index = trips.indexWhere((t) => t.id == id);
    if (index != -1) {
      trips[index] = updated;
    }
    return updated;
  }

  Future<void> deleteTrip(String id) async {
    try {
      // 1. Get all expense IDs belonging to this trip
      final expRes = await supabase
          .from('trip_expenses')
          .select('id')
          .eq('trip_id', id);

      final expIds = (expRes as List).map((e) => e['id'] as String).toList();

      // 2. Delete all expense splits for these expenses
      if (expIds.isNotEmpty) {
        await supabase
            .from('expense_splits')
            .delete()
            .inFilter('expense_id', expIds);
      }

      // 3. Delete all expenses for this trip
      await supabase.from('trip_expenses').delete().eq('trip_id', id);

      // 4. Delete all participants for this trip
      await supabase.from('trip_people').delete().eq('trip_id', id);

      // 5. Delete the trip itself
      await supabase.from('trips').delete().eq('id', id);

      trips.removeWhere((t) => t.id == id);
    } catch (e) {
      // Fallback direct delete in case cascade is configured
      await supabase.from('trips').delete().eq('id', id);
      trips.removeWhere((t) => t.id == id);
    }
  }

  // Participant / Trip People Methods
  Future<List<TripPersonModel>> getTripPeople(String tripId) async {
    try {
      final res = await supabase
          .from('trip_people')
          .select()
          .eq('trip_id', tripId)
          .order('name', ascending: true);

      return (res as List).map((e) => TripPersonModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<TripPersonModel> addTripPerson(
    String tripId, {
    required String name,
    String phone = '',
  }) async {
    final insertData = {
      'trip_id': tripId,
      'name': name,
      'phone': phone,
    };

    final res =
        await supabase.from('trip_people').insert(insertData).select().single();

    return TripPersonModel.fromJson(res);
  }

  Future<TripPersonModel> updateTripPerson(
    String personId, {
    required String name,
    String phone = '',
  }) async {
    final updateData = {
      'name': name,
      'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final res = await supabase
        .from('trip_people')
        .update(updateData)
        .eq('id', personId)
        .select()
        .single();

    return TripPersonModel.fromJson(res);
  }

  Future<void> deleteTripPerson(String personId) async {
    // Check if referenced as paid_by_person_id in trip_expenses
    final expenseCountRes = await supabase
        .from('trip_expenses')
        .select('id')
        .eq('paid_by_person_id', personId);

    if ((expenseCountRes as List).isNotEmpty) {
      throw Exception(
          'Cannot delete participant because they paid for expenses in this trip. Remove or reassign related expenses first.');
    }

    // Check if referenced in expense_splits
    final splitCountRes = await supabase
        .from('expense_splits')
        .select('id')
        .eq('person_id', personId);

    if ((splitCountRes as List).isNotEmpty) {
      throw Exception(
          'Cannot delete participant because they have shares in expenses in this trip. Remove or edit related expenses first.');
    }

    await supabase.from('trip_people').delete().eq('id', personId);
  }
}
