import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestAllPermissions() async {
    try {
      print('🔐 Requesting permissions...');
      
      // Demander TOUTES les permissions en même temps
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
        Permission.storage,
        Permission.photos,
      ].request();

      print('📋 Permission Status:');
      statuses.forEach((permission, status) {
        print('   $permission: $status');
      });

      // Vérifier si les permissions critiques sont accordées
      final cameraOk = statuses[Permission.camera]?.isGranted ?? false;
      final micOk = statuses[Permission.microphone]?.isGranted ?? false;

      if (!cameraOk || !micOk) {
        print('❌ Critical permissions denied!');
        print('   Camera: $cameraOk, Mic: $micOk');
        return false;
      }

      print('✅ All permissions granted!');
      return true;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  static Future<bool> checkPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;

      print('📋 Current permissions:');
      print('   Camera: $cameraStatus');
      print('   Mic: $micStatus');

      return cameraStatus.isGranted && micStatus.isGranted;
    } catch (e) {
      print('❌ Error checking permissions: $e');
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
