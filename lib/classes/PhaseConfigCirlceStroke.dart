import 'dart:convert';
class PhaseConfigCircleStroke {
  final int size;
  final String color;

  PhaseConfigCircleStroke({this.size, this.color});

  factory PhaseConfigCircleStroke.fromJson(Map<String, dynamic> json)  {

    return PhaseConfigCircleStroke(
      size: json['size'],
      color: json['color']
    );
  }
}
