import 'package:flutter_test/flutter_test.dart';

import 'package:bas/models/attendance_model.dart';
import 'package:bas/services/qr_service.dart';

void main() {
  group('QrService Tests', () {
    final QrService qrService = QrService();

    test(
      'Skenario 1: validasi kode valid ABSEN-TRM-2026 menghasilkan true',
      () {
        expect(qrService.validateQr('ABSEN-TRM-2026'), isTrue);
      },
    );

    test(
      'Skenario 2: validasi kode selain ABSEN-TRM-2026 menghasilkan false',
      () {
        expect(qrService.validateQr('ABSEN-TRM-2025'), isFalse);
        expect(qrService.validateQr('RANDOM-CODE'), isFalse);
        expect(qrService.validateQr(''), isFalse);
        expect(qrService.validateQr('absen-trm-2026'), isFalse);
      },
    );
  });

  group('AttendanceModel Tests', () {
    test(
      'Constructor menginisialisasi properti code dan status dengan benar',
      () {
        const AttendanceModel model = AttendanceModel(
          code: 'ABSEN-TRM-2026',
          status: 'HADIR',
        );

        expect(model.code, 'ABSEN-TRM-2026');
        expect(model.status, 'HADIR');
      },
    );

    test('Constructor untuk status tidak valid', () {
      const AttendanceModel model = AttendanceModel(
        code: 'INVALID-CODE',
        status: 'QR TIDAK VALID',
      );

      expect(model.code, 'INVALID-CODE');
      expect(model.status, 'QR TIDAK VALID');
    });
  });
}
