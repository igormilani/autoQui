package com.example.auto_qui

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "autoqui/parking_detection"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    ParkingDetectionService.start(this)
                    result.success(true)
                }
                "stop" -> {
                    ParkingDetectionService.stop(this)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
