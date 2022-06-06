class TeamScore {

  final String image;
  final String name;
  final int score;

  TeamScore({this.score, this.image, this.name});

  factory TeamScore.fromJson(Map<String, dynamic> json)  {

    return TeamScore(
      image: json['image'],
      name: json['name'],
      score: json['score']
    );
  }
}
