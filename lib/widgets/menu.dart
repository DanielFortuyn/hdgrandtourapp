import 'package:flutter/material.dart';
import "../routes.dart";
import '../providers/location.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';

class Menu extends StatelessWidget {
  @override

  Widget getNotificationCountBadge(int length) {

    if(length == 0) {
      return SizedBox.shrink();
    } else {
      return new Badge(
        shape: BadgeShape.square,
        borderRadius: BorderRadius.circular(8),
        badgeContent: Text(length.toString(), style: TextStyle(color: Colors.white)),
      );
    }
  }
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
            locationModel.handlePlacePhase();
          }),
      ListTile(
          leading: Icon(Icons.apps),
          title: Text('Code'),
          onTap: () {
            Navigator.pushReplacementNamed(context, Routes.code);
          }),
      ListTile(
          leading: Icon(Icons.rss_feed),
          title: Text('Log'),
          trailing: getNotificationCountBadge(locationModel.newMessages),
          onTap: () {
            locationModel.setNewMessages();
            Navigator.pushReplacementNamed(context, Routes.log);
          }),
      // ListTile(
      //     leading: Icon(Icons.assessment),
      //     title: Text('Teams'),
      //     onTap: () {
      //       Navigator.pushReplacementNamed(context, Routes.stand);
      //     }),
      // ListTile(
      //   leading: Icon(Icons.event),
      //   title: Text('Event'),
      //   onTap: () => Navigator.pushReplacementNamed(context, Routes.event),
      // )
    ];

    if (locationModel.deviceId == locationModel.adminDeviceId) {
      menuElements.add(ListTile(
          leading: Icon(Icons.settings),
          title: Text('Admin'),
          onTap: () {
            Navigator.pushReplacementNamed(context, Routes.admin);
          }));
    }

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
