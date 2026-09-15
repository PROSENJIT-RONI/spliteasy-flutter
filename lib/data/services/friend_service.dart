import 'dart:async';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class FriendService extends GetxService {
  final RxList<UserModel> friends = <UserModel>[].obs;

  Future<List<UserModel>> getFriends() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final res = await supabase
          .from('friends')
          .select('friend_id, profiles!friends_friend_id_fkey(*)')
          .eq('user_id', userId);

      List<UserModel> list = [];
      for (var map in (res as List)) {
        if (map['profiles'] != null) {
          list.add(UserModel.fromJson(map['profiles']));
        }
      }

      friends.assignAll(list);
      return list;
    } catch (e) {
      try {
        final res = await supabase
            .from('friends')
            .select('friend_id, profiles(*)')
            .eq('user_id', userId);

        List<UserModel> list = [];
        for (var map in (res as List)) {
          if (map['profiles'] != null) {
            list.add(UserModel.fromJson(map['profiles']));
          }
        }
        friends.assignAll(list);
        return list;
      } catch (_) {
        return friends;
      }
    }
  }

  Future<UserModel?> addFriendByPhone(String input) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final profileRes = await supabase
        .from('profiles')
        .select()
        .or('phone.eq.$input,email.eq.$input')
        .maybeSingle();

    if (profileRes == null) {
      throw Exception('User not found with input: $input');
    }

    final friend = UserModel.fromJson(profileRes);

    if (friend.id == userId) {
      throw Exception('You cannot add yourself as a friend');
    }

    await supabase.from('friends').upsert({
      'user_id': userId,
      'friend_id': friend.id,
    });

    if (!friends.any((f) => f.id == friend.id)) {
      friends.add(friend);
    }
    return friend;
  }
}
