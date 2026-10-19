import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/api.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';

export '../services/auth_service.dart' show AuthException, AuthUser;

/// Status masuk aplikasi dan jembatan ke REST API.
///
/// Ini **satu-satunya sumber kebenaran** soal siapa yang sedang masuk. Layar
/// mana pun yang menampilkan nama pengguna cukup mendengarkan
/// [AuthStore.currentUser], tidak perlu menyimpan salinannya sendiri.
///
/// Ada dua jalur:
/// - **Daring** — `signIn`, `signUp`, `signInWithGoogle`, `saveProfile`, dan
///   `savePassword` memakai REST API dan menyimpan token Sanctum di
///   [ApiConfig.token].
/// - **Lokal** — `login`, `register`, `loginWithGoogle`, `updateProfile`, dan
///   `changePassword` memakai [AuthService] yang serba di memori. Jalur ini
///   dipakai saat [ApiConfig.enabled] bernilai `false` (mis. pada pengujian)
///   dan menjadi cadangan kalau API tidak dipakai.
class AuthStore {
  const AuthStore._();

  /// Pengguna yang sedang masuk, atau `null` kalau belum masuk.
  static final ValueNotifier<AuthUser?> currentUser =
      ValueNotifier<AuthUser?>(null);

  /// `true` kalau sudah ada pengguna yang masuk.
  static bool get isLoggedIn => currentUser.value != null;

  /// Nama yang siap ditampilkan: nama pengguna, atau `'Guest'` kalau belum masuk.
  static String get displayName => currentUser.value?.name ?? 'Guest';

  // --- Jalur REST API ---------------------------------------------------

  /// Masuk lewat API. Melempar [AuthException] kalau gagal.
  static Future<AuthUser> signIn({
    required String identifier,
    required String password,
  }) async {
    if (!ApiConfig.enabled) {
      return login(identifier: identifier, password: password);
    }

    try {
      return _startSession(
        await ApiClient.post(
          '/auth/login',
          body: {'identifier': identifier, 'password': password},
        ),
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  /// Mendaftarkan akun lewat API, lalu langsung masuk.
  static Future<AuthUser> signUp({
    required String name,
    required String identifier,
    required String password,
    required String confirmPassword,
  }) async {
    if (!ApiConfig.enabled) {
      return register(
        name: name,
        identifier: identifier,
        password: password,
        confirmPassword: confirmPassword,
      );
    }

    try {
      return _startSession(
        await ApiClient.post(
          '/auth/register',
          body: {
            'name': name,
            'identifier': identifier,
            'password': password,
            'password_confirmation': confirmPassword,
          },
        ),
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  /// Masuk memakai simulasi akun Google lewat API.
  static Future<AuthUser> signInWithGoogle() async {
    if (!ApiConfig.enabled) return loginWithGoogle();

    try {
      return _startSession(
        await ApiClient.post(
          '/auth/login/google',
          body: {
            'identifier': AuthService.googleIdentifier,
            'name': 'Pengguna Google',
          },
        ),
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  /// Menyimpan nama dan email/nomor HP lewat API.
  static Future<AuthUser> saveProfile({
    required String name,
    required String identifier,
  }) async {
    final current = currentUser.value;
    if (current == null) {
      throw const AuthException('Belum masuk. Silakan login dulu.');
    }

    if (!ApiConfig.enabled || !ApiConfig.hasToken) {
      return updateProfile(name: name, identifier: identifier);
    }

    try {
      final response = await ApiClient.put(
        '/profile',
        body: {'name': name, 'identifier': identifier},
      );

      final user = dataOf(response)?['user'];
      final updated = AuthUser(
        name: '${user is Map ? user['name'] : name}',
        identifier: '${user is Map ? user['identifier'] : identifier}',
      );
      currentUser.value = updated;
      return updated;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  /// Mengganti password lewat API.
  static Future<void> savePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!ApiConfig.enabled || !ApiConfig.hasToken) {
      changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      throw const AuthException('Ulangi password baru dengan benar.');
    }

    try {
      await ApiClient.put(
        '/profile/password',
        body: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  // --- Jalur lokal (tanpa API) ------------------------------------------

  /// Masuk memakai akun lokal. Melempar [AuthException] kalau gagal.
  static AuthUser login({
    required String identifier,
    required String password,
  }) {
    final user = AuthService.login(identifier: identifier, password: password);
    currentUser.value = user;
    return user;
  }

  /// Daftar akun lokal, lalu langsung dianggap masuk.
  static AuthUser register({
    required String name,
    required String identifier,
    required String password,
    required String confirmPassword,
  }) {
    final user = AuthService.register(
      name: name,
      identifier: identifier,
      password: password,
      confirmPassword: confirmPassword,
    );
    currentUser.value = user;
    return user;
  }

  /// Masuk memakai akun simulasi Google (lokal).
  static AuthUser loginWithGoogle() {
    final user = AuthService.loginWithGoogle();
    currentUser.value = user;
    return user;
  }

  /// Mengubah nama dan email/nomor HP pengguna lokal.
  static AuthUser updateProfile({
    required String name,
    required String identifier,
  }) {
    final current = currentUser.value;
    if (current == null) {
      throw const AuthException('Belum masuk. Silakan login dulu.');
    }

    final user = AuthService.updateProfile(
      currentIdentifier: current.identifier,
      newName: name,
      newIdentifier: identifier,
    );
    currentUser.value = user;
    return user;
  }

  /// Mengganti password pengguna lokal.
  static void changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final current = currentUser.value;
    if (current == null) {
      throw const AuthException('Belum masuk. Silakan login dulu.');
    }

    AuthService.changePassword(
      currentIdentifier: current.identifier,
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  /// Keluar dan kembali ke keadaan belum masuk.
  static void logout() {
    if (ApiConfig.enabled && ApiConfig.hasToken) {
      // Kirim permintaan keluar tanpa menunggu; kalau gagal pun sesi lokal
      // tetap diakhiri.
      unawaited(
        ApiClient.post('/auth/logout').then((_) {}, onError: (_) {}),
      );
    }

    ApiConfig.token = null;
    currentUser.value = null;
  }

  // --- Pembantu ---------------------------------------------------------

  /// Menyimpan token dan pengguna dari respons login/daftar, lalu menarik data
  /// milik pengguna dari server.
  static AuthUser _startSession(Map<String, dynamic> response) {
    final data = dataOf(response) ?? const <String, dynamic>{};
    ApiConfig.token = '${data['token'] ?? ''}';

    final user = data['user'];
    final authUser = AuthUser(
      name: '${user is Map ? user['name'] : ''}',
      identifier: '${user is Map ? user['identifier'] : ''}',
    );

    currentUser.value = authUser;
    unawaited(SyncService.refreshUserData());

    return authUser;
  }
}
