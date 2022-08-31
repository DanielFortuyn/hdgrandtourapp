import 'dart:async';
import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:lustrum/classes/PhaseConfigCirlce.dart';
import 'package:lustrum/helpers/socket.dart';
import '../classes/TeamLocation.dart';
import '../classes/Team.dart';
import '../classes/Phase.dart';
import '../classes/LogMessage.dart';

import '../helpers/device.dart';
import '../helpers/rest.dart';
import '../helpers/hexcolor.dart';

import 'dart:math';

import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:audioplayers/audioplayers.dart';

class LocationModel with ChangeNotifier {
  SocketHelper _socket;
  DeviceInfo _deviceInfo = new DeviceInfo();
  AndroidDeviceInfo deviceInfo;
  int _currentPhaseId;
  int get currentPhaseId => _currentPhaseId;
  final player = AudioPlayer();
  String _deviceId;
  String get deviceId => _deviceId;

  Rest _rest;
  Set<Circle> _soc = new Set<Circle>();
  Set<Circle> get soc => _soc;
  List<TeamLocation> _teamLocations = [];
  List<TeamLocation> get teamLocations => _teamLocations;

  Phase _currentPhase;
  Phase get currentPhase => _currentPhase;

  String adminDeviceId = '909ff9f4b47d9068';

  bool _mapVisible = false;
  void setMapVisible(bool visible) {
    _mapVisible = visible;
  }

  List<LogMessage> _logMessages = [];
  List<LogMessage> get logMessages => _logMessages;

  MapType _mapType = MapType.normal;
  MapType get mapType => _mapType;
  bool _iso = false;

  Map<MarkerId, Marker> _destinationMarkers = {};
  Map<MarkerId, Marker> get destinationMarkers => _destinationMarkers;

  Map<MarkerId, Marker> _teamMarkers = {};
  Map<MarkerId, Marker> get teamMarkers => _teamMarkers;

  String snackTest = '';
  bool showSnack = false;
  GoogleMapController controller;

  Timer sendGetLocationTimer;
  LocationSettings locationSettings;
  Geolocation location;

  int _newMessages = 0;
  int get newMessages => _newMessages;

  void setNewMessages() {
    _newMessages = 0;
  }

  void addLogMessage(LogMessage _logMsg) {
    _newMessages++;
    _logMessages.insert(0, _logMsg);
  }

  static final LocationModel _singleton = LocationModel._internal();
  factory LocationModel() => _singleton;
  LocationModel._internal() {
    init();
  }

