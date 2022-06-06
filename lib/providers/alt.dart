import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';

import "../helpers/dio.dart";
import "../helpers/rest.dart";
import "../classes/Team.dart";

class AltModel with ChangeNotifier {
  static Team currentTeam = Team(id: '1', name: 'Loading..');

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo;

  String _deviceId = "";
  String get deviceId => _deviceId;

  List<Team> _teams = [currentTeam];
  List<Team> get teams => _teams;
  
  Rest _rest;

  AltModel(rest) {
    fetchInfo();
    _rest = rest;
    _teams = rest.teams;
  }

  void updateTeamDevice(newTeamId) async {
    try {
      dio.put('/team/' + newTeamId, data: {"deviceId": _deviceId}).then((f) {
        _rest.fetchTeams();
      });
    } catch(e) {
      print(e);
    }
  }
  
  Future<AndroidDeviceInfo> fetchInfo() async {
    AndroidDeviceInfo dInfo = await deviceInfo.androidInfo;
    _deviceId = dInfo.androidId;
    notifyListeners();
    return dInfo;
  }
}