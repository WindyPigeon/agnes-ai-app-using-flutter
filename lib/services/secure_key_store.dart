// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's Agnes AI secret key.
///
/// On Android/iOS/macOS/Windows this uses flutter_secure_storage
/// (Keychain/Keystore-backed). On Linux it deliberately does NOT use
/// flutter_secure_storage: that backend talks to the Secret Service over
/// D-Bus, and on a machine without an already-unlocked login keyring
/// (common on minimal/headless Linux setups) that call blocks the platform
/// thread indefinitely waiting for an unlock prompt nobody can answer,
/// freezing the whole app on startup. shared_preferences is used instead —
/// less secure at rest, but reliable; this trade-off is surfaced to the
/// user in the Account screen's key-field helper text.
class SecureKeyStore {
  static const _key = 'agnes_ai_secret_key';
  static const _timeout = Duration(seconds: 5);

  final _storage = const FlutterSecureStorage();

  bool get _useSecureBackend => !Platform.isLinux;

  Future<String> read() async {
    try {
      if (!_useSecureBackend) {
        final prefs = await SharedPreferences.getInstance().timeout(_timeout);
        return prefs.getString(_key) ?? '';
      }
      final value = await _storage.read(key: _key).timeout(_timeout);
      return value ?? '';
    } catch (e) {
      debugPrint('SecureKeyStore.read timed out or failed: $e');
      return '';
    }
  }

  Future<void> write(String apiKey) async {
    try {
      if (!_useSecureBackend) {
        final prefs = await SharedPreferences.getInstance().timeout(_timeout);
        await prefs.setString(_key, apiKey);
        return;
      }
      await _storage.write(key: _key, value: apiKey).timeout(_timeout);
    } catch (e) {
      debugPrint('SecureKeyStore.write timed out or failed: $e');
    }
  }

  Future<void> clear() async {
    try {
      if (!_useSecureBackend) {
        final prefs = await SharedPreferences.getInstance().timeout(_timeout);
        await prefs.remove(_key);
        return;
      }
      await _storage.delete(key: _key).timeout(_timeout);
    } catch (e) {
      debugPrint('SecureKeyStore.clear timed out or failed: $e');
    }
  }
}
