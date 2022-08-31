import 'package:dio/dio.dart';

import "../helpers/dio.dart";
import "../classes/Team.dart";
import 'package:audioplayers/audioplayers.dart';


class Rest {
  int i = 0;
  final player = AudioPlayer();
  List<Team> _teams;
  List<Team> get teams => _teams;


  static final Rest _singleton = Rest._internal();
  factory Rest() => _singleton;
  Rest._internal() {
    init();
  }

  void init() {
    fetchTeams().then((r) {
      _teams = r;
    });
  }
  void errorMusic() {
    i++;
    if(i % 3 == 0) {
      if(i % 9 == 0) {
        if(i % 27 == 0) {
          player.play(AssetSource('sounds/aishort.m4a'));
        } else {
          player.play(AssetSource('sounds/ngshort.m4a'));
        }
      } else {
        player.play(AssetSource('sounds/godver.m4a'));
      }
    } else {
      player.play(AssetSource('sounds/wddgn.m4a'));
    }
  }

  Future<Team> updatePhase(String deviceId, String entryId) async {
    print("[p104] bumping phase");
    try {
      await dio.post(
          '/bumpphase', data: {'deviceId': deviceId, 'entryId': entryId});
    } on DioError catch(e) {
      print('[update phase error]');
    }
  }

  Future<Team> processCode(String deviceId, String code) async {
    print("[p104] process code phase");
    try {
      var result = await dio.post('/code', data: {'deviceId': deviceId, 'code': code});
      if(result.statusCode == 204 || result.statusCode == 200) {
        player.play(AssetSource('sounds/kei.m4a'));
      }
      if(result.statusCode == 202) {
        player.play(AssetSource('sounds/wwww.m4a'));
      }
    } on DioError catch (e) {
      errorMusic();
    }
    return null;
  }
  Future<Team> processManualSubmit(String deviceId) async {
    print("[p104] process code phase");
    try {
      var result = await dio.post('/manual', data: {'deviceId': deviceId });
      if(result.statusCode == 204 || result.statusCode == 200) {
        print("[a] playing keigoed");
        player.play(AssetSource('sounds/kei.m4a'));
      }
    } on DioError catch (e) {
      errorMusic();
    }
    return null;
  }

  Future<List<Team>> fetchTeams() async {
    Response response = await dio.get('/teams');
    Iterable l = response.data;
    _teams = l.map((model) => Team.fromJson(model)).toList();
    return _teams;
  }

  Future<Team> getTeamByDeviceId(String deviceId) async {
    _teams = await this.fetchTeams();
    for (var i = 0; i < _teams.length; i++) {
      if (_teams[i].deviceId == deviceId) {
        return _teams[i];
      }
    }
    return null;
  }
}
