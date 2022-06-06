import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';

import "../helpers/dio.dart";
import "../classes/Team.dart";

class TenStateProvider {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo;

  List<Team> _teams = [];
  List<Team> get teams => _teams;
  

  Future<List<Team>> fetchTeams() async {
      Response response = await dio.get('/teams');
      Iterable l = response.data;
      return l.map((model) => Team.fromJson(model)).toList();
  } 


  Future<AndroidDeviceInfo> fetchInfo() async {
    AndroidDeviceInfo dInfo = await deviceInfo.androidInfo;
    return dInfo;
  }
}