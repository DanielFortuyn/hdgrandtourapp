import 'package:flutter/material.dart';
import "../routes.dart";
import '../providers/location.dart';
import 'package:provider/provider.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> elements = getMenuElements(context);
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: elements,
    ));
  }

  List<Widget> getMenuElements(context) {
    final locationModel = Provider.of<LocationModel>(context);
    List<Widget> menuElements = [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
          image: DecorationImage(
              fit: BoxFit.fill, image: AssetImage('assets/bg.png')),
        ),
        child: Text(""),
      ),
      ListTile(
          leading: Icon(Icons.map),
          title: Text('Map'),
          onTap: () {
            Navigator.pushReplacementNamed(context, Routes.map);
          }),
      ListTile(
          leading: Icon(Icons.apps),
          title: Text('Code'),
          onTap: () {
            Navigator.pushReplacementNamed(context, Routes.map);
          }),
      ListTile(
          leading: Icon(Icons.assessment),
          title: Text('Teams'),
          onTap: () {
            Navigator.pushReplacementNamed(context, Routes.stand);
          }),
      ListTile(
          leading: Icon(Icons.settings),
          title: Text('Admin'),
          onTap: () {
            Navigator.pushReplacementNamed(context, Routes.admin);
          }),
                ListTile(
          leading: Icon(Icons.event),
          title: Text('Event'),
          onTap: () => Navigator.pushReplacementNamed(context, Routes.event),
                )
        
    ];
    locationModel.deviceIsOfTeam().then((value) {
      if (!value) {
        menuElements.add(ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Test'),
            onTap: () {
              Navigator.pushReplacementNamed(context, Routes.test);
            }));
        menuElements.add(Divider());
        // menuElements.add();
      }
    });

    return menuElements;
  }
}
