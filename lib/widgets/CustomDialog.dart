import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lustrum/helpers/device.dart';
import 'package:lustrum/classes/Team.dart';
import "package:lustrum/helpers/rest.dart";
import 'package:lustrum/classes/Result.dart';
import 'dart:io';
import 'dart:convert';

// Define a custom Form widget.
class CustomDialog extends StatefulWidget {
  final dynamic data;
  CustomDialog({this.data});

  @override
  CustomDialogState createState() => CustomDialogState(data);
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class CustomDialogState extends State<CustomDialog> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  TextEditingController myController = TextEditingController(text: 'test');
  XFile _image;
  final DeviceInfo device = DeviceInfo();
  final Rest rest = Rest();

  final dynamic data;
  CustomDialogState(this.data);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  void fillAndPop() async {
    String base64 = '';
    if (_image != null) {
      List<int> byteString = await _image.readAsBytes();
      base64 = base64Encode(byteString);
    }

    device.fetchInfo().then((d) {
      print('entetringgg...');
      print(d);

      final Team _team = rest.getTeamByDeviceId(d.androidId);
      Result r = new Result(
          answer: myController.text, image: base64, teamId: _team.id);
      Navigator.of(context).pop(r);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text('Testing image'),
      content: TextField(controller: myController),
      actions: <Widget>[
        MaterialButton(
          elevation: 5.0,
          child: Text('Pick image'),
          onPressed: getImage,
        ),
        MaterialButton(
          elevation: 5.0,
          child: Text('Save'),
          onPressed: fillAndPop,
        )
      ],
    );
  }
}
