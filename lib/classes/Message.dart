class Message {
  final String id;
  final String name;
  final String message;

  Message({this.id, this.message, this.name});

  factory Message.fromJson(Map<String, dynamic> json)  {

    return Message(
      id: json['id'],
      message: json['message'],
      name: json['name']
    );
  }
}
