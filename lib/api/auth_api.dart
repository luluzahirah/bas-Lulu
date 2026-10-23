import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class AuthApi {
  Future<Map<String, dynamic>> fetchRandomUser() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));

    if (response.statusCode != 200) {
      throw HttpException('Gagal mengambil user (HTTP ${response.statusCode})');
    }

    final dynamic data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Format respons API tidak valid');
    }

    final dynamic results = data['results'];
    if (results is! List ||
        results.isEmpty ||
        results.first is! Map<String, dynamic>) {
      throw const FormatException('Data user tidak ditemukan dalam respons');
    }

    return results.first as Map<String, dynamic>;
  }
}
