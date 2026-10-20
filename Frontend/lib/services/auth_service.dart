import 'package:flutter/foundation.dart';

/// Pengguna yang berhasil masuk.
@immutable
class AuthUser {
  /// Nama yang ditampilkan, mis. pada sapaan "Hai, [nama]".
  final String name;

  /// Email atau nomor HP yang dipakai untuk masuk.
  final String identifier;

  const AuthUser({required this.name, required this.identifier});
}

/// Kesalahan autentikasi yang aman untuk ditampilkan ke pengguna.
///
/// `message` sudah berbahasa Indonesia dan siap dimasukkan ke `SnackBar`.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Satu akun yang tersimpan di perangkat.
class _Account {
  final String name;
  final String identifier;
  final String password;

  const _Account({
    required this.name,
    required this.identifier,
    required this.password,
  });
}

/// Logika Login & Daftar.
///
/// **Belum ada server**, jadi akun disimpan di memori saja: seluruh akun hilang
/// saat aplikasi ditutup. Struktur ini sengaja dipisah dari widget supaya nanti
/// bisa diganti menjadi panggilan API tanpa menyentuh layar mana pun — cukup
/// ganti isi method di kelas ini.
class AuthService {
  const AuthService._();

  /// Akun demo supaya Login bisa langsung dicoba tanpa mendaftar dulu.
  static const String demoIdentifier = 'demo@kangenan.com';
  static const String demoPassword = '123456';

  /// Identifier akun simulasi "Lanjutkan dengan Google".
  static const String googleIdentifier = 'pengguna.google@gmail.com';

  /// Minimal panjang password.
  static const int minimumPasswordLength = 6;

