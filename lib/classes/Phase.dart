import 'dart:ffi';

class Phase {
  final Int8 id;
  final String code;
  final String message;
  final Float lat;
  final Float lng;
  final Int64 range;

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
