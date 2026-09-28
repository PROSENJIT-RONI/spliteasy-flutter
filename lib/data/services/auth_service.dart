import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService extends GetxService {
  bool get isLoggedIn => supabase.auth.currentSession != null;
  String? get currentUserEmail => supabase.auth.currentUser?.email;
  String? get ownerId => supabase.auth.currentUser?.id;

  Future<AuthService> init() async {
    return this;
  }

  Future<bool> checkAuthStatus() async {
    return isLoggedIn;
  }

  Future<void> login(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException('Login failed: Invalid email or password');
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
