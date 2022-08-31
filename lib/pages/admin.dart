import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lustrum/classes/Team.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import "../widgets/menu.dart";
import '../providers/alt.dart';
import '../providers/location.dart';
import "../classes/Team.dart";
import "../widgets/PushForm.dart";

class AdminPage extends StatefulWidget {
  static const String routeName = '/admin';
  @override
  State<AdminPage> createState() => new AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  String answer = '';
  final snackBar = SnackBar(
    content: Text('Yay! A SnackBar!'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Menu(),
        body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Consumer<LocationModel>(
                builder: (context, model, child) { return new Column(
              children: <Widget>[
                Title(
                    title: "Admin",
                    child: Text('Admin'),
                    color: Color.fromRGBO(0, 0, 0, 1)),
                Center(child: TeamDropdown()),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child:  PushForm()
                  )
                ]
            );
         })
      )
    );
  }
}

class TeamDropdown extends StatefulWidget {
  @override
  State<TeamDropdown> createState() => new TeamDropdownState();
}

class TeamDropdownState extends State<TeamDropdown> {
  String currentTeamId = 'admin';



  void _getCurrentTeam(AltModel model) {
    if(model.teams != null) {
      model.teams.forEach((f) {
        if (model.deviceId == f.deviceId) {
          currentTeamId = f.id;
        }
      });
    }
  }

  List<DropdownMenuItem> _getItems(teams) {
    List<DropdownMenuItem> _dditems = [];
    if (teams != null) {
      _dditems = teams.map<DropdownMenuItem<String>>((Team value) {
        return DropdownMenuItem<String>(
          value: value.id,
          child: Text(value.name),
        );
      }).toList();
      _dditems
          .add(DropdownMenuItem<String>(child: Text('Admin'), value: 'admin'));
    }
    return _dditems;
  }

  Widget build(BuildContext context) {
    return Consumer<AltModel>(builder: (context, model, child) {
      _getCurrentTeam(model);
      return DropdownButton(
        items: _getItems(model.teams),
        value: currentTeamId,
        icon: Icon(Icons.arrow_downward),
        onChanged: (v) {
          currentTeamId = v;
          model.updateTeamDevice(v);
        },
      );
    });
  }
}

class MyButtonBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      children: <Widget>[
        const ElevatedButton(
          onPressed: null,
          child: Text('Disabled Button', style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            // ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: const Text('Enabled Button', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
