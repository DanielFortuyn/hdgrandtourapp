
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import "../helpers/dio.dart";
// Define a custom Form widget.
class PushForm extends StatefulWidget {
  const PushForm();

  @override
  State<PushForm> createState() => _PushFormState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _PushFormState extends State<PushForm> {
  // Create a text controller. Later, use it to retrieve the
  // current value of the TextField.
  final phaseController = TextEditingController();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();


  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    phaseController.dispose();
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  void send(String team)  async {
    var reqData = {
      'pw': '5M83ftUfsEDmvuOEaI5Q7Bxx25c3P65jId7pBv',
      'phaseId': phaseController.text,
      'notificationTitle': titleController.text,
      'notificationDescription': bodyController.text
    };

    if(team == 'snorro') {
      reqData['teamId']  = '582b848f-ab62-40aa-8255-1cfff80519d0';
    }
    if(team == 'hibbem') {
      reqData['teamId']  = 'd98f4c69-f79e-4c84-92c6-4c8cb47d69db';
    }
    if(team == 'remspoor') {
      reqData['teamId']  = 'e76ad8a4-f3f0-4e14-ba27-fbd18a54e284';
    }

    try {
      await dio.post('/notify', data: reqData );
    } on DioError catch(e) {
      print('[update phase error]');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fill this out in the next step.
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text('PUSH NOTIFICATIE VERSTUREN',
              style: TextStyle(
                  fontSize: 20
              ) ),
          TextField(
            controller: phaseController,
            decoration: InputDecoration(
                hintText: 'PhaseID'
            ),
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
                hintText: 'NotificatieTitel'
            ),
          ),
          TextField(
            controller: bodyController,
            decoration: InputDecoration(
                hintText: 'NotificatieBody'
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                  child: new Text('Snorro'),
                  onPressed: () =>
                  {
                    send('snorro')
                  }

              ),
              SizedBox(
                width: 5,
              ),
              ElevatedButton(
                  child: new Text('Hibbem'),
                  onPressed: () =>
                  {
                    send('hibbem')
                  }
              ),
              SizedBox(
                width: 5,
              ),
              ElevatedButton(
                  child: new Text('Remspoor'),
                  onPressed: () =>
                  {
                    send('remspoor')
                  }
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  child: new Text('All'),
                  onPressed: () =>
                  {
                    send('all')
                  }
              )
            ],
          )

        ],
      )
    );
  }
}