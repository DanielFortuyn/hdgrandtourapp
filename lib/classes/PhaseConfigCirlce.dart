import 'package:lustrum/classes/PhaseConfigCirlceStroke.dart';

class PhaseConfigCircle {
  final String color;
  final PhaseConfigCircleStroke stroke;

  PhaseConfigCircle({this.color, this.stroke});


  factory PhaseConfigCircle.fromJson(Map<String, dynamic> json)  {

    PhaseConfigCircleStroke stroke;

    stroke = PhaseConfigCircleStroke.fromJson(json['stroke']);

    return PhaseConfigCircle(
        color: json['color'],
        stroke: stroke
    );
  }
}