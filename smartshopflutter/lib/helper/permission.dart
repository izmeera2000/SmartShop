import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  final cameraStatus = await Permission.camera.request();
  final galleryStatus = await Permission.photos.request();

  if (!cameraStatus.isGranted || !galleryStatus.isGranted) {
    debugPrint("Permission not granted!");
  }
}
