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

    test('supports userid field as NPM from MockAPI schema', () {
      final UserAccount user = UserAccount.fromJson(<String, dynamic>{
        'userid': 12523030,
        'pass_sha1': '5bd2b3ecbed00f8cd09c073ff02be2d14ed28ecf',
        'nama': 'Sofi Putri Rahayu',
      });

      expect(user.npm, '12523030');
      expect(user.passwordSha1, '5bd2b3ecbed00f8cd09c073ff02be2d14ed28ecf');
      expect(user.name, 'Sofi Putri Rahayu');
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

    test('matchesPassword accepts matching SHA-1 hash or demo fallback', () {
      final AuthApi api = AuthApi();
      final String correctSha1 = api.sha1Hex('secret');
      final UserAccount user = UserAccount.fromJson(<String, dynamic>{
        'npm': '12523030',
        'pass_sha1': correctSha1,
      });

      expect(user.matchesPassword('secret', correctSha1), isTrue);
      expect(user.matchesPassword('123456', api.sha1Hex('123456')), isTrue);
      expect(user.matchesPassword('wrong', api.sha1Hex('wrong')), isFalse);
    });
  });
}
