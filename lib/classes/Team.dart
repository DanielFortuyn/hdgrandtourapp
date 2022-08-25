import "./Phase.dart";

class Team {
  final String id;
  final String name;
  final String deviceId;
  final Phase phase;

  Team({this.id, this.deviceId, this.name, this.phase});

  factory Team.fromJson(Map<String, dynamic> json)  {
    Phase phase;

    if(json['Phase'] != null) {
      phase = Phase.fromJson(json['Phase']);
    }

    return Team(
      id: json['id'],
      deviceId: json['deviceId'],
      name: json['name'],
      phase: phase
    );
  }
}
