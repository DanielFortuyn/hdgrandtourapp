import 'package:lustrum/helpers/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:lustrum/providers/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:lustrum/locator.dart';
import 'package:lustrum/services/Navigation.dart';
import 'package:lustrum/classes/Result.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:lustrum/widgets/CustomDialog.dart';


Future<dynamic> otherHandler(RemoteMessage message) async {
  print('Background message received');
}

class FcmModel with ChangeNotifier {
  static final FcmModel _singleton = FcmModel._internal();
  factory FcmModel() => _singleton;

  FcmModel._internal() {
    init();
  }

  LocationModel _lcm;
  BuildContext context;
  List<String> _handledMessageIds = [];

  FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final NavigationService _navigationService = locator<NavigationService>();

  void init() {
    subscribeToTopics();
    registerHandlers();
    debugPrint('====> FCM ---> inited onLaunch');
  }

  void setContext(BuildContext extContext) {
    context = extContext;
    _lcm = Provider.of<LocationModel>(context);
  }

  void setLocationModel(LocationModel locationModel) {
    _lcm = locationModel;
  }

  void subscribeToTopics() {
    _fcm.subscribeToTopic('updates');
  }

  void registerHandlers() {
    print('Registering handlerss... MESSAGExsdad');
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageHandler);
    FirebaseMessaging.onMessage.listen(onMessageHandler);
    FirebaseMessaging.onBackgroundMessage(otherHandler);
    // _fcm.configure(
    //   onMessage: onMessageHandler,
    //   onLaunch: onLaunchHandler,
    //   onResume: onResumeHandler,
    // );
  }


  Future<dynamic> onMessageHandler(RemoteMessage message) async {
    print('=-=-= GOT A MESSAGExsdad -=-=-=......................................................................');
    _navigationService.navigateTo('/map');
    print("onMessage: $message");
    debugPrint("On resume fired $message");
    _lcm.addWithCoordsMarker('Jantje', getLatLngFromMsg(message));
    doShowDialog(message);
  }

  Future<dynamic> onResumeHandler(Map<String, dynamic> message) async {
    print("onResume: $message");
    debugPrint("On resume fired $message");
    _lcm.addWithCoordsMarker('Jantje', getLatLngFromMsg(message));
    doShowDialog(message);
  }

  Future<dynamic> onLaunchHandler(Map<String, dynamic> message) async {
    debugPrint(
        "[onLaunch] triggered for: " + message['data']['google.message_id']);
    _lcm.addWithCoordsMarker('Jantje', getLatLngFromMsg(message));
    doShowDialog(message);
  }

  LatLng getLatLngFromMsg(message) {
    debugPrint(message.data.toString());
    if (message.data != null) {
      print('Data not null');
      double lat = double.tryParse(message.data['lat']) ?? 0;
      double lng = double.tryParse(message.data['lng']) ?? 0;
      return LatLng(lat, lng);
    }
    return LatLng(0, 0);
  }

  void doShowCustomDialog(message) {
    createAlertDialog(context, message['data']).then((Result onValue) {
      dynamic postData = {
        "teamId": onValue.teamId,
        "answer": onValue.answer.toString(),
        "image": onValue.image
      };
      dio.post('/answer', data: postData);
    });
  }

  Future<Result> createAlertDialog(BuildContext context, data) {
    return showDialog(
        context: context,
        builder: (context) {
          return new CustomDialog(data: data);
        });
  }

  void doShowDialog(message) {
    if (context != null) {
      if (message['notification']['title'] == 'image') {
        doShowCustomDialog(message);
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text('Launch'),
              subtitle: Text('Launch'),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.blue,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                color: Colors.red,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } else {
      print("context is null");
    }
  }
}
