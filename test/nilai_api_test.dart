import 'package:flutter_test/flutter_test.dart';

import 'package:bas/api/nilai_api.dart';

void main() {
  group('NilaiApi.parseResponse', () {
    test('parses the MockAPI value envelope', () {
      final List<NilaiItem> items = NilaiApi.parseResponse(
        '{"value":[{"id":162801,"kd_matkul":"GC327","npm":"12523030",'
        '"uas":"70","uts":"75","quis":"72","tugas":"80","hadir":"100",'
        '"na":"79.3","hm":"B+","am":"3.5","mutu":"10.5","nip":"LU0512",'
        '"thn_akademik":"2023/2024","semester":"1"}],"Count":1}',
      );

      expect(items, hasLength(1));
      expect(items.single.kdMatkul, 'GC327');
      expect(items.single.npm, '12523030');
      expect(items.single.na, 79.3);
      expect(items.single.hm, 'B+');
      expect(items.single.semester, 1);
    });

    test('continues to accept a plain array response', () {
      final List<NilaiItem> items = NilaiApi.parseResponse(
        '[{"kd_matkul":"GC302","npm":"12523030","na":73.284}]',
      );

      expect(items, hasLength(1));
      expect(items.single.kdMatkul, 'GC302');
      expect(items.single.na, 73.284);
    });

    test('rejects an invalid response shape', () {
      expect(
        () => NilaiApi.parseResponse('{"Count":0}'),
        throwsFormatException,
      );
    });

    test('rejects malformed JSON', () {
      expect(() => NilaiApi.parseResponse('{invalid'), throwsFormatException);
    });
  });
}
