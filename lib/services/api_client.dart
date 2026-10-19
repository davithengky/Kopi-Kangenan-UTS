import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';

/// Kesalahan dari REST API yang sudah siap ditampilkan ke pengguna.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  /// Pesan berbahasa Indonesia dari server.
  final String message;

  /// Kode status HTTP, kalau permintaan sempat sampai ke server.
  final int? statusCode;

  @override
  String toString() => message;
}

/// Klien HTTP tipis untuk REST API Kopi Kangenan.
///
/// Selalu mengembalikan `Map<String, dynamic>` berisi `data` dan/atau
/// `message`, dan melempar [ApiException] untuk semua kegagalan supaya lapisan
/// layar cukup menangkap satu jenis kesalahan.
class ApiClient {
  const ApiClient._();

  static final http.Client _client = http.Client();

  static const Duration _timeout = Duration(seconds: 15);

  /// GET `path` (mis. `/products`).
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _send(() => _client.get(_uri(path, query), headers: _headers));
  }

  /// POST `path` dengan badan JSON.
  static Future<Map<String, dynamic>> post(String path, {Object? body}) {
    return _send(
      () => _client.post(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
    );
  }

  /// PUT `path` dengan badan JSON.
  static Future<Map<String, dynamic>> put(String path, {Object? body}) {
    return _send(
      () => _client.put(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
    );
  }

  /// DELETE `path`.
  static Future<Map<String, dynamic>> delete(String path) {
    return _send(() => _client.delete(_uri(path), headers: _headers));
  }

  // --- Bagian dalam ------------------------------------------------------

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (ApiConfig.hasToken) 'Authorization': 'Bearer ${ApiConfig.token}',
  };

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    if (query == null || query.isEmpty) return uri;

    return uri.replace(
      queryParameters: query.map((key, value) => MapEntry(key, '$value')),
    );
  }

  static Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    late final http.Response response;

    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons. Coba lagi.');
    } catch (_) {
      throw const ApiException(
        'Tidak bisa menghubungi server. Pastikan API Kopi Kangenan menyala.',
      );
    }

    final decoded = _decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw ApiException(
      _pesanKesalahan(decoded),
      statusCode: response.statusCode,
    );
  }

  static Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return const <String, dynamic>{};

    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  /// Mengambil pesan dari `message` atau kesalahan validasi pertama.
  static String _pesanKesalahan(Map<String, dynamic> decoded) {
    final message = decoded['message'];
    if (message is String && message.isNotEmpty) return message;

    final errors = decoded['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return '${first.first}';
      return '$first';
    }

    return 'Terjadi kesalahan pada server.';
  }
}

/// Membaca bagian `data` dari respons; `null` kalau tidak ada.
Map<String, dynamic>? dataOf(Map<String, dynamic> response) {
  final data = response['data'];
  return data is Map<String, dynamic> ? data : null;
}

/// Membaca bagian `data` sebagai daftar.
List<Map<String, dynamic>> listOf(Map<String, dynamic> response) {
  final data = response['data'];
  if (data is! List) return const <Map<String, dynamic>>[];

  return data.whereType<Map<String, dynamic>>().toList();
}
