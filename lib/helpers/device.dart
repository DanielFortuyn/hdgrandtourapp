import 'package:device_info/device_info.dart';

class DeviceInfo {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo;

  String deviceId;

  DeviceInfo() {
    fetchInfo().then((value) => deviceId = value.androidId);
  }

  Future<AndroidDeviceInfo> fetchInfo() async {
    AndroidDeviceInfo dInfo = await deviceInfo.androidInfo;
    deviceId = dInfo.androidId;
    print("[DEVICEID]" + deviceId);
    return dInfo;
  }
}