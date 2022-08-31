import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import '../providers/fcm.dart';
import '../widgets/menu.dart';

import '../providers/location.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);
  static const String routeName = '/';
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

  @override
  void dispose() {
    super.dispose();
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
    // LocationModel _lm = Provider.of<LocationModel>(context, listen: false);
    // _lm.addMarker(1);
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static final CameraPosition _kInitial = CameraPosition(
    target: LatLng(52.160114, 4.497010),
    zoom: 7,
  );

  Widget renderStack(BuildContext context, FcmModel fcm, LocationModel model) {
    fcm.setContext(context);
    print('c18 ' + model.getAllMarkers().toString());
    GoogleMap gm = GoogleMap(
      mapType: model.mapType,
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
      zoomControlsEnabled: false,
      //Dit moet uit het model komen zodat de widget stateless kan worden, nu issues door states in beide dingen...
      markers: Set<Marker>.of(model.getAllMarkers().values),
      circles: Set<Circle>.of(model.soc),
    );

    List<Widget> stackChildren = [Positioned.fill(child: gm)];

    if (model.currentPhase != null && model.currentPhase.message != '') {
      stackChildren.add(Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
            margin: EdgeInsets.only(top: 5, left: 8, right: 8, bottom: 5),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF003380),
                      Color(0xFF007380),
                    ]),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset.zero)
                ]),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width - 34,
                            child: Text(
                              model.currentPhase.name,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'gt',
                                color: Colors.white,
                              ),
                            ))),
                    SizedBox(height: 8),
                    Container(
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width - 34,
                            child: Text(
                              model.currentPhase.message,
                              style: TextStyle(
                                fontSize: 13.0,
                                fontFamily: 'gt',
                                color: Colors.white,
                              ),
                            )))
                  ],
                )
              ],
            ),
          )));
    }

    return new Stack(
      children: stackChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    FcmModel fcm = Provider.of<FcmModel>(context);

    return new GestureDetector(
        child: Scaffold(
          drawer: Menu(),
          body: Consumer<LocationModel>(builder: (context, model, child) {
            return renderStack(context, fcm, model);
          }),
          floatingActionButton:
              Consumer<LocationModel>(builder: (context, model, child) {
            return FloatingActionButton.extended(
                onPressed: model.toggleIso, label: Icon(Icons.directions_boat));
          }),
        ),
        onLongPress: () {});
  }
}
