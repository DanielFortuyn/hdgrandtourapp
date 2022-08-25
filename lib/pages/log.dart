import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lustrum/classes/LogMessage.dart';
import 'package:lustrum/classes/Team.dart';
import 'package:lustrum/routes.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import "../widgets/menu.dart";
import '../providers/alt.dart';
import '../providers/location.dart';
import "../classes/Team.dart";

class LogPage extends StatefulWidget {
  static const String routeName = '/log';
  @override
  State<LogPage> createState() => new LogPageState();
}

class LogPageState extends State<LogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Menu(),
        body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Consumer<LocationModel>(builder: (context, model, child) {
              return SingleChildScrollView(
                  child: Column(children: messageStream(model.logMessages)));
            })));
  }
}

List<Widget> messageStream(List<LogMessage> logMessages) {
  List<Widget> list = [];
  for (var i = 0; i < logMessages.length; i++) {
    list.add(logCard(logMessages[i]));
  }
  return list;
}

List<Widget> getCardContents(_logMessage) {
  List<Widget> list = [
    ListTile(
      leading: Icon(_logMessage.icon),
      title: Text(_logMessage.title),
      subtitle: Text(
        _logMessage.subTitle,
        style: TextStyle(color: Colors.black.withOpacity(0.6)),
      ),
    )
  ];

  if (_logMessage.description != null) {
    list.add(Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 2),
      child: Text(
        _logMessage.description,
        textAlign: TextAlign.left,
        style: TextStyle(color: Colors.black.withOpacity(0.6)),
      ),
    ));
  }
  return list;
}

Widget logCard(LogMessage logMessage) {
  Color shadowColor = new Color(0x999999FF);
  if(logMessage.level != 0) {
    shadowColor = new Color(0xFFCCCCCC);
  }
  return Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: getCardContents(logMessage),
    ),
    color: shadowColor,
    shadowColor: shadowColor
  );
}

/// UI Widget for displaying metadata.
class MetaCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  // ignore: public_member_api_docs
  MetaCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Text(_title, style: const TextStyle(fontSize: 18)),
              ),
              _children,
            ],
          ),
        ),
      ),
    );
  }
}
