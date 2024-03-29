import "./PhaseConfig.dart";

class Phase {
  final int id;
  final String code;
  final String name;
  final String marker;
  final String message;
  final bool isoMode;
  final double lat;
  final double lng;
  final String mapType;
  final double range;
  final PhaseConfig config;

  Phase(
      {this.id,
      this.code,
      this.name,
      this.message,
      this.lat,
      this.mapType,
      this.lng,
      this.range,
      this.isoMode,
      this.marker,
      this.config});

  factory Phase.fromJson(Map<String, dynamic> json) {
    PhaseConfig config;

    if(json['config'] != null) {
      config = PhaseConfig.fromJson(json['config']);
    }
    return Phase(
        id: json['id'],
        mapType: json['mapType'],
        name: json['name'],
        code: json['code'],
        message: json['message'],
        lat: json['lat'].toDouble(),
        lng: json['lng'].toDouble(),
        marker: json['marker'],
        isoMode: json['isoMode'],
        range: json['range'].toDouble(),
        config: config
    );
  }
}
