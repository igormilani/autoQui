import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<void> requestParkingDetectionPermissions() async {
    await Permission.locationWhenInUse.request();
    await Permission.locationAlways.request();
    await Permission.activityRecognition.request();
    await Permission.notification.request();
  }

  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
  }
}
