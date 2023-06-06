import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> initFilePermission() async {
    log('storage 1  ${await Permission.storage.status}');
    final filePermissionRequest = await Permission.storage.request();
    switch (filePermissionRequest) {
      case PermissionStatus.denied:
        await Permission.storage.request();
        break;
      case PermissionStatus.permanentlyDenied:
        await openAppSettings();
        break;
      default:
    }

    log('storage 2 ${await Permission.storage.status}');
  }

  static Future<void> initLocationPermission() async {
    log('locationAlways 1  ${await Permission.locationAlways.status}');
    final locationPermissionRequest = await Permission.locationAlways.request();
    switch (locationPermissionRequest) {
      case PermissionStatus.denied:
        await Permission.locationAlways.request();
        break;
      case PermissionStatus.permanentlyDenied:
        await openAppSettings();
        break;
      default:
    }

    log('locationAlways 2 ${await Permission.locationAlways.status}');
  }
}
