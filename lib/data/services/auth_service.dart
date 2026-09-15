import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService extends GetxService {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  bool get loggedIn => supabase.auth.currentSession != null;

  Future<AuthService> init() async {
    await checkAuthStatus();
    return this;
  }

  Future<bool> checkAuthStatus() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      await fetchCurrentProfile();
      return true;
    }
    currentUser.value = null;
    return false;
  }

  Future<UserModel?> fetchCurrentProfile() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return null;

    try {
      final res = await supabase
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (res != null) {
        final profile = UserModel.fromJson(res);
        currentUser.value = profile;
        return profile;
      }
    } catch (e) {
      debugPrint('Profile query exception: $e');
    }

    // Auto-heal: If user was created directly in Supabase Dashboard (or trigger hadn't run),
    // automatically upsert a row into 'profiles' table.
    final meta = authUser.userMetadata ?? {};
    final defaultName = (meta['name'] as String?)?.isNotEmpty == true
        ? meta['name'] as String
        : (authUser.email?.split('@').first ?? 'User');

    final fallback = UserModel(
      id: authUser.id,
      name: defaultName,
      email: authUser.email ?? '',
      phone: (meta['phone'] as String?) ?? '',
      gender: (meta['gender'] as String?) ?? 'Other',
    );

    try {
      await supabase.from('profiles').upsert({
        'id': authUser.id,
        'name': fallback.name,
        'email': fallback.email,
        'phone': fallback.phone,
        'gender': fallback.gender,
      });
    } catch (err) {
      debugPrint('Auto-heal profile creation error: $err');
    }

    currentUser.value = fallback;
    return fallback;
  }

  Future<UserModel> login(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException('Login failed: Invalid credentials');
    }

    final profile = await fetchCurrentProfile();
    return profile!;
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
        'gender': gender,
      },
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Registration failed: No user created');
    }

    if (response.session != null) {
      try {
        await supabase.from('profiles').upsert({
          'id': user.id,
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
        });
        await fetchCurrentProfile();
      } catch (_) {}
    }

    return response;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    currentUser.value = null;
  }

  Future<UserModel> updateProfile({
    required String name,
    required String gender,
    String? avatarPath,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw const AuthException('Not authenticated');

    final updateData = {
      'name': name,
      'gender': gender,
      if (avatarPath != null) 'avatar_path': avatarPath,
    };

    await supabase.from('profiles').update(updateData).eq('id', userId);

    final updated = await fetchCurrentProfile();
    return updated!;
  }
}
