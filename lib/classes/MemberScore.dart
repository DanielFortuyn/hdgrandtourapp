class MemberScore {

  final String image;
  final String name;
  final int score;

  MemberScore({this.score, this.image, this.name});

  factory MemberScore.fromJson(Map<String, dynamic> json)  {

    return MemberScore(
      image: json['image'],
      name: json['name'],
      score: json['score']
    );
  }
}
