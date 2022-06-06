import 'dart:async';
import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:flutter_geofence/Geolocation.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import '../classes/TeamLocation.dart';
import '../classes/Team.dart';

import '../helpers/device.dart';
import '../helpers/rest.dart';

import 'dart:math';

class LocationModel with ChangeNotifier {
  SocketIO _socket;
  DeviceInfo _deviceInfo = new DeviceInfo();
  AndroidDeviceInfo deviceInfo;
  String _deviceId;
  Rest _rest;

  List<TeamLocation> _teamLocations = [];
  List<TeamLocation> get teamLocations => _teamLocations;

  Map<MarkerId, Marker> _destinationMarkers = {};
  Map<MarkerId, Marker> get destinationMarkers => _destinationMarkers;

  Map<MarkerId, Marker> _teamMarkers = {};
  Map<MarkerId, Marker> get teamMarkers => _teamMarkers;

  String snackTest = '';
  bool showSnack = false;

  GoogleMapController controller;

  Timer sendGetLocationTimer;
  LocationSettings locationSettings;


  LocationModel(socket, device, Rest rest) {
    print("[LOCATION_INSTANCE] Creating a new instance of the location model");

    print("[LOAD] Geofence");
    Geofence.initialize();
    Geofence.requestPermissions();
    Geofence.startListening(GeolocationEvent.entry, (entry) {
      print('[GEO] In');
      print("Entry of a georegion" + "Welcome to: ${entry.id}");
      addMarker(1);
    });

    Geofence.startListening(GeolocationEvent.exit, (entry) {
      print('[GEO] Exit');
      print("Exit of a georegion" + "Byebye to: ${entry.id}");
      addMarker(1);

    });

    Geolocation location = Geolocation(
        latitude: 52.168094,
        longitude: 4.584889,
        radius: 400.0,
        id: "Kerkplein13");

    Geolocation _location = Geolocation(
        latitude: 52.145131,
        longitude: 4.486045,
        radius: 400.0,
        id: "Case del pensveen"
    );
    Geofence.addGeolocation(location, GeolocationEvent.entry)
        .then((onValue) {
      print("great success");
      print("[LOAD] added" + " Your geofence has been added!");
    }).catchError((onError) {
      print("great failure");
    });

    Geofence.addGeolocation(_location, GeolocationEvent.entry)
        .then((onValue) {
      print("great success");
      print("[LOAD] added" + " Your geofence has been added!");
    }).catchError((onError) {
      print("great failure");
    });


    _rest = rest;
    _socket = socket;
    _socket.subscribe('team.location.update',
        (jsonData) => _handleTeamLocationUpdate(jsonData));

    _socket.subscribe(
        'place.finish.marker', (jsonData) => _handleMarkerPlacement(jsonData));

    _socket.sendMessage('get.location.update', jsonEncode({"hdh": "10"}));
    sendGetLocationTimer = setGetLocationTimer();

    locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
          "Lustrum 2022 will continue to receive your location even when you aren't using it",
          notificationTitle: "Running in Background",
          enableWakeLock: true,
        )
    );

    //Get inital position
    Geolocator.getCurrentPosition(
            forceAndroidLocationManager: true,
            desiredAccuracy: LocationAccuracy.best)
        .then((Position position) => _sendLocation(position));

    //Keep track of updates
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) => _sendLocation(position));
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
      _socket.sendMessage('get.location.update', jsonEncode({"hdh": "10"}));
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

    if (_deviceId != null && _deviceIsOfTeam(_teams, _deviceId)) {
      _socket.sendMessage(
          'post.location.update',
          json.encode({
            'lat': position.latitude,
            'lng': position.longitude,
            'deviceId': _deviceId,
          }));
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

  addMarker(id) async {
    final _random = new Random();
    final l = (_random.nextInt(5) - 2.5) + id;
    final p = (_random.nextInt(5) - 2.5) + id;
    await addWithCoordsMarker(id.toString(), LatLng(50 + l, 10 + p));
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
    _destinationMarkers.remove(markerId);
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
    print("received location update");
    List<dynamic> locations = json.decode(jsonData);
    // If the call to the server was successful, parse the JSON.
    _teamLocations = [];
    locations.forEach((item) async {
      TeamLocation _tl = TeamLocation.fromJson(item);
      _teamLocations.add(_tl);
    });
    _updateMarkers();
  }

  void _updateMarkers() async {
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
      _teamMarkers[_markerId] = marker;
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

  void _updateCamera() async {
    List<LatLng> list = [];
    Map<MarkerId, Marker> _ckers = getAllMarkers();

    if (_ckers.length > 0) {
      _ckers.forEach((k, v) {
        list.add(LatLng(v.position.latitude, v.position.longitude));
      });
      if (controller != null) {
        controller.getVisibleRegion().then((f) {
          controller.animateCamera(
              CameraUpdate.newLatLngBounds(boundsFromLatLngList(list), 50));
        });
      } else {
        print("Controller is null");
      }
    }
  }
}
