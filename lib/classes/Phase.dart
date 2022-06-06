import 'dart:ffi';

class Phase {
  final int id;
  final String code;
  final String message;
  final double lat;
  final double lng;
  final int range;

  Phase({this.id, this.code, this.message, this.lat, this.lng, this.range});

  factory Phase.fromJson(Map<String, dynamic> json)  {

    return Phase(
        id: json['id'],
        code: json['code'],
        message: json['message'],
        lat: json['lat'],
        lng: json['lng'],
        range: json['range']
    );
  }
}