  /// Akun yang terdaftar, dikunci oleh email/nomor HP huruf kecil.
  static final Map<String, _Account> _accounts = {
    demoIdentifier: const _Account(
      name: 'Demo',
      identifier: demoIdentifier,
      password: demoPassword,
    ),
  };

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9]{9,15}$');
  static final RegExp _phoneSeparator = RegExp(r'[\s-]');

  /// Kunci pencarian akun: tanpa spasi di ujung, huruf kecil.
  static String _key(String identifier) => identifier.trim().toLowerCase();

  /// `true` kalau [identifier] berbentuk email, bukan nomor HP.
  static bool isEmail(String identifier) => identifier.contains('@');

  /// Memvalidasi email atau nomor HP. Melempar [AuthException] kalau tidak valid.
  static void validateIdentifier(String identifier) {
    final value = identifier.trim();
    if (value.isEmpty) {
      throw const AuthException('Email atau nomor HP harus diisi.');
    }

    if (isEmail(value)) {
      if (!_emailPattern.hasMatch(value)) {
        throw const AuthException(
          'Format email tidak valid. Contoh: nama@email.com',
        );
      }
      return;
    }

    // Boleh ditulis 0812-3456-7890 atau +62 812 3456 7890.
    final digits = value.replaceAll(_phoneSeparator, '');
    if (!_phonePattern.hasMatch(digits)) {
      throw const AuthException(
        'Format nomor HP tidak valid. Contoh: 08123456789',
      );
    }
  }

  /// Memvalidasi password. Melempar [AuthException] kalau tidak valid.
  static void validatePassword(String password) {
    if (password.isEmpty) {
      throw const AuthException('Password harus diisi.');
    }
    if (password.length < minimumPasswordLength) {
      throw const AuthException(
        'Password minimal $minimumPasswordLength karakter.',
      );
    }
  }

  /// Memvalidasi nama pengguna. Melempar [AuthException] kalau tidak valid.
  static void validateName(String name) {
    if (name.trim().isEmpty) {
      throw const AuthException('Nama harus diisi.');
    }
    if (name.trim().length < 3) {
      throw const AuthException('Nama minimal 3 karakter.');
    }
  }

  /// Masuk dengan akun yang sudah terdaftar.
  static AuthUser login({
    required String identifier,
    required String password,
  }) {
    validateIdentifier(identifier);
    if (password.isEmpty) {
      throw const AuthException('Password harus diisi.');
    }

    final account = _accounts[_key(identifier)];
    if (account == null) {
      throw const AuthException(
        'Akun belum terdaftar. Silakan daftar terlebih dahulu.',
      );
    }
    if (account.password != password) {
      throw const AuthException('Password salah.');
    }

    return AuthUser(name: account.name, identifier: account.identifier);
  }

  /// Mendaftarkan akun baru, lalu langsung mengembalikannya sebagai pengguna
  /// yang masuk.
  static AuthUser register({
    required String name,
    required String identifier,
    required String password,
    required String confirmPassword,
  }) {
    validateName(name);
    validateIdentifier(identifier);
    validatePassword(password);

    if (password != confirmPassword) {
      throw const AuthException('Konfirmasi password tidak sama.');
    }
    if (_accounts.containsKey(_key(identifier))) {
      throw const AuthException(
        'Email atau nomor HP sudah terdaftar. Silakan masuk.',
      );
    }

    final account = _Account(
      name: name.trim(),
      identifier: identifier.trim(),
      password: password,
    );
    _accounts[_key(identifier)] = account;

    return AuthUser(name: account.name, identifier: account.identifier);
  }

  /// Simulasi "Lanjutkan dengan Google".
  ///
  /// Tidak ada SDK Google di proyek ini, jadi akun Google contoh dibuat otomatis
  /// saat pertama kali dipakai lalu langsung dianggap masuk.
  static AuthUser loginWithGoogle() {
    final key = _key(googleIdentifier);

    _accounts.putIfAbsent(
      key,
      () => const _Account(
        name: 'Pengguna Google',
        identifier: googleIdentifier,
        password: '',
      ),
    );

    final account = _accounts[key]!;
    return AuthUser(name: account.name, identifier: account.identifier);
  }

  /// Mengubah nama dan email/nomor HP akun yang sedang masuk.
  ///
  /// Melempar [AuthException] kalau data baru tidak valid atau identifier baru
  /// sudah dipakai akun lain.
  static AuthUser updateProfile({
    required String currentIdentifier,
    required String newName,
    required String newIdentifier,
  }) {
    validateName(newName);
    validateIdentifier(newIdentifier);

    final key = _key(currentIdentifier);
    final account = _accounts[key];
    if (account == null) {
      throw const AuthException('Akun tidak ditemukan. Silakan masuk ulang.');
    }

    final newKey = _key(newIdentifier);
    if (newKey != key && _accounts.containsKey(newKey)) {
      throw const AuthException('Email atau nomor HP sudah terdaftar.');
    }

    final updated = _Account(
      name: newName.trim(),
      identifier: newIdentifier.trim(),
      password: account.password,
    );

    _accounts.remove(key);
    _accounts[newKey] = updated;

    return AuthUser(name: updated.name, identifier: updated.identifier);
  }

  /// Mengganti password akun yang sedang masuk.
  static void changePassword({
    required String currentIdentifier,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final key = _key(currentIdentifier);
    final account = _accounts[key];
    if (account == null) {
      throw const AuthException('Akun tidak ditemukan. Silakan masuk ulang.');
    }
    if (account.password != currentPassword) {
      throw const AuthException('Password lama salah.');
    }

    validatePassword(newPassword);
    if (newPassword != confirmPassword) {
      throw const AuthException('Konfirmasi password tidak sama.');
    }

    _accounts[key] = _Account(
      name: account.name,
      identifier: account.identifier,
      password: newPassword,
    );
  }

  /// Jumlah akun terdaftar. Dipakai untuk pengujian.
  @visibleForTesting
  static int get registeredAccountCount => _accounts.length;

  /// Mengembalikan daftar akun ke kondisi awal (hanya akun demo).
  ///
  /// Dipakai oleh pengujian supaya setiap tes mulai dari keadaan yang sama.
  @visibleForTesting
  static void reset() {
    _accounts
      ..clear()
      ..[demoIdentifier] = const _Account(
        name: 'Demo',
        identifier: demoIdentifier,
        password: demoPassword,
      );
  }
}
