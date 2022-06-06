class Score {

  final String image;
  final String nick;
  final String lastName;
  final String firstName;
  final String description;

  final int score;

  Score({this.score, this.image, this.nick, this.description, this.firstName, this.lastName});

  factory Score.fromJson(Map<String, dynamic> json)  {
    
    return Score(
      image: json['image'],
      nick: json['nick'],
      score: json['score'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      description: json['description'],
    );
  }
}
