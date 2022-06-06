import 'package:dio/dio.dart';

import "../helpers/dio.dart";
import "../classes/Team.dart";

class Rest {
    List<Team> _teams;
    List<Team> get teams => _teams;

    Rest() {
      fetchTeams().then((r) {
        _teams = r;
      });
    }
    
    Future<List<Team>> fetchTeams() async {
      print('Getting teams..');
      if(_teams == null) {
        Response response = await dio.get('/teams');
        Iterable l = response.data;
        _teams = l.map((model) => Team.fromJson(model)).toList();
      }
      return _teams;
  } 

  Team getTeamByDeviceId(String deviceId) {
    print("=====>DeviceId: " + deviceId);
    return _teams.map((Team team) {
      if(team.deviceId == deviceId) {
        return team;
      }
      return null;
    }).first;
  }
}