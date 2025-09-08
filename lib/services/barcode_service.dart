import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';

class BarcodeService {
  Future<String> scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan();
      return result.rawContent;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        throw 'The user did not grant the camera permission!';
      } else {
        throw 'Unknown error: $e';
      }
    } on FormatException {
      throw 'null (User returned using the "back"-button before scanning anything. Result)';
    } catch (e) {
      throw 'Unknown error: $e';
    }
  }
}
