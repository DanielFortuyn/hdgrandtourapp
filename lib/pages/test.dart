import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lustrum/widgets/menu.dart';

class TestPage extends StatefulWidget {
  static const String routeName = '/test';
  @override
  State<TestPage> createState() => new TestPageState();
}

class TestPageState extends State<TestPage> {
  TextEditingController answerController = TextEditingController();

  Future<String> createAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Hoe oud is Daniel eigenlijk?'),
            content: Text('asdasd'),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text('Save'),
                onPressed: () {
                  Navigator.of(context).pop(answerController.text.toString());
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(),
      body: Center(
      child: Column(children: <Widget>[
      FlatButton(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Text('clickit'),
        onPressed: () {
          createAlertDialog(context).then((onValue) {
            print(onValue);
          });
        },
      )
    ])
    )
    );
  }
}
