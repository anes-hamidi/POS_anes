import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrService {
  Widget generateQrCode(String data) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: 100.0,
    );
  }
}
