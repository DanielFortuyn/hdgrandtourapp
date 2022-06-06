import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import '../providers/fcm.dart';
import '../widgets/menu.dart';

import '../providers/location.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);
  static const String routeName = '/map';
  final MapType _mapType = MapType.normal;

  @override
  State<MapPage> createState() => new MapPageState();
}

class MapPageState extends State<MapPage> {
  GoogleMapController _controller;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;

  MapType _mapType;

  @override
  void initState() {
    _mapType = widget._mapType;
    super.initState();
  }

  void callThisOnChild(String str) {
    final snackBar = SnackBar(
      content: Text('Yay! A SnackBar! from nfc ' + str),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    LocationModel _lm = Provider.of<LocationModel>(context, listen: false);
    _lm.addMarker(1);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _setMapType(MapType mapType) {
    if (_mapType == mapType) {
      _mapType = MapType.normal;
    } else {
      _mapType = mapType;
    }
  }

  static final CameraPosition _kInitial = CameraPosition(
    target: LatLng(52.160114, 4.497010),
    zoom: 7,
  );

  @override
  Widget build(BuildContext context) {
    FcmModel fcm = Provider.of<FcmModel>(context);

    Set<Circle> circles = Set.from([Circle(
      circleId: CircleId('first'),
      fillColor: Color(0x33FF00BB),
      strokeWidth: 3,
      strokeColor: Color(0xAAFF00BB),
      center: LatLng(52.168094,4.584889),
      radius: 400
    )]);
    return new GestureDetector(
        child: Scaffold(
          drawer: Menu(),
          body: Consumer<LocationModel>(builder: (context, model, child) {
            fcm.setContext(context);
            GoogleMap gm = GoogleMap(
                mapType: _mapType,
                initialCameraPosition: _kInitial,
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                  model.setController(_controller);
                  model.updateCamera();
                },
                onTap: (tap) {
                  print('[Tap]' + _controller.toString());

                  model.setController(_controller);
                },
                myLocationButtonEnabled: false,
                //Dit moet uit het model komen zodat de widget stateless kan worden, nu issues door states in beide dingen...
                markers: Set<Marker>.of(model.getAllMarkers().values),
                circles: circles,
            );

            return gm;
          }),
          // floatingActionButton: FloatingActionButton.extended(
          //     onPressed: () => _addTargetMarker(),
          //     label: Icon(Icons.directions_boat))
        ),
        onLongPress: () {
          setState(() {
            _setMapType(MapType.none);
          });
        });
  }
}
