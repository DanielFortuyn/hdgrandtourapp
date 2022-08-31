import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lustrum/classes/LogMessage.dart';
import 'package:lustrum/helpers/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lustrum/providers/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:lustrum/locator.dart';
import 'dart:async';
import 'package:lustrum/services/Navigation.dart';
import 'package:lustrum/classes/Result.dart';
import 'package:device_info/device_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

import "../helpers/rest.dart";

// import 'package:lustrum/widgets/CustomDialog.dart';
import '../helpers/device.dart';

Future<dynamic> otherHandler(RemoteMessage message) async {
  print('Background message received');
  await dotenv.load(fileName: ".env");
  DeviceInfo deviceInfo = DeviceInfo();
  await deviceInfo.fetchInfo();

  Rest rest = Rest();
  rest.backgroundRefresh(deviceInfo.deviceId);
}

class FcmModel with ChangeNotifier {
  static final FcmModel _singleton = FcmModel._internal();
  factory FcmModel() => _singleton;
  FcmModel._internal() {
    init();
  }

  DeviceInfo _deviceInfo = new DeviceInfo();

  LocationModel _lcm;
  BuildContext context;
  List<String> _handledMessageIds = [];
  Timer countdownTimer;
  Duration myDuration = Duration(seconds: 6);

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

  void subscribeToTopics() async {
    await _deviceInfo.fetchInfo();

    var topic = 'device.' + _deviceInfo.deviceId.toString();
    print(topic);
    _fcm.subscribeToTopic(topic);
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
    final player = AudioPlayer();
    print(
        '=-=-= GOT A MESSAGExsdad -=-=-=......................................................................');
    _navigationService.navigateTo('/');
    print("onMessage: $message");
    debugPrint("On resume fired $message");

    _lcm.addLogMessage(logMessageFromNotification(message));
    _lcm.reloadMap();
    player.play(AssetSource('sounds/ktis.m4a'));

    // doShowDialog(message);
  }

  LogMessage logMessageFromNotification(RemoteMessage message) {
    String title = 'New push message';
    String description = 'received';

    if (message.data != null) {
      print('[n001]' + message.data.toString());
      title = message.data['dialog.title'].toString();
      description = message.data['dialog.content'].toString();
    }

    return new LogMessage(title, description, icon: Icons.assistant);
  }

  Future<dynamic> onResumeHandler(Map<String, dynamic> message) async {
    print("onResume: $message");
    debugPrint("On resume fired $message");

    _lcm.reloadMap();
    // _lcm.addWithCoordsMarker('Jantje', getLatLngFromMsg(message));
    doShowDialog(message);
  }

  Future<dynamic> onLaunchHandler(Map<String, dynamic> message) async {
    debugPrint(
        "[onLaunch] triggered for: " + message['data']['google.message_id']);
    // _lcm.addWithCoordsMarker('Jantje', getLatLngFromMsg(message));
    _lcm.reloadMap();
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
          // return new CustomDialog(data: data);
        });
  }

  void cancelTimer(context) async {
    await countdownTimer.cancel();
    Navigator.pop(context);
  }

  void doShowDialog(message) {
    if (context != null) {
      String strDigits(int n) => n.toString().padLeft(2, '0');

      // showDialog(
      //     context: context,
      //     barrierDismissible: false,
      //     builder: (context) {
      //         String strDigits(int n) => n.toString().padLeft(2, '0');
      //         return StatefulBuilder(
      //           builder: (context, setState) {
      //
      //             String hours;
      //             String minutes;
      //             String seconds = strDigits(myDuration.inSeconds.remainder(60));
      //
      //
      //           return AlertDialog(
      //             title: Text("Under Attack"),
      //             content: Column(
      //               children: [
      //                 Text('Blauw schild'),
      //                 Text(
      //                   '$hours:$minutes:$seconds',
      //                   style: TextStyle(
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.black,
      //                       fontSize: 50),
      //                 ),
      //               ],
      //             ),
      //             actions: <Widget>[
      //               FlatButton(
      //                 onPressed: () => Navigator.pop(context),
      //                 child: Text("Cancel"),
      //               ),
      //               FlatButton(
      //                 onPressed: () {
      //                 },
      //                 child: Text("Change"),
      //               ),
      //             ],
      //           );
      //         },
      //       );
      //     });
    } else {
      print("context is null");
    }
  }
}
