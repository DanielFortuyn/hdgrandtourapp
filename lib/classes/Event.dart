class Event {
  
  final String id;
  final String teamId;
  final String event; 
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic data;

  Event({this.id, this.teamId, this.event, this.data, this.createdAt, this.updatedAt});

  factory Event.fromJson(Map<String, dynamic> json)  {
    
    return Event(
      id: json['id'],
      teamId: json['teamId'],
      event: json['event'],
      data: json['data'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
