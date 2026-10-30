import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/attendance_model.dart';
import '../services/qr_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key, this.qrService});

  final QrService? qrService;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final MobileScannerController _controller;
  late final QrService _qrService;

  AttendanceModel? _attendance;
  String _status = 'Belum Scan';
  String? _scannedCode;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _qrService = widget.qrService ?? QrService();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _attendance != null) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    for (final Barcode barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        final String code = rawValue.trim();
        final bool isValid = _qrService.validateQr(code);
        final String statusText = isValid ? 'HADIR' : 'QR TIDAK VALID';

        setState(() {
          _isProcessing = true;
          _scannedCode = code;
          _status = statusText;
          _attendance = AttendanceModel(code: code, status: statusText);
        });

        // Pause/stop scanner detection after successful scan
        _controller.stop();
        break;
      }
    }
  }

  void _resetScan() {
    setState(() {
      _isProcessing = false;
      _scannedCode = null;
      _status = 'Belum Scan';
      _attendance = null;
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHadir = _status == 'HADIR';
    final bool isInvalid = _status == 'QR TIDAK VALID';
    final bool isBelumScan = _status == 'Belum Scan';

    Color statusColor;
    if (isHadir) {
      statusColor = const Color(0xFF16A34A); // Hijau
    } else if (isInvalid) {
      statusColor = const Color(0xFFDC2626); // Merah
    } else {
      statusColor = const Color(0xFF64748B); // Abu-abu
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Scan QR Attendance'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            tooltip: 'Flashlight',
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            tooltip: 'Ganti Kamera',
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Viewport Kamera Scanner
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (BuildContext context, MobileScannerException error) {
                    final String msg =
                        error.errorCode ==
                            MobileScannerErrorCode.permissionDenied
                        ? 'Izin kamera diperlukan untuk melakukan absensi. Mohon izinkan akses kamera di pengaturan perangkat.'
                        : 'Gagal mengakses kamera: ${error.errorDetails?.message ?? error.errorCode.name}';
                    return Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.no_photography_outlined,
                              size: 48,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Akses Kamera Ditolak / Tidak Tersedia',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              msg,
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Overlay batas pemindaian QR
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isHadir
                            ? const Color(0xFF22C55E)
                            : isInvalid
                            ? const Color(0xFFEF4444)
                            : Colors.white.withValues(alpha: 0.8),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Hint text overlay
                Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isBelumScan
                          ? 'Arahkan QR Code ke dalam kotak scanner'
                          : 'Pemindaian selesai',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Panel Hasil Scan & Status
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'STATUS PRESENSI',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tampilan status yang jelas dan besar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            isHadir
                                ? Icons.check_circle_rounded
                                : isInvalid
                                ? Icons.cancel_rounded
                                : Icons.hourglass_empty_rounded,
                            color: statusColor,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _status,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_scannedCode != null) ...<Widget>[
                      Text(
                        'Kode QR: $_scannedCode',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (_attendance != null && isHadir)
                      const Text(
                        'Kehadiran perkuliahan berhasil dicatat.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF15803D),
                        ),
                      )
                    else if (_attendance != null && isInvalid)
                      const Text(
                        'QR Code tidak cocok dengan jadwal absensi yang berlaku.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    const SizedBox(height: 18),
                    // Tombol scan ulang
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          'Scan Ulang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: _resetScan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
