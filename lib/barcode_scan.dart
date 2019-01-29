import 'dart:async';

import 'package:flutter/services.dart';

class BarcodeScanner {
  static const CameraAccessDenied = 'PERMISSION_NOT_GRANTED';
  static const MethodChannel _channel =
      const MethodChannel('com.apptreesoftware.barcode_scan');
  static Future<String> scan(String theme) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'theme': theme,
    };
    return await _channel.invokeMethod('scan', params);
  }
}
