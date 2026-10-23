import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _endpoint =
      Uri.parse('https://6adab9277512f497b30020ef.mockapi.io/user');

  final http.Client _client;

  /// Checks submitted NPM and SHA-1 password against the demo API.
  /// Each API record is expected to have "NPM" and "Password" fields.
  Future<bool> authenticate({
    required String npm,
    required String passwordSha1,
  }) async {
    final response = await _client
        .get(_endpoint)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw HttpException(
        'Gagal mengambil data login (HTTP ${response.statusCode})',
      );
    }

    final dynamic data = jsonDecode(response.body);
    if (data is! List) {
      throw const FormatException(
        'Respons API login harus berupa daftar user.',
      );
    }

    for (final dynamic item in data) {
      if (item is! Map<String, dynamic>) continue;
      final dynamic apiNpm = item['NPM'];
      final dynamic apiPassword = item['Password'];
      if (apiNpm is String &&
          apiPassword is String &&
          apiNpm.trim() == npm.trim() &&
          apiPassword.trim().toLowerCase() == passwordSha1.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  void close() => _client.close();
}
