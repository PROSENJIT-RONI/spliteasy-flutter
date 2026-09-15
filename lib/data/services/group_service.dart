import 'dart:async';
import 'package:get/get.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class GroupService extends GetxService {
  final RxList<GroupModel> groups = <GroupModel>[].obs;

  Future<List<GroupModel>> getGroups() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final memberRes = await supabase
          .from('group_members')
          .select('group_id')
          .eq('user_id', userId);

      final groupIds = (memberRes as List)
          .map((e) => e['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) {
        groups.clear();
        return [];
      }

      final groupsRes = await supabase
          .from('groups')
          .select('*, group_members(user_id)')
          .inFilter('id', groupIds)
          .order('created_at', ascending: false);

      List<GroupModel> result = [];
      for (var map in (groupsRes as List)) {
        final membersList = (map['group_members'] as List? ?? [])
            .map((m) => m['user_id'] as String)
            .toList();
        final gMap = Map<String, dynamic>.from(map);
        gMap['member_ids'] = membersList;
        result.add(GroupModel.fromJson(gMap));
      }

      groups.assignAll(result);
      return result;
    } catch (e) {
      return groups;
    }
  }

  Future<GroupModel?> getGroupById(String id) async {
    try {
      final res = await supabase
          .from('groups')
          .select('*, group_members(user_id)')
          .eq('id', id)
          .maybeSingle();

      if (res == null) return null;
      final gMap = Map<String, dynamic>.from(res);
      final membersList = (res['group_members'] as List? ?? [])
          .map((m) => m['user_id'] as String)
          .toList();
      gMap['member_ids'] = membersList;
      return GroupModel.fromJson(gMap);
    } catch (e) {
      return groups.firstWhereOrNull((g) => g.id == id);
    }
  }

  Future<GroupModel> createGroup({
    required String name,
    required String icon,
    required String category,
    String description = '',
    required List<String> memberIds,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final groupData = {
      'name': name,
      'icon': icon.isEmpty ? '👥' : icon,
      'category': category,
      'description': description,
      'created_by': userId,
    };

    final res = await supabase.from('groups').insert(groupData).select().single();
    final groupId = res['id'] as String;

    final allMembers = <String>{userId, ...memberIds}.toList();
    final memberInserts = allMembers
        .map((mId) => {
              'group_id': groupId,
              'user_id': mId,
            })
        .toList();

    await supabase.from('group_members').insert(memberInserts);

    final createdGroup = GroupModel.fromJson({
      ...res,
      'member_ids': allMembers,
    });

    groups.insert(0, createdGroup);
    return createdGroup;
  }

  Future<List<UserModel>> getGroupMembers(String groupId) async {
    try {
      final res = await supabase
          .from('group_members')
          .select('profiles(*)')
          .eq('group_id', groupId);

      List<UserModel> result = [];
      for (var map in (res as List)) {
        if (map['profiles'] != null) {
          result.add(UserModel.fromJson(map['profiles']));
        }
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<UserModel> addMemberToGroup(String groupId, String emailOrPhone) async {
    final profileRes = await supabase
        .from('profiles')
        .select()
        .or('email.eq.$emailOrPhone,phone.eq.$emailOrPhone')
        .maybeSingle();

    if (profileRes == null) {
      throw Exception('No user found with email/phone: $emailOrPhone');
    }

    final user = UserModel.fromJson(profileRes);

    await supabase.from('group_members').upsert({
      'group_id': groupId,
      'user_id': user.id,
    });

    return user;
  }
}
