import 'dart:async';
import 'package:get/get.dart';
import '../models/settlement_model.dart';
import 'supabase_service.dart';

class SettlementService extends GetxService {
  final RxList<SettlementModel> settlements = <SettlementModel>[].obs;

  Future<List<SettlementModel>> getSettlements() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final res = await supabase
          .from('settlements')
          .select()
          .or('payer_id.eq.$userId,payee_id.eq.$userId')
          .order('created_at', ascending: false);

      final list =
          (res as List).map((e) => SettlementModel.fromJson(e)).toList();
      settlements.assignAll(list);
      return list;
    } catch (e) {
      return settlements;
    }
  }

  Future<SettlementModel> createSettlement({
    String? groupId,
    required String payerId,
    required String payeeId,
    required double amount,
    String? note,
  }) async {
    final insertData = {
      'group_id': groupId,
      'payer_id': payerId,
      'payee_id': payeeId,
      'amount': amount,
      'note': note,
    };

    final res =
        await supabase.from('settlements').insert(insertData).select().single();

    final created = SettlementModel.fromJson(res);
    settlements.insert(0, created);
    return created;
  }
}
