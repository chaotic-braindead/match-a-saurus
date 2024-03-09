class Player {
  final String name;
  final int score;
  Player({
    required this.name,
    required this.score
  });
  @override
  bool operator==(Object other){
    return other is Player && name == other.name && score == other.score;
  }
  Map<String, dynamic> toJson(){
    return {"name": name, "score": score};
  }
}