import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request location (fine) permission.
  static Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// Request storage/gallery permission (platform-specific).
  static Future<bool> requestStorage() async {
    // On Android this maps to storage or photos depending on SDK.
    final status = await Permission.photos.request();
    if (status.isGranted) return true;
    final alt = await Permission.storage.request();
    return alt.isGranted;
  }

  /// Request camera permission.
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request notification permission (Android 13+/iOS)
  static Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Request a set of permissions commonly needed for app features.
  static Future<Map<String, bool>> requestAll() async {
    final results = <String, bool>{};
    results['location'] = await requestLocation();
    results['storage'] = await requestStorage();
    results['camera'] = await requestCamera();
    results['notifications'] = await requestNotifications();
    return results;
  }
}
