import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../providers/event.dart';
import 'package:provider/provider.dart';

import "../classes/Event.dart";

class EventPage extends StatefulWidget {
  static const String routeName = '/event';
  @override
  State<EventPage> createState() => new EventPageState();
}

class EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Consumer<EventModel>(builder: (context, model, child) {
          return new ListView(children: <Widget>[showEventTable(model)]);
        }));
  }
}

Widget showEventTable(model) {
  return DataTable(columns: [
    DataColumn(label: Text('Event')),
    DataColumn(label: Text('Crea')),
    DataColumn(label: Text('#')),
  ], rows: listEvents(model.events));
}

List<DataRow> listEvents(List<Event> scores) {
  List<DataRow> r = [];
  for (int i = 0; i < scores.length; i++) {
    Event item = scores[i];
    r.add(new DataRow(cells: [
      DataCell(Text(item.event)),
      DataCell(Text(item.createdAt.toString())),
      DataCell(Text("action"),),
    ]));
  }
  return r;
}
