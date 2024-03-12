import 'package:hive/hive.dart';
part 'player.g.dart';

@HiveType(typeId: 1)
class Player {
  @HiveField(0)
  String name;
  @HiveField(1)
  int? score;
  Player({
    required this.name,
    this.score
  });

  @override
  bool operator==(Object other){
    return other is Player && name == other.name && score == other.score;
  }
  Map<String, dynamic> toJson(){
    return {"name": name, "score": score};
  }
}