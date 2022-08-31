import 'package:device_info/device_info.dart';

class DeviceInfo {

  static final DeviceInfo _singleton = DeviceInfo._internal();

  factory DeviceInfo() {
    return _singleton;
  }

  DeviceInfo._internal();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo;

  String deviceId;
  String instanceId;

  Future<AndroidDeviceInfo> fetchInfo() async {
    if(androidInfo == null) {
      androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.androidId;
    }
    return androidInfo;
  }
}