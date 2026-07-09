import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  final PocketBase _pb;

  static const String _authStoreKey = 'pb_auth_store';

  // Private constructor
  AuthService._(this._pb);

  // Static factory method for async initialization
  static Future<AuthService> create() async {
    final prefs = await SharedPreferences.getInstance();

    final store = AsyncAuthStore(
      save: (String data) async {
        await prefs.setString(_authStoreKey, data);
      },
      initial: prefs.getString(_authStoreKey),
      clear: () async {
        await prefs.remove(_authStoreKey);
      },
    );

    final pb = PocketBase('https://metube.pockethost.io', authStore: store);

    final authService = AuthService._(pb);

    // Listen for changes and notify listeners
    pb.authStore.onChange.listen((_) {
      authService.notifyListeners();
    });

    return authService;
  }

  PocketBase get pb => _pb;

  Future<void> signIn(String email, String password) async {
    try {
      await _pb.collection('users').authWithPassword(email, password);
      notifyListeners();
    } catch (e) {
      log('Login failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    _pb.authStore.clear();
    notifyListeners();
  }

  Future<void> signUp(
    String username,
    String email,
    String password,
    String passwordConfirm,
  ) async {
    try {
      await _pb
          .collection('users')
          .create(
            body: {
              'username': username,
              'email': email,
              'password': password,
              'passwordConfirm': passwordConfirm,
            },
          );
      await signIn(email, password);
    } catch (e) {
      log('Sign-up failed: $e');
      rethrow;
    }
  }

  Future<void> requestEmailChange(String newEmail) async {
    try {
      await _pb.collection('users').requestEmailChange(newEmail);
    } catch (e) {
      log('Request email change failed: $e');
      rethrow;
    }
  }

  Future<void> changeUsername(String newUsername) async {
    try {
      await _pb
          .collection('users')
          .update(userId!, body: {'username': newUsername});
    } catch (e) {
      log('Change username failed: $e');
      rethrow;
    }
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String newPasswordConfirm,
  ) async {
    try {
      await _pb
          .collection('users')
          .update(
            userId!,
            body: {
              'oldPassword': oldPassword,
              'password': newPassword,
              'passwordConfirm': newPasswordConfirm,
            },
          );
    } catch (e) {
      log('Change password failed: $e');
      rethrow;
    }
  }

  bool get isSignedIn => _pb.authStore.isValid;

  String? get userEmail => _pb.authStore.record?.data['email'] as String?;
  String? get username => _pb.authStore.record?.data['username'] as String?;
  String? get userId => _pb.authStore.record?.id;

  String? get userAvatarUrl {
    final record = _pb.authStore.record;
    if (record == null) {
      return null;
    }
    final avatarFilename = record.data['avatar']?.toString();
    if (avatarFilename == null || avatarFilename.isEmpty) {
      return null;
    }
    return _pb.files.getUrl(record, avatarFilename).toString();
  }
}
