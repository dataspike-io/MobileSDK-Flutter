import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionStatus? _initialStatus;
  PermissionStatus? get initialStatus => _initialStatus;

  Future<PermissionStatus> requestCameraStatus() async {
    final camera = Permission.camera;
    final status = await camera.status;
    _initialStatus = status;
    return status;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final res = await Permission.camera.request();
    return res.isGranted;
  }
}