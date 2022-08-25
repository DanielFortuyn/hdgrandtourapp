import "./PhaseConfigCirlce.dart";
class PhaseConfig {
  PhaseConfigCircle circle;

  PhaseConfig({this.circle});

  factory PhaseConfig.fromJson(Map<String, dynamic> json)  {
    PhaseConfigCircle circle;
    circle = PhaseConfigCircle.fromJson(json['circle']);
    return PhaseConfig(
        circle: circle,
    );
  }
}