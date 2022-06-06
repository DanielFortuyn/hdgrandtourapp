import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';

class TeamLocation {
  final double lat;
  final double lng;
  final String deviceId;
  final String name;
  final String createdAt;
  final String image;
  Future<BitmapDescriptor> loadedImage;

  BitmapDescriptor test;

  TeamLocation(
      {this.name,
      this.image,
      this.lat,
      this.lng,
      this.deviceId,
      this.createdAt});

  factory TeamLocation.fromJson(Map<String, dynamic> json) {
    return TeamLocation(
      name: json['name'],
      image: json['image'],
      lat: json['lat'],
      lng: json['lng'],
      deviceId: json['deviceId'],
      createdAt: json['createdAt'],
    );
  }

  Future<BitmapDescriptor> getImage()  {
    if(image != null) {
      return BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(16, 16)), image);
    }
    return null;
  }

  static Future<BitmapDescriptor> getAssetIcon(
      BuildContext context, String assetName) async {
    final Completer<BitmapDescriptor> bitmapIcon =
        Completer<BitmapDescriptor>();
    final ImageConfiguration config = createLocalImageConfiguration(context);

    AssetImage(assetName)
        .resolve(config)
        .addListener(ImageStreamListener((ImageInfo image, bool sync) async {
      final ByteData bytes =
          await image.image.toByteData(format: ImageByteFormat.png);
      final BitmapDescriptor bitmap =
          BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
      bitmapIcon.complete(bitmap);
    }));

    return await bitmapIcon.future;
  }
}