import 'package:flutter_test/flutter_test.dart';

import 'package:bas/api/auth_api.dart';

void main() {
  group('UserAccount.fromJson', () {
    test('reads NPM and SHA-1 from the documented field names', () {
      final UserAccount user = UserAccount.fromJson(<String, dynamic>{
        'NPM': '12523030',
        'Password': 'sha1-hash',
      });

      expect(user.npm, '12523030');
      expect(user.passwordSha1, 'sha1-hash');
    });

    test('supports lowercase NPM and pass_sha1 fields', () {
      final UserAccount user = UserAccount.fromJson(<String, dynamic>{
        'npm': '12523030',
        'pass_sha1': 'sha1-hash',
      });

      expect(user.npm, '12523030');
      expect(user.passwordSha1, 'sha1-hash');
    });

    test('does not treat login_name as an NPM', () {
      final UserAccount user = UserAccount.fromJson(<String, dynamic>{
        'login_name': 'demo-user',
        'nama': 'Mahasiswa Demo',
        'pass_sha1': 'sha1-hash',
      });

      expect(user.npm, isEmpty);
      expect(user.passwordSha1, 'sha1-hash');
      expect(user.name, 'Mahasiswa Demo');
    });
  });
}
