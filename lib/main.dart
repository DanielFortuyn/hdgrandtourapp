import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

import './pages/admin.dart';
import './pages/map.dart';
import './pages/stand.dart';
import './pages/test.dart';
import './pages/event.dart';
import './pages/code.dart';
import './pages/log.dart';

import './providers/alt.dart';
import './providers/location.dart';
import './providers/score.dart';
import './providers/fcm.dart';
import './providers/snack.dart';

import './helpers/device.dart';
import './helpers/socket.dart';
import "./helpers/rest.dart";

import "./services/Navigation.dart";
import "./locator.dart";

import 'package:flutter_geofence/geofence.dart';

void main() async {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await _checkPermission();
  Wakelock.enable();
  startKioskMode();
  Geofence.initialize();
  Geofence.requestPermissions();
  // Pass all uncaught errors from the framework to Crashlytics.
  runApp(LustrumApp());
}

Future<void> _checkPermission() async {
  final serviceStatus = await Permission.locationAlways.serviceStatus;
  final isGpsOn = serviceStatus == ServiceStatus.enabled;
  if (!isGpsOn) {
    print('Turn on location services before requesting permission.');
    return;
  }
  final status = await Permission.locationAlways.request();
  if (status == PermissionStatus.granted) {
    print('Permission granted');
  } else if (status == PermissionStatus.denied) {
    print('Permission denied. Show a dialog and again ask for the permission');
    await Permission.location.request();
    await Permission.locationAlways.request();
    print('Permission requested');
  } else if (status == PermissionStatus.permanentlyDenied) {
    print('Take the user to the settings page.');
    await openAppSettings();
  }
}

class LustrumApp extends StatefulWidget {
  @override
  _LustrumAppState createState() => _LustrumAppState();
}

class _LustrumAppState extends State<LustrumApp> with WidgetsBindingObserver {
  int _counter = 0;
  final DeviceInfo device = DeviceInfo();
  final GlobalKey<MapPageState> _mapPageState = GlobalKey<MapPageState>();
  Rest rest;
  LocationModel _locationModel;
  MapPage page;

  @override
  void initState() {
    print("c00 init state was run");
    createInstance();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    rest.fetchTeams();
  }

  void createInstance() {
    print("c001 createinstance was run");
    page = MapPage(
      key: _mapPageState,
    );
    rest = Rest();
    // SocketHelper socket = SocketHelper();
    _locationModel = LocationModel(device, rest);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print("===================AppLifecycleState Current state = $state");

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.resumed:
        break;
    }
  }

  Widget build (BuildContext context) {
    rest.fetchTeams();
    // void _listenToNfcTags(_mapPageState) {
    //   print('Starting to listen NEW PLACE!!');
    //   NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    //     print('FOUND TAG ============ XDASPDSD');
    //     Ndef ndef = Ndef.from(tag);
    //     if (ndef == null) {
    //        print('Tag is not compatible with NDEF');
    //        return;
    //     }
    //     final message = ndef.cachedMessage;
    //     final payload = message?.records[0].payload ?? const Iterable<int>.empty();
    //     final payloadStr = String.fromCharCodes(payload);
    //     NdefFormatable _ndef = NdefFormatable.from(tag);
    //     _mapPageState.currentState.callThisOnChild(payloadStr);
    //   });
    // }

    // _listenToNfcTags(_mapPageState);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AltModel(rest)),
          ChangeNotifierProvider(create: (context) => _locationModel),
          ChangeNotifierProvider(create: (context) => ScoreModel()),
          ChangeNotifierProvider(create: (context) => FcmModel()),
        ],
        child: MaterialApp(
            title: 'HD The Grand Tour 2022',
            navigatorKey: locator<NavigationService>().navigatorKey,
            theme: ThemeData(
              // This is the theme of your application.
              primarySwatch: Colors.blue,
            ),
            // builder: (context, widget) => LustrumScaffold(body: widget),
            initialRoute: '/map',
            routes: {
              '/map': (context) => openPage(
                  context, page, true
                  ),
              '/admin': (context) => openPage(context, AdminPage(),false),
              '/stand': (context) => openPage(context, StandPage(), false),
              '/log': (context) => openPage(context, LogPage(), false),
              '/test': (context) => openPage(context, TestPage(), false),
              '/event': (context) => openPage(context, EventPage(), false),
              '/code': (context) => openPage(context, CodePage(), false)
            }));
  }

  Widget openPage(context, Widget page, bool atMap) {
    _locationModel.setMapVisible(atMap);
    if(atMap) {
      _locationModel.handlePlacePhase();
    }
    print('Dispose controller called.. c13');
    // Provider.of<LocationModel>(context, listen: false).disposeController();
    return page;
  }
}
