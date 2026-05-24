import 'package:flutter/services.dart';

class ParkingDetectionService {
  static const _channel = MethodChannel('autoqui/parking_detection');

  Future<bool> start() async {
    final result = await _channel.invokeMethod<bool>('start');
    return result ?? false;
  }

  Future<bool> stop() async {
    final result = await _channel.invokeMethod<bool>('stop');
    return result ?? false;
  }
}
