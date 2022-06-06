import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:lustrum/classes/TeamScore.dart';
import 'package:lustrum/classes/MemberScore.dart';


import '../providers/score.dart';
import 'package:provider/provider.dart';

import "../classes/Score.dart";

class StandPage extends StatefulWidget {
  static const String routeName = '/stand';
  @override
  State<StandPage> createState() => new StandPageState();
}

class StandPageState extends State<StandPage> {


  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Consumer<ScoreModel>(builder:(context,model,child) { return new ListView(children: <Widget>[
              new SizedBox(width: 300, height: 300, child: SimpleBarChart.fromTeamScore(model.teamScores)),
              new SizedBox(width: 300, height: 300, child: SimpleBarChart.fromMemberScore(model.memberScores)),
              showScoreTable(model)
            ]);
          })
        );
  }
}

Widget showScoreTable(model) {
  return DataTable(
    columns: [
      DataColumn(label:Text('Name') ),
      DataColumn(label:Text('Desc') ),
      DataColumn(label:Text('#') ),
    ],
    rows: listScores(model.scores)
  );
}

List<DataRow> listScores(scores) {
  List<DataRow> r = [];
  for(int i=0; i<scores.length; i++) {
    Score item = scores[i];
    r.add(new DataRow(cells: [
      DataCell(Text(item.nick)),
      DataCell(Text(item.description)),
      DataCell(Text(item.score.toString())),
    ]));
  }
  return r;
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SimpleBarChart.withSampleData() {
    return new SimpleBarChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  factory SimpleBarChart.fromTeamScore(ts) {
    return new SimpleBarChart(
      _createTeamScoreData(ts),
      animate:true,
    );
  }

    factory SimpleBarChart.fromMemberScore(ts) {
    return new SimpleBarChart(
      _createMemberScoreData(ts),
      animate:true,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
    );
  }

  static List<charts.Series<MemberScore, String>> _createMemberScoreData(ts) {
    return [
      new charts.Series<MemberScore, String>(
        id: 'MemberScore',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (MemberScore sales, _) => sales.name,
        measureFn: (MemberScore sales, _) => sales.score,
        data: ts,
      )
    ];
  }

    static List<charts.Series<TeamScore, String>> _createTeamScoreData(ts) {
    return [
      new charts.Series<TeamScore, String>(
        id: 'TeamScore',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TeamScore sales, _) => sales.name,
        measureFn: (TeamScore sales, _) => sales.score,
        data: ts,
      )
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TeamScore, String>> _createSampleData() {
    final data = [
      new TeamScore(name: '2014', score: 1),
      new TeamScore(name: '2015', score: 1),
    ];

    return [
      new charts.Series<TeamScore, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TeamScore sales, _) => sales.name,
        measureFn: (TeamScore sales, _) => sales.score,
        data: data,
      )
    ];
  }
}