  void init() {
    _rest = new Rest();
    final DeviceInfo _deviceInfo = DeviceInfo();

    // addLogMessage(LogMessage(
    //     "Initialized",
    //     "The location lib has been initialized for: " +
    //         _deviceId,
    //     icon: Icons.build));
    // _newMessages--;

    SocketHelper _socket = new SocketHelper();

    _socket.socket.on('team.location.update',
        (jsonData) => _handleTeamLocationUpdate(jsonData));

    _socket.socket.on(
        'place.finish.marker', (jsonData) => _handleMarkerPlacement(jsonData));

    _socket.socket.emit('get.location.update', jsonEncode({"hdh": "10"}));
    sendGetLocationTimer = setGetLocationTimer();

    _socket.socket.on('refresh', (jsonData) => _handleRefresh(jsonData));

    locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "HD Grand Tour 2022 will continue to receive your location even when you aren't using it",
          notificationTitle: "Running in Background",
          enableWakeLock: true,
        ));

    //Get initial position
    Geolocator.getCurrentPosition(
            forceAndroidLocationManager: true,
            desiredAccuracy: LocationAccuracy.best)
        .then((Position position) => _sendLocation(position));

    //Keep track of updates
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) => _sendLocation(position));

    _handlePlacePhase();
  }

  void manualSubmit() {
    addLogMessage(LogMessage("Manually submitted location", "",
        icon: Icons.add_task, level: 1));
    _rest
        .processManualSubmit(deviceId.toString())
        .then((value) => handlePlacePhase());
  }

  void reloadMap() {
    print('xx[115] got reload map from push message');
    _handlePlacePhase();
  }

  void clearLog() {
    _logMessages.clear();
  }

  void toggleIso() {
    _iso = !_iso;
    print('[i100] Toggleing iso' + _iso.toString());
  }

  void resetPhase() {
    _rest.updatePhase(_deviceId, "20").then((value) => _handlePlacePhase());
  }

  void bumpFromAdmin() async {
    Team team = await _rest.getTeamByDeviceId(_deviceId);
    Phase phase = team.phase;
    player.play(AssetSource('kei.m4a'));
    _rest
        .updatePhase(_deviceId, phase.code.toString())
        .then((value) => _handlePlacePhase());
  }

  void handleCode(code) {
    print('[p319] code processing');
    if (code == 'stopkiosk') {
      stopKioskMode();
    }
    if (code == 'upupdowndownleftrightleftrightba') {
      _rest.processCode(_deviceId, code).then((value) => handlePlacePhase());
    }
    _rest.processCode(_deviceId, code).then((value) => handlePlacePhase());
  }

  void handlePlacePhase() async {
    await _handlePlacePhase();
  }

  void _removeEverything() async {
    _destinationMarkers.clear();
    _soc.clear();
    await Geofence.removeAllGeolocations();
    addLogMessage(LogMessage('Everything removed', 'Map was cleared..'));
  }

  void setMapTypeFromPhase(Phase phase) {
    if (phase.mapType == 'none') {
      _mapType = MapType.none;
    }
    if (phase.mapType == 'normal') {
      _mapType = MapType.normal;
    }
    if (phase.mapType == 'hybrid') {
      _mapType = MapType.hybrid;
    }
    if (phase.isoMode != null) {
      _iso = !!phase.isoMode;
    }
  }

  void _handlePlacePhase() async {
    await _removeEverything();
    Team team = await _rest.getTeamByDeviceId(_deviceId);
    if (team != null && team.phase != null) {
      _currentPhaseId = team.phase.id;
    }

    if (team != null && team.phase != null && team.phase.marker != '0') {
      Phase phase = team.phase;
      _currentPhase = phase;

      print('c1001' + phase.marker + ' ' + phase.range.toString());
      setMapTypeFromPhase(phase);

      if (phase.marker != 'hidden') {
        addMarker(phase.id, phase.lat, phase.lng);
      }
      if (phase.range.toInt() > 0) {
        _placeGeofenseFromPhase(phase);
        print('c1111 placing circle ' + phase.marker);
        if (phase.marker == 'circle') {
          print('c1112 placing circle for real');
          _placeCircleFromPhase(phase);
        }
      }
      _currentPhaseId = phase.id;
    }
    notifyListeners();
  }

  void _placeCircleFromPhase(Phase phase) {
    PhaseConfigCircle pcc;
    Color fill = Color(0x33003380);
    Color stroke = Color(0xFF003380);
    int strokeSize = 3;

    if (phase.config != null && phase.config.circle != null) {
      pcc = phase.config.circle;
      if (pcc.stroke != null) {
        if (pcc.stroke.color != null) {
          stroke = HexColor(pcc.stroke.color);
        }
        if (pcc.stroke.size != null) {
          strokeSize = pcc.stroke.size;
        }
      }
      if (pcc.color != null) {
        fill = HexColor(pcc.color);
      }
    }

    Circle c = Circle(
        circleId: CircleId(phase.id.toString()),
        fillColor: fill,
        strokeWidth: strokeSize,
        strokeColor: stroke,
        center: LatLng(phase.lat, phase.lng),
        radius: phase.range);

    _soc.add(c);
  }

  void _placeGeofenseFromPhase(Phase phase) {
    location = Geolocation(
        latitude: phase.lat,
        longitude: phase.lng,
        radius: phase.range,
        id: "Phase-" + phase.id.toString());

    print("[l123]" + location.toString());
    Geofence.addGeolocation(location, GeolocationEvent.entry).then((onValue) {
      // if(phase.id != currentPhaseId) {
      addLogMessage(LogMessage(
          "Added a new location ${phase.id}", phase.message,
          icon: Icons.add_task, level: 1));
      // }
    }).catchError((onError) {
      print("great failure");
    });

    Geofence.startListening(GeolocationEvent.entry, (entry) {
      addLogMessage(
          LogMessage("Entered geofence", "You entered ${entry.id}", level: 1));
      player.play(AssetSource('sounds/kei.m4a'));
      _rest
          .updatePhase(_deviceId, entry.id)
          .then((value) => _handlePlacePhase());
    });
  }

  void _handleMarkerPlacement(jsonData) async {
    try {
      dynamic markerData = json.decode(jsonData);

      double lat = double.tryParse(markerData["lat"]) ?? 1;
      double lng = double.tryParse(markerData["lng"]) ?? 1;

      await addWithCoordsMarker(markerData["id"].toString(), LatLng(lat, lng));
      if (controller != null) {
        _updateCamera();
      }
      notifyListeners();
    } on FormatException catch (e) {
      print(e);
    }
  }

  bool _deviceIsOfTeam(List<Team> _teams, String currentDeviceId) {
    bool result = false;
    if (_teams != null && _teams.length > 0) {
      _teams.forEach((Team element) {
        if (element.deviceId == currentDeviceId) {
          result = true;
        }
      });
    }
    return result;
  }

  Timer setGetLocationTimer() {
    return Timer(Duration(seconds: 10), () {
      print("Get location fired");
      _socket.socket.emit('get.location.update', jsonEncode({"hdh": "10"}));
      sendGetLocationTimer = setGetLocationTimer();
    });
  }

  void _sendLocation(Position position) async {
    print("SENDING MY LOCATION....");
    sendGetLocationTimer.cancel();
    sendGetLocationTimer = setGetLocationTimer();
    //Push new location to our sockets//
    deviceInfo = await _deviceInfo.fetchInfo();
    _deviceId = deviceInfo.androidId;
    List<Team> _teams = await _rest.fetchTeams();

    if (_socket == null) {
      print('c002 reconnecting socket');
      _socket = new SocketHelper();
    }

    print('c0003 ' + _deviceId);

    if (_deviceId != null && _deviceIsOfTeam(_teams, _deviceId)) {
      _socket.socket.emit('post.location.update', {
        'lat': position.latitude,
        'lng': position.longitude,
        'deviceId': _deviceId,
      });
    }
  }

  Future<bool> deviceIsOfTeam() async {
    //Push new location to our sockets//
    deviceInfo = await _deviceInfo.fetchInfo();
    _deviceId = deviceInfo.androidId;
    List<Team> _teams = await _rest.fetchTeams();
    return _deviceIsOfTeam(_teams, _deviceId);
  }

  Future<BitmapDescriptor> getImage(String image) {
    return BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(16, 16)), image);
  }

  addMarker(id, lat, lng) async {
    final _random = new Random();
    await addWithCoordsMarker(id.toString(), LatLng(lat, lng));
  }

  addWithCoordsMarker(String id, LatLng latLng) async {
    MarkerId _markerId = new MarkerId(id);
    _destinationMarkers[_markerId] = new Marker(
        markerId: _markerId,
        position: latLng,
        icon: await getImage('assets/finish.png'),
        onTap: () {
          _onMarkerTapped(_markerId);
        });
    notifyListeners();
  }

  _onMarkerTapped(MarkerId markerId) {
    // _destinationMarkers.remove(markerId);s
    _updateCamera();
    notifyListeners();
  }

  Map<MarkerId, Marker> getAllMarkers() {
    Map<MarkerId, Marker> markers = {};
    markers.addAll(destinationMarkers);
    markers.addAll(teamMarkers);
    return markers;
  }

  void setController(_controller) {
    controller = _controller;
  }

  void _handleTeamLocationUpdate(jsonData) {
    print("received location update c19");
    // print(json.decode(jsonData));
    List<dynamic> locations = jsonData;
    // If the call to the server was successful, parse the JSON.
    _teamLocations = [];
    locations.forEach((item) async {
      TeamLocation _tl = TeamLocation.fromJson(item);
      _teamLocations.add(_tl);
    });
    _updateMarkers();
  }

  void _handleRefresh(jsonData) {
    print('R001 Got refresh..: ' + jsonData.toString());
    if (jsonData.deviceId != null && jsonData.deviceId.deviceId.toString() == _deviceId) {
      player.play(AssetSource('sounds/ktis.m4a'));
      this._handlePlacePhase();
    }
  }

  void _updateMarkers() async {
    print('c91 updating markers');
    for (var _loc in _teamLocations) {
      MarkerId _markerId = MarkerId(_loc.deviceId);
      final Marker marker = Marker(
        markerId: _markerId,
        icon: await _loc.getImage(),
        position: LatLng(_loc.lat, _loc.lng),
        onTap: () {
          _onMarkerTapped(_markerId);
        },
      );
      if (_iso) {
        if (_loc.deviceId == _deviceId) {
          _teamMarkers[_markerId] = marker;
        } else {
          _teamMarkers.remove(_markerId);
        }
      } else {
        _teamMarkers[_markerId] = marker;
      }
    }
    _updateCamera();
    notifyListeners();
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  void disposeController() {
    controller = null;
  }

  void updateCamera() {
    _updateCamera();
  }

  void _setMapType(MapType mapType) {
    if (_mapType == mapType) {
      _mapType = MapType.normal;
    } else {
      _mapType = mapType;
    }
  }

  void _updateCamera() async {
    List<LatLng> list = [];
    Map<MarkerId, Marker> _ckers = getAllMarkers();
    if (_mapVisible) {
      if (_ckers.length > 0) {
        _ckers.forEach((k, v) {
          list.add(LatLng(v.position.latitude, v.position.longitude));
        });
        // if(list.length > 1) {
        controller.getVisibleRegion().then((f) {
          controller.animateCamera(
              CameraUpdate.newLatLngBounds(boundsFromLatLngList(list), 50));
        });
        // }
      } else {
        print("Controller is null");
      }
    }
  }
}
