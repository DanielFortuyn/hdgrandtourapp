import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import "../classes/Score.dart";
import "../classes/TeamScore.dart";
import "../classes/MemberScore.dart";


import "../helpers/dio.dart";

class ScoreModel with ChangeNotifier {
  List<Score> _scores = [];
  List<TeamScore> _teamScores = [];
  List<MemberScore> _memberScores = [];

  List<Score> get scores => _scores;
  List<TeamScore> get teamScores => _teamScores;
  List<MemberScore> get memberScores => _memberScores;


  ScoreModel() {
    fetchScore();
  }

  void fetchScore() async {
      Response response = await dio.get('/score');
      List s = response.data['score'];
      Map t = response.data['teamScore'];
      Map m = response.data['memberScore'];

      for (int i=0; i<s.length; i++) {
          _scores.add(Score.fromJson(s[i]));
      }

      t.forEach((key, value) {
        _teamScores.add(TeamScore.fromJson(value));
      });

      m.forEach((key, value) {
        _memberScores.add(MemberScore.fromJson(value));
      });
          
      // print(jsonDecode(response.data));
      notifyListeners();
  } 
}